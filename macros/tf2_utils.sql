{% macro hash_cols(model,col_list, is_exclude, is_hashdiff) %}
    {% if is_exclude %}
        {% set relation = ref(model_name) %}
        {% set relation_cols = adapter.get_columns_in_relation(relation) %}
        {% set result_cols = [] %}
            {% for col in relation_cols %}
                {% if col.name not in col_list %}
                    {% do result_cols.append(col.name) %}
                {% endif %}
            {% endfor %}
    {% else %}
        {% set result_cols = col_list %}
    {% endif %}

    {% if is_hashdiff %}
        CAST(MD5_BINARY(CONCAT_WS('||',
            {% for col in result_cols %}
                IFNULL(NULLIF(UPPER(TRIM(CAST({{ col }} AS VARCHAR))), ''), '^^'){% if not loop.last %}, {% endif %}
            {% endfor %}
            )) as BINARY(16)
        )
    {% else %}
        CAST(MD5_BINARY(NULLIF(CONCAT_WS('||',
            {% for col in result_cols %}
                IFNULL(NULLIF(UPPER(TRIM(CAST({{ col }} AS VARCHAR))), ''), '^^'){% if not loop.last %}, {% endif %}
            {% endfor %}
            ), '^^||^^||^^')) as BINARY(16)
        )
    {% endif %} 
{% endmacro%}

{% set relation = ref(model_name) %}
    {% set cols = adapter.get_columns_in_relation(relation) %}