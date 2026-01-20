{% macro dbt_logging_model_level_start() %}
INSERT INTO TF2_DBT_DB.DEV_AUDIT.dbt_model_execution (
    invocation_id,
    model_name,
    execution_id,
    status,
    started_at
)
VALUES (
    '{{ invocation_id }}',
    '{{ model.name }}',
    '{{ invocation_id }}_{{ model.name }}_{{ run_started_at.timestamp() }}',
    'RUNNING',
    CURRENT_TIMESTAMP()
);
{% endmacro %}