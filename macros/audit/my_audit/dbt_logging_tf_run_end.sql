{% macro dbt_logging_tf_run_end() %}


{# Determine overall status #}
{% set failed_count = results
    | selectattr("status", "in", ["error", "fail"])
    | list
    | length %}
{% set STATUS = 'FAIL' if failed_count > 0 else 'SUCCESS' %}

{# update rows for each model in model table #}
{% for r in results %}
    {% if r.node.resource_type in ['model', 'test', 'seed', 'snapshot'] %}
        -- look for resource specific fields if available
        {% if r.adapter_response is defined and r.adapter_response.rows_affected is defined %}
            {% set rows = r.adapter_response.rows_affected %}
        {% else %}
            {% set rows = none %}
        {% endif %}

        UPDATE TF2_DBT_DB.DEV_AUDIT.dbt_model_execution
        -- set basic audit fields
        SET
            status = '{{ r.status | upper }}',
            finished_at = CURRENT_TIMESTAMP(),
            duration_sec = {{r.execution_time | default(0)}},
            model_name = '{{ r.node.name }}',
            type = '{{ r.node.resource_type }}',
            execution_id = '{{ invocation_id }}_{{ r.node.unique_id }}',
        -- specific fields
            rows_inserted = {{ rows if rows is not none else 'null' }}
        -- identify record to update
        WHERE execution_id = '{{ invocation_id }}_{{ r.node.unique_id }}'
          AND status = 'RUNNING';
    {% endif %}
{% endfor %}

{# update row in run table #}
UPDATE TF2_DBT_DB.DEV_AUDIT.dbt_run_execution
SET
    finished_at = CURRENT_TIMESTAMP(),
    duration_sec = DATEDIFF(
        second,
        started_at,
        CURRENT_TIMESTAMP()
    ),
    status = '{{ STATUS }}'
WHERE invocation_id = '{{ invocation_id }}';

{% endmacro %}