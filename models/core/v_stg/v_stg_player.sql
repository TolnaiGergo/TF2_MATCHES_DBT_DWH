
with stg_player_cte as(
    select
        player_id,
        player_name,
        country,
        lvl,
         _stg_file_name,
         _stg_file_load_ts,
         _stg_copy_ts

    from {{ ref('stg_player')}}
),
v_stg_player_cte as(
    select
       -- business key
       player_id,
       -- payload
       player_name,
       country,
       lvl,
       -- hash diff
       {{ hash_cols('sgt_player',['player_name','country','lvl'],false,true)}} as hash_diff,
       --metadata
         _stg_file_name,
         _stg_file_load_ts,
         _stg_copy_ts
    from stg_player_cte   
),
default_rows_cte as (
    select
        player_id,
        player_name,
        country,
        lvl,
        hash_diff,
        _stg_file_name,
        _stg_file_load_ts,
        _stg_copy_ts
    from values
        (0,
        'unknown',
        'unknown',
        -1,
        TO_BINARY('00000000000000000000000000000000', 'HEX'),
        'no_source',
        to_timestamp_ntz('1900-01-01 00:00:00'),
        to_timestamp_ntz('1900-01-01 00:00:00'))
    as t(player_id, player_name, country, lvl, hash_diff, _stg_file_name, _stg_file_load_ts, _stg_copy_ts)
)
select
    v_stg .*,
    {{ generate_audit_metadata() }}
from v_stg_player_cte as v_stg

union

select
    default_rows_cte.*,
    {{ generate_audit_metadata() }}
from default_rows_cte
-- another comment
