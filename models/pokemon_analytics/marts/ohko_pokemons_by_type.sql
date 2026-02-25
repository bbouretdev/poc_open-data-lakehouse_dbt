{{
    config(
      materialized='table',
      alias='ohko_pokemons_by_type'
    )
}}

with base as (

    select *
    from {{ ref('ohko_pokemons') }}

),

types as (

    select id, type_1 as type
    from base
    where type_1 is not null

    union all

    select id, type_2 as type
    from base
    where type_2 is not null

),

aggregated as (

    select
        type,
        count(distinct id) as pokemon_count
    from types
    group by type

)

select *
from aggregated
order by pokemon_count desc