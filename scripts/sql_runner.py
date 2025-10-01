"""Author: Diego Tostes

Helper utilities to execute SQL files against PostgreSQL.
"""

from __future__ import annotations

import logging
import re
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Iterator

import psycopg2
from psycopg2.extensions import connection as PgConnection

from db_config import DatabaseConfig, DEFAULT_CONFIG


LOGGER = logging.getLogger(__name__)
PROCEDURE_ARCHIVE_DIR = Path("database/procedures/created_procedure")


@dataclass(slots=True)
class RoutineTarget:
    """Details describing the first CREATE FUNCTION/PROCEDURE statement."""

    kind: str
    schema: str | None
    name: str
    argument_signature: str
    statement: str


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


def _split_signature_arguments(args: str) -> list[str]:
    """Split argument declarations on commas while respecting parentheses."""

    result: list[str] = []
    current: list[str] = []
    depth = 0
    for char in args:
        if char == "(":
            depth += 1
        elif char == ")" and depth > 0:
            depth -= 1
        if char == "," and depth == 0:
            result.append("".join(current))
            current = []
            continue
        current.append(char)
    if current:
        result.append("".join(current))
    return result


def _normalize_argument_signature(args: str) -> str:
    """Return a canonical comma-separated list of argument type expressions."""

    if not args.strip():
        return ""

    type_prefixes = {
        "bigint",
        "bigserial",
        "bit",
        "boolean",
        "box",
        "bytea",
        "char",
        "character",
        "citext",
        "date",
        "decimal",
        "double",
        "float",
        "inet",
        "int",
        "integer",
        "json",
        "jsonb",
        "line",
        "lseg",
        "money",
        "numeric",
        "path",
        "point",
        "polygon",
        "real",
        "serial",
        "smallint",
        "smallserial",
        "text",
        "time",
        "timestamp",
        "tsquery",
        "tsvector",
        "uuid",
        "varchar",
        "xml",
    }

    parts = []
    for piece in _split_signature_arguments(args):
        normalized_piece = re.sub(r"\s+", " ", piece.strip())
        if not normalized_piece:
            continue

        # Remove default expressions specified via ``DEFAULT`` or ``=``.
        normalized_piece = re.split(
            r"(?i)\bdefault\b|=",
            normalized_piece,
            maxsplit=1,
        )[0].strip()

        tokens = normalized_piece.split()
        while tokens and tokens[0].upper() in {"IN", "OUT", "INOUT"}:
            tokens.pop(0)

        if not tokens:
            continue

        if tokens[0].upper() == "VARIADIC":
            if len(tokens) > 2:
                type_tokens = [tokens[0]] + tokens[2:]
            elif len(tokens) == 2:
                type_tokens = tokens
            else:
                type_tokens = tokens
        else:
            first_token = tokens[0]
            lowered_first = first_token.lower().lstrip('"').rstrip('"')
            if (
                lowered_first in type_prefixes
                or lowered_first.startswith("pg_")
                or lowered_first.startswith("public.")
                or lowered_first.startswith("information_schema.")
            ):
                type_tokens = tokens
            elif len(tokens) > 1:
                type_tokens = tokens[1:]
            else:
                type_tokens = tokens

        normalized_type = " ".join(type_tokens)
        parts.append(normalized_type)
    return ", ".join(parts)


def _extract_create_statement(sql_text: str, start_index: int) -> str:
    """Extract the CREATE statement starting at ``start_index`` including its terminator."""

    in_single_quote = False
    in_double_quote = False
    dollar_tag: str | None = None
    index = start_index
    length = len(sql_text)

    while index < length:
        char = sql_text[index]
        previous_char = sql_text[index - 1] if index > 0 else ""

        if dollar_tag is not None:
            if sql_text.startswith(dollar_tag, index):
                index += len(dollar_tag)
                dollar_tag = None
                continue
            index += 1
            continue

        if in_single_quote:
            if char == "'" and previous_char != "\\":
                in_single_quote = False
            index += 1
            continue

        if in_double_quote:
            if char == '"' and previous_char != "\\":
                in_double_quote = False
            index += 1
            continue

        if char == "'":
            in_single_quote = True
            index += 1
            continue

        if char == '"':
            in_double_quote = True
            index += 1
            continue

        if char == "$":
            dollar_match = re.match(r"\$[A-Za-z0-9_]*\$", sql_text[index:])
            if dollar_match:
                tag = dollar_match.group()
                if dollar_tag is None:
                    dollar_tag = tag
                elif dollar_tag == tag:
                    dollar_tag = None
                index += len(tag)
                continue

        if char == ";":
            return sql_text[start_index : index + 1]

        if char == "(":
            # Parentheses affect comma splitting but not termination.
            pass

        index += 1

    return sql_text[start_index:]


def find_create_routine_target(sql_text: str) -> RoutineTarget | None:
    """Return metadata for the first CREATE FUNCTION/PROCEDURE statement in ``sql_text``."""

    match = re.search(
        r"CREATE\s+(?:OR\s+REPLACE\s+)?(?P<kind>FUNCTION|PROCEDURE)\s+"
        r"(?:(?P<schema>\w+)\.)?(?P<name>\w+)\s*\((?P<args>[^)]*)\)",
        sql_text,
        flags=re.IGNORECASE,
    )
    if not match:
        return None

    statement = _extract_create_statement(sql_text, match.start())
    argument_signature = _normalize_argument_signature(match.group("args"))
    schema = match.group("schema")
    kind = match.group("kind").upper()
    name = match.group("name")

    return RoutineTarget(
        kind=kind,
        schema=schema,
        name=name,
        argument_signature=argument_signature,
        statement=statement,
    )


def _normalize_routine_definition(definition: str) -> str:
    """Normalize routine definitions for comparison purposes."""

    normalized = re.sub(
        r"CREATE\s+OR\s+REPLACE", "CREATE", definition, flags=re.IGNORECASE
    )
    normalized = normalized.strip()
    normalized = re.sub(r";\s*$", "", normalized)
    normalized = re.sub(r"\s+", " ", normalized)
    return normalized.lower()


def execute_sql_file(path: Path, connection: PgConnection) -> None:
    """Execute SQL file, skipping unchanged routine definitions or existing tables.

    The function inspects the SQL for the first ``CREATE FUNCTION``/``CREATE PROCEDURE``
    signature. When found, it queries PostgreSQL for the current definition using
    ``pg_get_functiondef``. Unchanged routines are archived instead of being executed;
    changed routines are dropped before re-creation. If the SQL contains a table
    definition, execution is skipped when the table already exists. Otherwise, the
    SQL is executed and the transaction committed.
    """

    LOGGER.info("Executing SQL file: %s", path)
    sql_text = path.read_text(encoding="utf-8")
    routine_target = find_create_routine_target(sql_text)

    drop_statement: str | None = None

    if routine_target is not None:
        qualified_name = (
            f"{routine_target.schema}.{routine_target.name}"
            if routine_target.schema
            else routine_target.name
        )
        signature = (
            f"{qualified_name}({routine_target.argument_signature})"
            if routine_target.argument_signature
            else f"{qualified_name}()"
        )
        normalized_new_definition = _normalize_routine_definition(
            routine_target.statement
        )

        with connection.cursor() as cursor:
            cursor.execute("SELECT to_regprocedure(%s)", (signature,))
            oid_row = cursor.fetchone()

            if oid_row and oid_row[0] is not None:
                cursor.execute("SELECT pg_get_functiondef(%s)", (oid_row[0],))
                current_definition_row = cursor.fetchone()
                current_definition = (
                    current_definition_row[0] if current_definition_row else None
                )

                if current_definition is not None:
                    normalized_current_definition = _normalize_routine_definition(
                        current_definition
                    )

                    if normalized_current_definition == normalized_new_definition:
                        archive_path = PROCEDURE_ARCHIVE_DIR / path.name
                        archive_path.parent.mkdir(parents=True, exist_ok=True)
                        if path.resolve() != archive_path.resolve():
                            path.replace(archive_path)
                        LOGGER.info(
                            "Skipping %s: routine already up to date (archived to %s)",
                            path,
                            archive_path,
                        )
                        return

                cursor.execute(
                    "SELECT n.nspname, p.proname, p.prokind, "
                    "pg_get_function_identity_arguments(p.oid) "
                    "FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace "
                    "WHERE p.oid = %s",
                    (oid_row[0],),
                )
                identity_row = cursor.fetchone()
                if identity_row:
                    kind_lookup = {"f": "FUNCTION", "p": "PROCEDURE", "a": "AGGREGATE"}
                    drop_kind = kind_lookup.get(identity_row[2], routine_target.kind)
                    drop_signature_args = identity_row[3] or ""
                    drop_qualified_name = f"{identity_row[0]}.{identity_row[1]}"
                    drop_statement = (
                        f"DROP {drop_kind} {drop_qualified_name}"
                        f"({drop_signature_args})"
                    )
                else:
                    drop_args = (
                        routine_target.argument_signature
                        if routine_target.argument_signature
                        else ""
                    )
                    drop_statement = (
                        f"DROP {routine_target.kind} {qualified_name}"
                        f"({drop_args})"
                    )

    else:
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
        if drop_statement:
            LOGGER.info("Dropping existing routine before recreation: %s", drop_statement)
            cursor.execute(drop_statement)
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
