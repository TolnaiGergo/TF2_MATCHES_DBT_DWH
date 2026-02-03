{% macro dbt_logging_tf_model_start() %}
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
    '{{ invocation_id }}_{{ model.unique_id }}',
    'RUNNING',
    CURRENT_TIMESTAMP()
);

{% endmacro %}