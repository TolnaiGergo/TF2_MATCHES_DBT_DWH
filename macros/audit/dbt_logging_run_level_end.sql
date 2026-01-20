{% macro dbt_logging_run_level_end() %}

{% set failed = true %}
{% set failed_set = results
    | selectattr("status", "in", ["error", "fail"])
    | list
%}

{# logging #}
{% for r in failed_set %}
  {{ log("FAILED model = " ~ r.node.name, info=True) }}
{% endfor %}


{% if failed_set | length == 0  %}
    {% set failed = false %}
{% endif %}

{% for _failed in failed_set %}
    {% do dbt_logging_model_level_failed('tester_1') %} 
    {% if _failed.node.resource_type == 'model' %}
        {{ dbt_logging_model_level_failed(_failed.node.name) }} {# _failed.node.name #}
    {% endif %}
{% endfor %}

UPDATE TF2_DBT_DB.DEV_AUDIT.dbt_run_execution
SET
    finished_at = CURRENT_TIMESTAMP(),
    duration_sec = DATEDIFF(
        second,
        started_at,
        CURRENT_TIMESTAMP()
    ),
    status = '{{ "FAILED" if failed else "SUCCESS" }}'
WHERE invocation_id = '{{ invocation_id }}';

{% endmacro %}