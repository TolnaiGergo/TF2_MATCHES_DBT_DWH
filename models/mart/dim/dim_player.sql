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
    player_id,
    player_name,
    country,
    lvl
from player_snapshot_cte
where valid_to is null