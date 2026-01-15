{% macro timestamp_to_sk(timestamp_value) %}
    TO_NUMBER(TO_CHAR( {{ timestamp_value }} ,'YYYYMMDD'))
{% endmacro %}