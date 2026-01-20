{{
    config(
        materialized='incremental',
        unique_key = 'match_id',
        incremental_strategy= 'append'
    )
}}

with core_match_cte as (
    select
    -- business key
        match_id,
    -- foreign s-keys
        CASE 
            WHEN connection_time is not null THEN {{ timestamp_to_sk('connection_time') }}
            WHEN join_time is not null THEN {{ timestamp_to_sk('join_time') }}
            WHEN match_creation_time is not null THEN {{ timestamp_to_sk('match_creation_time') }}
            ELSE null
        END 
        AS dim_date_sk,
        CASE
            WHEN map.map_index is null THEN 0
            ELSE match.map_index
        END
        AS dim_map_sk,
        CASE
            WHEN player.player_id is null THEN 0
            ELSE match.player_id
        END
        AS dim_player_sk,
    -- foreign business keys
        map_index,
        player_id,
        classes_played,
    -- date of match
        CASE 
            WHEN connection_time is not null THEN CAST(connection_time AS DATE)
            WHEN join_time is not null THEN CAST(join_time AS DATE)
            WHEN match_creation_time is not null THEN CAST(match_creation_time AS DATE)
            ELSE null
        END 
        AS match_date,
    -- timestamps
        match_creation_time,
        connection_time,
        join_time,
        joined_after_match_start,
        match_end_time,
        time_left_match,
    -- time-based metrics
        time_in_queue,
        match_duration,
    -- match descriptive data
        type,
        red_team_final_score,
        blu_team_final_score,
        winning_team,
        win_reason,
        leave_reason,
        reached_conclusion,
    -- player metrics
        result_team,
        result_score,
        result_rank,
        kills,
        deaths,
        damage,
        healing,
        support
    from {{ ref('match')}} as match
    left join {{ ref('core_map_snapshot') }} as map 
        using (map_index) 
    left join {{ ref('core_player_snapshot') }} as player 
        using (player_id)
)
select
    -- business key
        match_id,
    -- foreign keys
        cm.dim_date_sk,
        cm.dim_map_sk,
        cm.dim_player_sk,
        cm.classes_played,
    -- date of match
        match_date,
    -- timestamps
        match_creation_time,
        connection_time,
        join_time,
        joined_after_match_start,
        match_end_time,
        time_left_match,
    -- time-based metrics
        time_in_queue,
        match_duration,
    -- match descriptive data
        type,
        red_team_final_score,
        blu_team_final_score,
        winning_team,
        win_reason,
        leave_reason,
        reached_conclusion,
    -- player metrics
        result_team,
        result_score,
        result_rank,
        kills,
        deaths,
        damage,
        healing,
        support
from core_match_cte as cm
inner join {{ ref('dim_date')}} as dd
    using (dim_date_sk)
inner join {{ ref('dim_map') }} as dm
    using (dim_map_sk)
inner join {{ ref('dim_player') }} as dp
    using (dim_player_sk)
inner join {{ ref('dim_class_set') }} as dcs
    using (classes_played)
{% if is_incremental() %}
    where cm.match_id not in (select match_id from {{ this }})
{% endif %}