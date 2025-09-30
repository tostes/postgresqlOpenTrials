"""Author: Diego Tostes

Helper utilities to execute SQL files against PostgreSQL.
"""

from __future__ import annotations

import logging
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


def execute_sql_file(path: Path, connection: PgConnection) -> None:
    """Execute all SQL statements contained in the given file."""

    LOGGER.info("Executing SQL file: %s", path)
    sql_text = path.read_text(encoding="utf-8")
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
