{{ config(
    pre_hook="{{ dbt_logging_model_level_start() }}",
    post_hook="{{ dbt_logging_model_level_end() }}"
) }}


with test_cte as (
    select
        column1 as id,
        column2 as name,
        column3 as loaded_at
    from values
        (1, 'Test User 1', current_timestamp()),
        (2, 'Test User 2', current_timestamp()),
        (3, 'Test User 3', current_timestamp())
)
select * from test_cte