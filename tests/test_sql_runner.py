from __future__ import annotations

from pathlib import Path
from typing import Iterable
from unittest.mock import MagicMock

import sys

sys.path.append(str(Path(__file__).resolve().parents[1]))
sys.path.append(str(Path(__file__).resolve().parents[1] / "scripts"))

psycopg2_mock = MagicMock()
extensions_mock = MagicMock()
extensions_mock.connection = MagicMock()
psycopg2_mock.extensions = extensions_mock
sys.modules.setdefault("psycopg2", psycopg2_mock)
sys.modules.setdefault("psycopg2.extensions", extensions_mock)

import pytest

from scripts import sql_runner


def _make_cursor(mock: MagicMock) -> MagicMock:
    context = MagicMock()
    context.__enter__.return_value = mock
    context.__exit__.return_value = False
    return context


def _build_connection(cursors: Iterable[MagicMock]) -> MagicMock:
    connection = MagicMock()
    context_managers = [_make_cursor(cursor) for cursor in cursors]
    connection.cursor.side_effect = context_managers
    return connection


def _routine_sql(body: str = "RETURN a;") -> str:
    return (
        "CREATE OR REPLACE FUNCTION public.test_func(a integer)\n"
        "RETURNS integer\n"
        "LANGUAGE plpgsql\n"
        "AS $$\n"
        f"BEGIN\n    {body}\nEND;\n"
        "$$;\n"
    )


def test_execute_sql_file_creates_routine_when_absent(tmp_path: Path) -> None:
    sql_path = tmp_path / "routine.sql"
    sql_path.write_text(_routine_sql(), encoding="utf-8")

    check_cursor = MagicMock()
    check_cursor.fetchone.return_value = (None,)
    check_cursor.execute.reset_mock()
    exec_cursor = MagicMock()

    connection = _build_connection([check_cursor, exec_cursor])

    sql_runner.execute_sql_file(sql_path, connection)

    check_cursor.execute.assert_called_once_with(
        "SELECT to_regprocedure(%s)", ("public.test_func(integer)",)
    )
    exec_cursor.execute.assert_called_once_with(sql_path.read_text(encoding="utf-8"))
    connection.commit.assert_called_once()


def test_execute_sql_file_skips_and_archives_when_definition_matches(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    sql_path = tmp_path / "routine.sql"
    sql_path.write_text(_routine_sql(), encoding="utf-8")

    archive_dir = tmp_path / "archive"
    monkeypatch.setattr(sql_runner, "PROCEDURE_ARCHIVE_DIR", archive_dir)

    check_cursor = MagicMock()
    check_cursor.fetchone.side_effect = [
        (12345,),
        (_routine_sql(),),
    ]

    connection = _build_connection([check_cursor])

    sql_runner.execute_sql_file(sql_path, connection)

    assert not sql_path.exists()
    archived_path = archive_dir / "routine.sql"
    assert archived_path.exists()
    assert archived_path.read_text(encoding="utf-8") == _routine_sql()
    connection.commit.assert_not_called()
    assert check_cursor.execute.call_args_list == [
        (("SELECT to_regprocedure(%s)", ("public.test_func(integer)",)),),
        (("SELECT pg_get_functiondef(to_regprocedure(%s))", ("public.test_func(integer)",)),),
    ]


def test_execute_sql_file_replaces_when_definition_differs(tmp_path: Path) -> None:
    sql_path = tmp_path / "routine.sql"
    sql_path.write_text(_routine_sql("RETURN a + 1;"), encoding="utf-8")

    existing_definition = _routine_sql("RETURN a; ")

    check_cursor = MagicMock()
    check_cursor.fetchone.side_effect = [
        (12345,),
        (existing_definition,),
        ("public", "test_func", "f", "integer"),
    ]

    exec_cursor = MagicMock()

    connection = _build_connection([check_cursor, exec_cursor])

    sql_runner.execute_sql_file(sql_path, connection)

    exec_cursor.execute.assert_any_call("DROP FUNCTION public.test_func(integer)")
    exec_cursor.execute.assert_any_call(sql_path.read_text(encoding="utf-8"))
    connection.commit.assert_called_once()
    assert check_cursor.execute.call_args_list == [
        (("SELECT to_regprocedure(%s)", ("public.test_func(integer)",)),),
        (("SELECT pg_get_functiondef(to_regprocedure(%s))", ("public.test_func(integer)",)),),
        (
            (
                "SELECT n.nspname, p.proname, p.prokind, "
                "pg_get_function_identity_arguments(p.oid) "
                "FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace "
                "WHERE p.oid = to_regprocedure(%s)",
                ("public.test_func(integer)",),
            ),
        ),
    ]
