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

sql_files = get_files_from_workdir(workdir=SQL_ROOT, pattern="*.sql")
      
sql_file_paths = sql_files
SELECTED_SQL_FILES.extend(sql_file_paths)
sql_files = create_parameterset_from_files(sql_file_paths, workdir=REPO_ROOT)

@pytest.mark.pipelines
@pytest.mark.parametrize("sql_path, sql_text", sql_files)
def test_cte_prefix(sql_path: Path, sql_text: str) -> None:
    """Test that all CTE names start with 'cte_'."""
      
    match_iter = list(CTE_PREFIX_PATTERN.finditer(sql_text))
    errors = []
    for match in match_iter:
        view_name = match.group(1)
        if not view_name.startswith("cte_"):
            line_number = extract_line_number(sql_text, match.start())
            errors.append(f"Line {line_number}: CTE '{view_name}' does not start with 'cte_'")
    if errors:
        formatted_errors = "\n - ".join(errors)
        pytest.fail(f"{formatted_errors}")