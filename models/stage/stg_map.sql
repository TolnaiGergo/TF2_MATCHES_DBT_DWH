with map_source as
(
    SELECT
        map_index,
        map_name,
        game_mode,
        _stg_file_name,
        _stg_file_load_ts,
        _stg_copy_ts
    FROM {{source('source_data','STG_MAP')}}
)
SELECT
    -- business key
    map_index::number as map_index,
    -- payload
    map_name::varchar as map_name,
    game_mode::varchar as game_mode,

    -- metadata
    _stg_file_name::varchar as _stg_file_name,
    _stg_file_load_ts::timestamp as _stg_file_load_ts,
    _stg_copy_ts::timestamp as _stg_copy_ts
FROM map_source