{{
    config(
        materialized='incremental',
        unique_key = 'match_id',
        incremental_strategy= 'append'
    )
}}

with v_stg_match_cte as (
    select
        -- business key
       match_id,
       -- foreign key
       map_index,
       player_id,
       classes_played,
       type,
       match_creation_time,
       connection_time,
       join_time,
       joined_after_match_start,
       time_in_queue,
       match_end_time,
       time_left_match,
       match_duration,
       red_team_final_score,
       blu_team_final_score,
       winning_team,
       win_reason,
       result_team,
       result_score,
       result_rank,
       kills,
       deaths,
       damage,
       healing,
       support,
       leave_reason,
       reached_conclusion,
       -- metadata
       _stg_file_name,
       _stg_file_load_ts,
       _stg_copy_ts
)
select
    v_stg.*,
    -- additional metadata
    CURRENT_TIMESTAMP() as _core_load_ts 
from v_stg_match_cte as v_stg
where match_id is not null
{% if is_incremental() %}
    and v_stg._stg_file_load_ts > ( select max(_stg_file_load_ts) from {{this}})
    and v_stg.match_id not in (select match_id from {{ this }})
{% endif %}