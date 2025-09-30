"""Author: Diego Tostes

Apply stored procedure definitions to the database.
"""

from __future__ import annotations

import argparse
import logging
from pathlib import Path

from db_config import DatabaseConfig
from sql_runner import execute_sql_files, iter_sql_files


def resolve_procedures_dir() -> Path:
    """Return the default directory for procedure SQL files."""

    return Path(__file__).resolve().parent.parent / "database" / "procedures"


def parse_args() -> argparse.Namespace:
    """Parse CLI arguments."""

    parser = argparse.ArgumentParser(description="Apply procedure SQL scripts in order.")
    parser.add_argument(
        "--directory",
        type=Path,
        default=resolve_procedures_dir(),
        help="Directory containing the procedure SQL files.",
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
    return parser.parse_args()


def load_config(config_path: Path | None) -> DatabaseConfig:
    """Load database configuration from file or environment variables."""

    if config_path is not None:
        return DatabaseConfig.from_json(config_path)
    return DatabaseConfig.from_env()


def main() -> None:
    """Execute the stored procedures."""

    args = parse_args()
    logging.basicConfig(level=args.log_level.upper())
    config = load_config(args.config)
    sql_files = list(iter_sql_files(args.directory))
    execute_sql_files(sql_files, config)


if __name__ == "__main__":
    main()
