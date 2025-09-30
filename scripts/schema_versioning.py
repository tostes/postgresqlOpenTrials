"""Author: Diego Tostes

Simple schema version tracking based on SQL file hashes.
"""

from __future__ import annotations

import argparse
import hashlib
import logging
from pathlib import Path
from typing import Dict, Iterable, Tuple

from db_config import DatabaseConfig
from sql_runner import iter_sql_files, get_connection

SCHEMA_VERSION_TABLE = "schema_version"


def parse_args() -> argparse.Namespace:
    """Parse command line arguments for schema tracking."""

    parser = argparse.ArgumentParser(
        description="Track SQL file hashes in the schema_version table."
    )
    parser.add_argument(
        "directories",
        nargs="+",
        type=Path,
        help="One or more directories containing SQL files to track.",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help="Optional JSON file with database credentials.",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        help="Python logging level (default: INFO).",
    )
    parser.add_argument(
        "--record",
        action="store_true",
        help="Persist missing or outdated hashes back to the database.",
    )
    return parser.parse_args()


def load_config(config_path: Path | None) -> DatabaseConfig:
    """Load configuration from file or environment."""

    if config_path is not None:
        return DatabaseConfig.from_json(config_path)
    return DatabaseConfig.from_env()


def calculate_hash(path: Path) -> str:
    """Compute a SHA256 hash for the given file."""

    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(8192), b""):
            digest.update(chunk)
    return digest.hexdigest()


def ensure_table_exists(connection) -> None:
    """Create the schema_version table if it is missing."""

    ddl = f"""
    CREATE TABLE IF NOT EXISTS {SCHEMA_VERSION_TABLE} (
        id SERIAL PRIMARY KEY,
        file_path TEXT NOT NULL UNIQUE,
        file_hash TEXT NOT NULL,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    """
    with connection.cursor() as cursor:
        cursor.execute(ddl)
    connection.commit()


def fetch_existing_hashes(connection) -> Dict[str, str]:
    """Fetch stored hashes from the schema_version table."""

    with connection.cursor() as cursor:
        cursor.execute(
            f"SELECT file_path, file_hash FROM {SCHEMA_VERSION_TABLE}"
        )
        rows = cursor.fetchall()
    return {row[0]: row[1] for row in rows}


def gather_files(directories: Iterable[Path]) -> Dict[str, Path]:
    """Collect SQL files from the provided directories."""

    root = Path(__file__).resolve().parent.parent
    files: Dict[str, Path] = {}
    for directory in directories:
        for sql_file in iter_sql_files(directory):
            relative_path = sql_file.resolve().relative_to(root)
            files[str(relative_path)] = sql_file
    return files


def classify_files(
    files: Dict[str, Path],
    stored_hashes: Dict[str, str],
) -> Tuple[Dict[str, Path], Dict[str, Path], Dict[str, Path]]:
    """Classify files as missing, outdated or up-to-date."""

    missing: Dict[str, Path] = {}
    outdated: Dict[str, Path] = {}
    up_to_date: Dict[str, Path] = {}

    for rel_path, sql_file in files.items():
        file_hash = calculate_hash(sql_file)
        stored_hash = stored_hashes.get(rel_path)
        if stored_hash is None:
            missing[rel_path] = sql_file
        elif stored_hash != file_hash:
            outdated[rel_path] = sql_file
        else:
            up_to_date[rel_path] = sql_file
    return missing, outdated, up_to_date


def record_hashes(connection, files: Dict[str, Path]) -> None:
    """Insert or update file hashes in the schema_version table."""

    with connection.cursor() as cursor:
        for rel_path, sql_file in files.items():
            file_hash = calculate_hash(sql_file)
            cursor.execute(
                f"""
                INSERT INTO {SCHEMA_VERSION_TABLE} (file_path, file_hash)
                VALUES (%s, %s)
                ON CONFLICT (file_path)
                DO UPDATE SET file_hash = EXCLUDED.file_hash, applied_at = NOW()
                """,
                (rel_path, file_hash),
            )
    connection.commit()


def main() -> None:
    """Entry point for the schema versioning helper."""

    args = parse_args()
    logging.basicConfig(level=args.log_level.upper())
    config = load_config(args.config)
    directories = [directory for directory in args.directories]
    files = gather_files(directories)

    with get_connection(config) as connection:
        ensure_table_exists(connection)
        stored_hashes = fetch_existing_hashes(connection)
        missing, outdated, up_to_date = classify_files(files, stored_hashes)

        logging.info("Up-to-date files: %s", len(up_to_date))
        logging.info("Missing files: %s", len(missing))
        logging.info("Outdated files: %s", len(outdated))

        if args.record:
            to_record = {**missing, **outdated}
            if to_record:
                logging.info("Recording %s file hashes in the database.", len(to_record))
                record_hashes(connection, to_record)
            else:
                logging.info("No changes to record.")


if __name__ == "__main__":
    main()
