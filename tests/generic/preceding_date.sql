{% test preceding_date(model, preceding_date_col, following_date_col ) %}

with failed_cte as (
    select {{ preceding_date_col }}, {{ following_date_col}}
    from {{ model }}
    where {{ preceding_date_col }} > {{ following_date_col }}    
)

{% endtest %}