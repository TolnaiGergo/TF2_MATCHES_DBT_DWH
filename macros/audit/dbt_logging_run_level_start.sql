{% macro dbt_logging_run_level_start() %}
INSERT INTO TF2_DBT_DB.DEV_AUDIT.dbt_run_execution (
    invocation_id,
    command,
    started_at,
    status
)
VALUES (
    '{{ invocation_id }}',
    '{{ flags.WHICH }}',
    CURRENT_TIMESTAMP(),
    'RUNNING'
);
{% endmacro %}