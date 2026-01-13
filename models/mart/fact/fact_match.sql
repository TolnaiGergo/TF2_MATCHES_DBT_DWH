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
    -- foreign keys
        map_index,
        player_id,
        classes_played,
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
        support,
    from {{ ref('match')}}
)
select
    core_match_cte.*
from core_match_cte
inner join {{ ref('dim_map') }} as dm
    using (map_index)
inner join {{ ref('dim_player') }} as dp
    using (player_id)
inner join {{ ref('dim_class_set') }} as dcs
    using (classes_played)
{% if is_incremental() %}
    where core_match_cte.match_id not in (select match_id from {{ this }})
{% endif %}