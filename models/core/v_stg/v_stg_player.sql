
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
)
select
    *
from v_stg_player_cte   
    
    
