with aggregated_match_cte as (
    select
        year(match_date) as year,
        month(match_date) as month,
        map_name,
        count(match_id) as total_matches,
        SUM(
            CASE 
                WHEN lower(winning_team) = lower(result_team)  THEN 1
                ELSE 0
            END
        ) as total_wins,
        (total_matches - total_wins) as total_losses,
        avg(kills) as avg_kills,
        avg(deaths) as avg_deaths,
        avg(damage) as avg_damage

    from {{ ref('fact_match')}}
    inner join {{ ref('dim_map')}}
        using(dim_map_sk)
    group by year(match_date),
             month(match_date),
             map_name
    order by year desc, month desc, map_name asc
)
select * from aggregated_match_cte