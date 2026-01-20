{{ config(
    pre_hook="{{ dbt_logging_model_level_start() }}",
    post_hook="{{ dbt_logging_model_level_end() }}"
) }}
with player_snapshot_cte as(
    select
        player_id,
        player_name,
        country,
        lvl,
        valid_to
    from {{ ref('core_player_snapshot')}}
)
select
    player_id as dim_player_sk,
    player_name,
    country,
    lvl,
    CURRENT_TIMESTAMP() as loaded_at
from player_snapshot_cte
where valid_to is null