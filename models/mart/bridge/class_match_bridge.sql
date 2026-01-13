WITH mask AS 
(
    SELECT seq4() as idx
    FROM TABLE(GENERATOR( rowcount => 9))

)
SELECT
    classes_played,
    idx as dim_class_id,
    CASE
        WHEN BITAND(classes_played,POWER(2,idx)) <> 0 THEN TRUE
        ELSE FALSE
    END AS participated
FROM mask, {{ ref('dim_class_set') }}
