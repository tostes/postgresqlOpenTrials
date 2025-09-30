"""Author: Diego Tostes

Database configuration utilities.
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict


@dataclass
class DatabaseConfig:
    """Simple container for PostgreSQL connection parameters."""

    host: str = "localhost"
    port: int = 5432
    user: str = "postgres"
    password: str = "postgres"
    database: str = "postgres"

    @classmethod
    def from_env(cls) -> "DatabaseConfig":
        """Build a configuration instance using environment variables if present."""

        return cls(
            host=os.getenv("DB_HOST", cls.host),
            port=int(os.getenv("DB_PORT", cls.port)),
            user=os.getenv("DB_USER", cls.user),
            password=os.getenv("DB_PASSWORD", cls.password),
            database=os.getenv("DB_NAME", cls.database),
        )

    @classmethod
    def from_json(cls, path: Path) -> "DatabaseConfig":
        """Load configuration values from a JSON file."""

        with path.open("r", encoding="utf-8") as handle:
            data: Dict[str, Any] = json.load(handle)
        return cls(
            host=data.get("host", cls.host),
            port=int(data.get("port", cls.port)),
            user=data.get("user", cls.user),
            password=data.get("password", cls.password),
            database=data.get("database", cls.database),
        )

    def as_dict(self) -> Dict[str, Any]:
        """Return a dictionary ready to be expanded as psycopg2 connection kwargs."""

        return {
            "host": self.host,
            "port": self.port,
            "user": self.user,
            "password": self.password,
            "dbname": self.database,
        }


DEFAULT_CONFIG = DatabaseConfig()
