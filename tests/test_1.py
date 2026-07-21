"""
Test to see if all files have select * wildcards.
"""

from __future__ import annotations
from pathlib import Path
import os
import pytest
import re

# PoC for centralizing repo-relative path constants
from conftest import (
    REPO_ROOT,
    SQL_ROOT,
    get_changed_files,
    get_files_from_workdir,
    create_parameterset_from_files,
    extract_line_number,
    remove_sql_comments,
    SELECTED_SQL_FILES,
    #CLEAN_COLUMNS_ONLY_PATTERN_SELECT_CLAUSE,
)

#REGEX
SELECT_WILDCARD_PATTERN = re.compile(
    r"(?i)\bselect\s*\*\s*from\s+[a-zA-Z0-9_]+\b",
    flags=re.IGNORECASE | re.DOTALL,
)

CTE_PREFIX_PATTERN = re.compile(
    r"with\s+([a-zA-Z0-9_]+)\s+as|,\s+([a-zA-Z0-9_]+)\s+as",
    flags=re.IGNORECASE | re.DOTALL,
)

is_pull_request = os.getenv("GITHUB_EVENT_NAME") == "pull_request"
if os.getenv("GITHUB_ACTIONS") == "true" and is_pull_request:
    print("Running tests on changed files only (pull request context detected).")
    changed_files = get_changed_files(workdir=SQL_ROOT)
    sql_files = [
        str(REPO_ROOT / f)
        for f in changed_files
        if f.endswith(".sql")
    ]
else:
    sql_files = get_files_from_workdir(workdir=SQL_ROOT, pattern="*.sql")
      
sql_file_paths = sql_files
SELECTED_SQL_FILES.extend(sql_file_paths)
sql_files = create_parameterset_from_files(sql_file_paths, workdir=REPO_ROOT)

# Tests
@pytest.mark.conventions
@pytest.mark.parametrize("sql_path, sql_text", sql_files)
def test_select_wildcard(sql_path: Path, sql_text: str) -> None:
    """Test that all files have SELECT * statements."""
      
    match_iter = list(SELECT_WILDCARD_PATTERN.finditer(sql_text))
    errors = []
    if not match_iter:
        pytest.fail(f"No SELECT * statements found in {sql_path}")

