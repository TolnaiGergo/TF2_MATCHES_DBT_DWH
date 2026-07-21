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

    changed_files = get_changed_files(workdir=SQL_ROOT)
    sql_files = [
        str(REPO_ROOT / f)
        for f in changed_files
        if f.endswith(".sql")
    ]
else:
    sql_files = get_files_from_workdir(workdir=SQL_ROOT, pattern="*.sql")
      
sql_files = create_parameterset_from_files(sql_files, workdir=REPO_ROOT)

SQL_PARSER_PATTERN = re.compile(
    r"CREATE\s+OR\s+REPLACE\s+TEMP\s+VIEW\s+(?:[a-zA-Z0-9_]+\.)*([a-zA-Z0-9_]+)\s+AS\s+SELECT\s+(.*?)\s+FROM\s+(.*)",
    flags=re.IGNORECASE | re.DOTALL,
)

CREATE_TEMP_VIEW_PATTERN = re.compile(
    r"CREATE\s+OR\s+REPLACE\s+TEMP\s+VIEW\s+(?:[a-zA-Z0-9_]+\.)*([a-zA-Z0-9_]+)",
    flags=re.IGNORECASE | re.DOTALL,
)

CLEAN_COLUMNS_ONLY_PATTERN_SELECT_CLAUSE = re.compile(
    r"""
    ^                                         
    \s* 
    (?:                                       
        (?:[a-zA-Z0-9_]+\s*\.\s*)* 
        (?:[a-zA-Z0-9_]+|\*)                  
        (?:\s+AS\s+[a-zA-Z0-9_]+)?            
        \s* 
    )
    (?:                                       
        ,\s* 
        (?:[a-zA-Z0-9_]+\s*\.\s*)* 
        (?:[a-zA-Z0-9_]+|\*)                  
        (?:\s+AS\s+[a-zA-Z0-9_]+)?            
        \s*
    )* 
    $                                         
    """,
    flags=re.IGNORECASE | re.VERBOSE | re.DOTALL
)

def _remove_sql_comments(sql_text: str) -> str:

    no_multi_line = re.sub(r"/\*.*?\*/", "", sql_text, flags=re.DOTALL)
    
    no_single_line = re.sub(r"--.*?(?=\n|$)", "", no_multi_line)
    
    return no_single_line

def _extract_line_number(sql_text: str, match_start: int) -> int:
    """Extract the line number of a match in the SQL text."""
    return sql_text.count("\n", 0, match_start) + 1

def _analyze_sql_query(sql_text: str):
    sql_text_no_comments = _remove_sql_comments(sql_text)
    match = SQL_PARSER_PATTERN.search(sql_text_no_comments)
    if not match:
        return None
        
    view_name = match.group(1)
    select_clause = match.group(2).strip()
    from_clause = match.group(3).strip()
    
    # remove any following clauses (WHERE, GROUP BY, ORDER BY, etc.) keeping only the FROM clause
    from_clause_clean = re.split(r"\b(WHERE|GROUP|ORDER|LIMIT|HAVING)\b", from_clause, flags=re.IGNORECASE)[0].strip().lower()

    # Determine if the view is a single-source read view (1:1 mapping)
    is_single_source = not (
        "join" in from_clause_clean or 
        "," in from_clause_clean
    )
	
    is_simple_from_clause = bool(from_clause_clean == from_clause.strip().lower())
    
    # Determine if the select clause contains only clean column references (no expressions, functions)
    is_clean_columns_only = bool(CLEAN_COLUMNS_ONLY_PATTERN_SELECT_CLAUSE.match(select_clause))
	
    return {
        "view_name": view_name,
        "select_clause": select_clause,
        "from_clause": from_clause_clean,
        "is_single_source": is_single_source,
        "is_clean_columns_only": is_clean_columns_only,
        "is_simple_from_clause": is_simple_from_clause,
    }


# Tests
@pytest.mark.conventions
@pytest.mark.parametrize("sql_path, sql_text", sql_files)
def test_select_wildcard(sql_path: Path, sql_text: str) -> None:
    """Test that all temp view names start with 'temp_'."""
      
    match_iter = list(SELECT_WILDCARD_PATTERN.finditer(sql_text))
    errors = []
    if not match_iter:
        pytest.fail(f"No SELECT * statements found in {sql_path}")

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