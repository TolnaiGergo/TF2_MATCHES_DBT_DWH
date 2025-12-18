with stg_match_cte as(
    select
        match_id,
        type,
        match_creation_time,
        connection_time,
        join_time,
        joined_after_match_start,
        time_in_queue,
        match_end_time,
        time_left_match,
        map_index,
        match_duration,
        red_team_final_score,
        blu_team_final_score,
        winning_team,
        win_reason,
        team_at_join,
        result_team,
        result_score,
        result_rank,
        classes_played,
        kills,
        deaths,
        damage,
        healing,
        support,
        leave_reason,
        reached_conclusion,
        player_id,
        _stg_file_name,
        _stg_file_load_ts,
        _stg_copy_ts
    from {{ ref('stg_match')}}
),
v_stg_match_cte as(
    select
       -- business key
       match_id,
       -- foreign key
       map_index,
       player_id,
       FLOOR(classes_played/2) as classes_played,
       -- payload
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
       CASE winning_team
            WHEN '2' THEN 'RED'
            WHEN '3' THEN 'BLU'
            ELSE 'DRAW'
        END AS winning_team,
       CASE win_reason
          WHEN '0' THEN '(No result / unfinished match)'
          WHEN '1' THEN 'captured all control points'
          WHEN '2' THEN 'eliminated all opponents during sudden death'
          WHEN '3' THEN 'captured the enemy intelligence X times'
          WHEN '4' THEN 'defended until time ran out'
          WHEN '5' THEN 'everyone lost'
          WHEN '6' THEN 'had more points when the time limit was reached'
          WHEN '7' THEN 'had more points when the win limit was reached'
          WHEN '8' THEN 'was ahead by the required difference to win'
          WHEN '9' THEN 'captured the enemy reactor core'
          WHEN '10' THEN 'destroyed robots and collected power cores'
          WHEN '11' THEN 'defended their reactor core until it returned'
          WHEN '12' THEN 'collected enough points'
          WHEN '13' THEN 'scored 3 times'
          WHEN '14' THEN 'won two stages in a row'
          WHEN '15' THEN 'won one stage'
          WHEN '16' THEN 'won one stage after the opponents victory'
        END AS win_reason,
       CASE team_at_join
            WHEN '0' THEN 'red'
            WHEN '1' THEN 'blu'
            ELSE 'none'
        END AS team_at_join,
       CASE result_team
            WHEN '2' THEN 'red'
            WHEN '3' THEN 'blu'
            ELSE 'none'
        END AS result_team,
       result_score,
       result_rank,
       kills,
       deaths,
       damage,
       healing,
       support,
       CASE leave_reason
            WHEN '0' THEN 'match completed'
            WHEN '1' THEN 'connection error'
            WHEN '4' THEN 'ended by time limit'
            WHEN '6' THEN 'quit manually'
            ELSE 'unknown'
        END AS leave_reason,
       reached_conclusion,
       -- hash diff
       {{ hash_cols('stg_match',['match_id','map_index','player_id','classes_played','_STG_FILE_NAME','_STG_FILE_LOAD_TS','_STG_COPY_TS'], true, true) }} as hash_diff,
       --metadata
       _stg_file_name,
       _stg_file_load_ts,
       _stg_copy_ts
    from stg_match_cte   
)
select
    *
from v_stg_match_cte