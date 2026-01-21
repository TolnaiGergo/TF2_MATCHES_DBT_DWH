{{ config(
    materialized="incremental",
    primary_key="id",
    unique_key = 'match_id',
    incremental_strategy= 'append',

    pre_hook="{{ dbt_logging_model_level_start() }}",
    post_hook="{{ dbt_logging_model_level_end() }}",
    

) }}


with initial_cte as (
    select
        column1 as id,
        column2 as user_name,
        CAST(column3 as NUMBER) as age,
        column4 as loaded_at
    from values
        (1, 'User_1','25', current_timestamp()),
        (2, 'User_2', '26', current_timestamp()),
        (3, 'User_3', '27', current_timestamp())
),
additional_cte as (
    select
        column1 as id,
        column2 as user_name,
        CAST(column3 as NUMBER) as age,
        column4 as loaded_at
    from values
        (4, 'User_4','24', current_timestamp()),
        (5, 'User_5','oops', current_timestamp())
)
select * from initial_cte
{% if is_incremental() %}

union

select * from additional_cte

{% endif %}