{{ config(materialized="table", tags=["conversations"]) }}

select
    id,
    case
        when lower(dietary_habit) like '%vegetarian%'
        then 'Vegetarian'
        when lower(dietary_habit) like '%vegan%'
        then 'Vegan'
        else 'Unknown'
    end as dietary_habit,
    top_three_foods
from {{ ref("refined_sim_conversations") }}
where
    lower(dietary_habit) like '%vegetarian%'
    and lower(dietary_habit) not like '%non-vegetarian%'
    or lower(dietary_habit) like '%vegan%'
