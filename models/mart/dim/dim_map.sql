with map_snapshot_cte as(
    select
        map_index,
        map_name,
        game_mode,
        valid_to,
    from {{ ref('core_map_snapshot')}}
)
select
    map_index,
    map_name,
    game_mode
from map_snapshot_cte
where valid_to is null