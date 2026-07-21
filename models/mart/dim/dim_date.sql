/*WITH date_range AS 
(
    SELECT 
        MIN(cast(connection_time_tz as date)) AS min_date,
        MAX(cast(connection_time_tz as date)) AS max_date
    FROM {{ ref('match')}}
),*/
WITH recursive dates_cte AS
(
    --anchor
    SELECT
        current_date() AS today,
        year(today) AS year,
        quarter(today) AS quarter,
        month(today) AS month,
        week(today) AS week,
        dayofyear(today) AS day_of_year,
        dayofweek(today) AS day_of_week,
        dayofmonth(today) AS day_of_the_month,
        dayname(today) AS day_name

    UNION ALL

    -- recursive claues
    SELECT
        dateadd('day',-1, today) AS today_r,
        year(today_r) AS year,
        quarter(today_r) AS quarter,
        month(today_r) AS month,
        week(today_r) AS week,
        dayofyear(today_r) AS day_of_year,
        dayofweek(today_r) AS day_of_week,
        dayofmonth(today_r) AS day_of_the_month,
        dayname(today_r) AS day_name
    FROM dates_cte
    WHERE today_r >= (SELECT MIN(cast(connection_time as date)) FROM {{ ref('match') }})
)
SELECT
    TO_NUMBER(TO_CHAR(today, 'YYYYMMDD'))AS dim_date_sk,
    today AS CALENDAR_DATE,
    year,
    quarter,
    month,
    week,
    day_of_year,
    day_of_week,
    day_of_the_month,
    day_name,
    {{ generate_audit_metadata() }}
FROM dates_cte

-- no wildcard select nooo!