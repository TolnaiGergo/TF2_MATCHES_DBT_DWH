with match_source AS
(
    SELECT
        match_id::number as match_id,
        type,
        TO_TIMESTAMP(match_creation_time, 'YYYY.MM.DD HH24:MI') as match_creation_time,
        TO_TIMESTAMP(connection_time, 'YYYY.MM.DD HH24:MI')  as connection_time,
        TO_TIMESTAMP(join_time, 'YYYY.MM.DD HH24:MI') as join_time,
        joined_after_match_start::boolean as joined_after_match_start,
        time_in_queue::number as time_in_queue,
        TO_TIMESTAMP(match_end_time, 'YYYY.MM.DD HH24:MI') as match_end_time,
        TO_TIMESTAMP(time_left_match, 'YYYY.MM.DD HH24:MI') as time_left_match,
        map_index::number as map_index,
        match_duration::number as match_duration,
        red_team_final_score::number as red_team_final_score,
        blu_team_final_score::number as blu_team_final_score,
        winning_team,
        win_reason,
        team_at_join,
        result_team,
        result_score::number as result_score,
        result_rank::number as result_rank,
        classes_played::number as classes_played,
        kills::number as kills,
        deaths::number as deaths,
        damage::number as damage,
        healing::number as healing,
        support::number as support,
        leave_reason,
        reached_conclusion::boolean as reached_conclusion,
        player_id::number as player_id,
        _stg_file_name,
        _stg_file_load_ts,
        _stg_copy_ts
    FROM {{source('source_data','STG_MATCH')}} 
)
SELECT
*
FROM match_source
