"""Author: Diego Tostes

Load static data into the database using the populate scripts.
"""

from __future__ import annotations

import argparse
import logging
from pathlib import Path

from db_config import DatabaseConfig
from sql_runner import execute_sql_files, iter_sql_files


def resolve_populate_dir() -> Path:
    """Return the default directory for populate SQL files."""

    return Path(__file__).resolve().parent.parent / "database" / "populate"


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""

    parser = argparse.ArgumentParser(description="Populate reference data using SQL scripts.")
    parser.add_argument(
        "--directory",
        type=Path,
        default=resolve_populate_dir(),
        help="Directory containing the populate SQL files.",
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
    """Load configuration from JSON or the environment."""

    if config_path is not None:
        return DatabaseConfig.from_json(config_path)
    return DatabaseConfig.from_env()


def main() -> None:
    """Apply populate scripts to the database."""

    args = parse_args()
    logging.basicConfig(level=args.log_level.upper())
    config = load_config(args.config)
    sql_files = list(iter_sql_files(args.directory))
    execute_sql_files(sql_files, config)


if __name__ == "__main__":
    main()
