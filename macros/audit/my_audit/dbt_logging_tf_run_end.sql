{% macro dbt_logging_tf_run_end() %}


{# Determine overall status #}
{% set failed_count = results
    | selectattr("status", "in", ["error", "fail"])
    | list
    | length %}
{% set STATUS = 'FAIL' if failed_count > 0 else 'SUCCESS' %}

{# update rows for each model in model table #}
{% for r in results %}
    {% if r.node.resource_type in ['model', 'snapshot', 'seed'] %}
        {% set rows = 'null' %}
        {% if r.node.config.materialized in ['table', 'incremental'] or r.node.resource_type == 'snapshot' %}
            {% set rows = "(SELECT COUNT(*) FROM " ~ r.node.relation_name ~ " WHERE dbt_invocation_id = '" ~ invocation_id ~ "')" %}
        {% elif r.node.resource_type == 'seed' and r.adapter_response.rows_affected is defined %}
            {% set rows = r.adapter_response.rows_affected %}
        {% endif %}

        UPDATE TF2_DBT_DB.DEV_AUDIT.dbt_model_execution
        -- set basic audit fields
        SET
            status = '{{ r.status | upper }}',
            finished_at = CURRENT_TIMESTAMP(),
            duration_sec = {{r.execution_time | default(0)}},
        -- specific fields
            rows_inserted = {{ rows }}
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