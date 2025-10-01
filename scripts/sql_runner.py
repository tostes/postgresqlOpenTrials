"""Author: Diego Tostes

Helper utilities to execute SQL files against PostgreSQL.
"""

from __future__ import annotations

import logging
import re
from contextlib import contextmanager
from pathlib import Path
from typing import Iterable, Iterator

import psycopg2
from psycopg2.extensions import connection as PgConnection

from db_config import DatabaseConfig, DEFAULT_CONFIG


LOGGER = logging.getLogger(__name__)


@contextmanager
def get_connection(config: DatabaseConfig = DEFAULT_CONFIG) -> Iterator[PgConnection]:
    """Yield a psycopg2 connection using the provided configuration."""

    connection = psycopg2.connect(**config.as_dict())
    try:
        yield connection
    finally:
        connection.close()


def find_create_table_target(sql_text: str) -> tuple[str | None, str] | None:
    """Return the first (schema, table) pair from a CREATE TABLE statement or ``None``."""

    match = re.search(
        r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?"
        r"(?:(?P<schema>\w+)\.)?(?P<table>\w+)",
        sql_text,
        flags=re.IGNORECASE,
    )
    if not match:
        return None
    return match.group("schema"), match.group("table")


def execute_sql_file(path: Path, connection: PgConnection) -> None:
    """Execute SQL file unless its target table already exists in the database.

    When the first ``CREATE TABLE`` target is already present, the SQL is skipped
    without committing the transaction; otherwise, the statements are executed
    and the connection is committed.
    """

    LOGGER.info("Executing SQL file: %s", path)
    sql_text = path.read_text(encoding="utf-8")
    target = find_create_table_target(sql_text)

    if target is not None:
        schema, table = target
        regclass = f"{schema}.{table}" if schema else table
        with connection.cursor() as cursor:
            cursor.execute("SELECT to_regclass(%s)", (regclass,))
            if cursor.fetchone()[0] is not None:
                LOGGER.info("Skipping %s: table already exists", path)
                return

    with connection.cursor() as cursor:
        cursor.execute(sql_text)
    connection.commit()


def execute_sql_files(paths: Iterable[Path], config: DatabaseConfig = DEFAULT_CONFIG) -> None:
    """Execute multiple SQL files in a single database session."""

    with get_connection(config) as connection:
        for sql_path in paths:
            execute_sql_file(sql_path, connection)


def iter_sql_files(
    directory: Path, priority_prefix: str | None = "vocabulary_"
) -> Iterable[Path]:
    """Yield SQL files from a directory with optional prioritized prefix ordering."""

    sql_files = [path for path in directory.glob("*.sql") if path.is_file()]

    if priority_prefix:
        prioritized = sorted(
            (path for path in sql_files if path.name.startswith(priority_prefix))
        )
        others = sorted(
            (path for path in sql_files if not path.name.startswith(priority_prefix))
        )
        yield from prioritized
        yield from others
    else:
        yield from sorted(sql_files)
