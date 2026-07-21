{% macro generate_audit_metadata() %}
    '{{ invocation_id }}'::string as dbt_invocation_id,
    '{{ invocation_id }}_{{ model.unique_id }}'::string as dbt_execution_id,
    CURRENT_TIMESTAMP() as dbt_loaded_at,
{% endmacro %}