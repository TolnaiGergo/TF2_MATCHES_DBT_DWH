"""Shared pytest fixtures/constants for the test suite.

Centralizes repo-relative path constants so individual test files don't each
recompute `Path(__file__).resolve().parents[N]` (which is fragile - it breaks
silently if a test file is moved to a different nesting depth).
"""

from __future__ import annotations

from pathlib import Path
import re
import os
import subprocess
import pytest


REPO_ROOT = Path(__file__).resolve().parents[1]
SQL_ROOT = REPO_ROOT / "models"
SELECTED_SQL_FILES: list[str] = []

def get_files_from_workdir(workdir: Path = SQL_ROOT, pattern: str = "*.sql", regex: re.Pattern | None = None) -> list[Path]:
    """
    Retrieve a list of files from the specified directory that match the given pattern or regex.

    Args:
        workdir (Path): The directory to search for files. Defaults to SQL_ROOT.
        pattern (str): The glob pattern to match files. Defaults to "*.sql".
        regex (re.Pattern | None): An optional regex pattern to filter files by their content.
        If regex is provided, only files whose content matches the regex are returned.
    Returns:
        list[Path]: A list of files matching the pattern or regex.

    Raises:
        ValueError: If the workdir does not exist.
    """
    if regex:
        return [p for p in workdir.rglob(str(pattern)) if regex.search(p.read_text(encoding="utf-8"))]
    else:
        return list(workdir.rglob(pattern))

def pytest_sessionstart(session) -> None:
    if SELECTED_SQL_FILES:
        print("Selected SQL files for pytest:")
        for file_path in SELECTED_SQL_FILES:
            print(f"- {file_path}")

def get_changed_files(workdir: Path = SQL_ROOT) -> list[str]:
    """
    Retrieve a list of changed SQL files in the specified directory using git.
    This function checks for changed files in the current git repository.
    Only used by GitHub Actions to limit the test scope to changed files.

    Args:
        workdir (Path): The directory to search for changed files. Defaults to SQL_ROOT.

    Returns:
        list[str]: A list of changed SQL files relative to the repository root.
    """
    changed_files = set()
    try:
        target_branch = os.getenv("GITHUB_BASE_REF", "dev")
        diff_cmd = ["git", "diff", "--name-only", f"origin/{target_branch}...HEAD"]
        diff_output = subprocess.check_output(diff_cmd, text=True)
        changed_files.update(diff_output.splitlines())

        return list(changed_files)
    except Exception as e:
        print(f"Git query error: {e}")
        return []
    
def create_parameterset_from_files(files: list[str], workdir: Path = REPO_ROOT) -> list[pytest.ParameterSet]:
    """
    Creates a list of pytest.ParameterSet objects from a list of file paths.
    Each ParameterSet contains the Path object and the file's text content.

    Args:
        files (list[str]): A list of file paths to create ParameterSet objects from.
        workdir (Path): The base directory to which the file paths are relative. Defaults to REPO_ROOT.
    
    Returns:
        list[pytest.ParameterSet]: A list of pytest.ParameterSet objects, each containing the Path and text content of a file.
    """
    view_files: list[pytest.ParameterSet] = []
    for file in files:
        if not Path(file).exists():
            raise FileNotFoundError(f"File not found: {file}")
        else:
            view_files.append(
                pytest.param(
                    Path(file),
                    Path(file).read_text(encoding="utf-8"),
                    id=str(Path(file).relative_to(workdir)),
                )
            )
    return view_files

def remove_sql_comments(sql_text: str) -> str:
    """
    Remove both single-line and multi-line comments from the SQL text.

    Args:
        sql_text (str): The SQL text from which to remove comments.

    Returns:
        str: The SQL text with comments removed.
    """
    no_multi_line = re.sub(r"/\*.*?\*/", "", sql_text, flags=re.DOTALL)
    no_single_line = re.sub(r"--.*?(?=\n|$)", "", no_multi_line)
    
    return no_single_line

def extract_line_number(sql_text: str, match_start: int) -> int:
    """
    Extract the line number of a match in the SQL text.

    Args:
        sql_text (str): The SQL text in which to find the line number.
        match_start (int): The start index of the match in the SQL text.

    Returns:
        int: The line number of the match in the SQL text.
    """
    return sql_text.count("\n", 0, match_start) + 1
