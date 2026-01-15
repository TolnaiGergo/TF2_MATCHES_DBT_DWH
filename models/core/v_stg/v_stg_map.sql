
with stg_map_cte as(
    select
        map_index,
        map_name,
        game_mode,
         _stg_file_name,
         _stg_file_load_ts,
         _stg_copy_ts

    from {{ ref('stg_map')}}
),
v_stg_map_cte as(
    select
       -- business key
       map_index,
       -- payload
       map_name,
       game_mode,
       -- hash diff
       {{ hash_cols('stg_map',['map_name','game_mode'],false,true)}} as hash_diff,
       --metadata
         _stg_file_name,
         _stg_file_load_ts,
         _stg_copy_ts
    from stg_map_cte   
),
default_rows_cte as (
    select
        map_index,
        map_name,
        game_mode,
        hash_diff,
        _stg_file_name,
        _stg_file_load_ts,
        _stg_copy_ts
    from values
        (0,
        'unknown',
        'unknown',
        TO_BINARY('00000000000000000000000000000000', 'HEX'),
        'no_source',
        to_timestamp_ntz('1900-01-01 00:00:00'),
        to_timestamp_ntz('1900-01-01 00:00:00'))
    as t(map_index, map_name, game_mode, hash_diff, _stg_file_name, _stg_file_load_ts, _stg_copy_ts)
)
select
    v_stg .*
from v_stg_map_cte as v_stg

union

select
    default_rows_cte.*
from default_rows_cte


    
    
