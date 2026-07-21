{% macro dbt_logging_tf_model_start() %}
INSERT INTO TF2_DBT_DB.DEV_AUDIT.dbt_model_execution (
    invocation_id,
    unique_id,
    execution_id,
    model_name,
    type,
    status,
    started_at
)
VALUES (
    '{{ invocation_id }}',
    '{{ model.unique_id }}',
    '{{ invocation_id }}_{{ model.unique_id }}',
    '{{ model.name }}',
    '{{ resource_type }}',
    'RUNNING',
    CURRENT_TIMESTAMP()
);

{% endmacro %}