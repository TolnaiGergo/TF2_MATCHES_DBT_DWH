{{ config(
    materialized="table",

    pre_hook="{{ dbt_logging_model_level_start() }}",
    post_hook="{{ dbt_logging_model_level_end() }}",
    
) }}


with test_cte as (
    select
        column1 as id,
        column2 as user_name,
        column3 as loaded_at
    from values
        (1, 'User_1', current_timestamp()),
        (2, 'User_2', current_timestamp()),
        (3, 'User_3', current_timestamp())
)
select * from test_cte