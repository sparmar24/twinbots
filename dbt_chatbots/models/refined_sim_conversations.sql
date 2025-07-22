{{ config(materialized="table", tags=["conversations"]) }}

select
    id,
    split_part(answer, ':', 1) as dietary_habit,
    split_part(answer, ':', 2) as top_three_foods
from simulated_conversations
limit 100
