{% test is_between(model, column_name, lower, upper)%}
with failed_cte as (
    select {{ column_name }}
    from {{ model }}
    where NOT {{column_name}} between {{ lower }} and {{ upper }}
)
select *
from failed_cte
{% endtest %}