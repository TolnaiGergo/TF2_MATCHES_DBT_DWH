{% macro dbt_logging_model_level_end() %}
UPDATE TF2_DBT_DB.DEV_AUDIT.dbt_model_execution
SET
    status = 'SUCCESS',
    finished_at = CURRENT_TIMESTAMP(),
    duration_sec = DATEDIFF(
        second,
        started_at,
        CURRENT_TIMESTAMP()
    ),
    rows_inserted = (
        SELECT COUNT(*)
        FROM {{ this }}
        WHERE DATE(loaded_at) = CURRENT_DATE
    )
WHERE invocation_id = '{{ invocation_id }}'
  AND model_name = '{{ model.name }}'
  AND status = 'RUNNING';
{% endmacro %}