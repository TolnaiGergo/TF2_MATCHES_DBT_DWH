{% macro dbt_logging_model_level_failed(model_name) %}
UPDATE TF2_DBT_DB.DEV_AUDIT.dbt_model_execution
SET
    status = 'FAILED',
    finished_at = CURRENT_TIMESTAMP(),
    duration_sec = DATEDIFF(
        second,
        started_at,
        CURRENT_TIMESTAMP()
    )
WHERE invocation_id = '{{ invocation_id }}'
  AND model_name = '{{ model_name }}'
  AND status = 'RUNNING';
{% endmacro %}