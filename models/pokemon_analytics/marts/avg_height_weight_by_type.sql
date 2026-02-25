{{ config(
    materialized='table',
    alias='avg_height_weight_by_type'
) }}

with base as (
    select *
    from {{ ref('int__pokemons') }}
),

types as (
    select id, type_1 as type, height, weight
    from base
    where type_1 is not null

    union all

    select id, type_2 as type, height, weight
    from base
    where type_2 is not null
),

aggregated as (
    select
        type,
        avg(height) as avg_height,
        avg(weight) as avg_weight
    from types
    group by type
)

select *
from aggregated