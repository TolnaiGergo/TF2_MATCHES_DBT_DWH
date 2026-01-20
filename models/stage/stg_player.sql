with player_source AS
(
    SELECT
        player_id,
        player_name,
        country,
        lvl,
        _STG_COPY_TS,
        _STG_FILE_LOAD_TS,
        _STG_FILE_NAME
    FROM {{source('source_data','STG_PLAYER')}}

)
SELECT
    -- business key
    player_id::number as player_id,
    -- payload
    player_name::varchar as player_name,
    country::varchar as country,
    lvl::number as lvl,
    -- metadata
    _STG_COPY_TS::timestamp as _STG_COPY_TS,
    _STG_FILE_LOAD_TS::timestamp as _STG_FILE_LOAD_TS,
    _STG_FILE_NAME::varchar as _STG_FILE_NAME
FROM player_source