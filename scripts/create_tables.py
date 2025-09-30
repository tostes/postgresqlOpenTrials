"""Author: Diego Tostes

Command line helper to execute all table definition scripts.
"""

from __future__ import annotations

import argparse
import logging
from pathlib import Path

from db_config import DatabaseConfig
from sql_runner import execute_sql_files, iter_sql_files


def resolve_tables_dir() -> Path:
    """Return the default path for table definition files."""

    return Path(__file__).resolve().parent.parent / "database" / "tables"


def parse_args() -> argparse.Namespace:
    """Parse command line arguments for the script."""

    parser = argparse.ArgumentParser(description="Apply table DDL scripts in order.")
    parser.add_argument(
        "--directory",
        type=Path,
        default=resolve_tables_dir(),
        help="Directory containing the table SQL files.",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help="Optional JSON configuration file with database credentials.",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        help="Python logging level (default: INFO).",
    )
    parser.add_argument(
        "--priority-prefix",
        default="vocabulary_",
        help=(
            "Optional filename prefix to prioritize when executing table scripts "
            "(default: vocabulary_)."
        ),
    )
    return parser.parse_args()


def load_config(config_path: Path | None) -> DatabaseConfig:
    """Load the database configuration from file or environment."""

    if config_path is not None:
        return DatabaseConfig.from_json(config_path)
    return DatabaseConfig.from_env()


def main() -> None:
    """Script entry point."""

    args = parse_args()
    logging.basicConfig(level=args.log_level.upper())
    config = load_config(args.config)
    sql_files = list(iter_sql_files(args.directory, args.priority_prefix))
    execute_sql_files(sql_files, config)


if __name__ == "__main__":
    main()
