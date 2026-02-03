{% macro dbt_logging_run_level_start() %}
INSERT INTO TF2_DBT_DB.DEV_AUDIT.dbt_run_execution (
    invocation_id,
    command,
    profile_name,
    schema_name,
    user_name,
    started_at,
    status
)
VALUES (
    '{{ invocation_id }}',
    '{{ invocation_args_dict["invocation_command"] }}',
    '{{ target.profile_name }}',
    '{{ target.name }}',
    '{{ target.user }}',
    CURRENT_TIMESTAMP(),
    'RUNNING'
);

commit;
{% endmacro %}