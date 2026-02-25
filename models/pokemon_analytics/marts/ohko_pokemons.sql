{{
    config(
      unique_key='id',
      alias='ohko_pokemons'
    )
}}

with pokemons as (

    select *
    from {{ ref('int__pokemons') }}

),

learnsets as (

    select *
    from {{ ref('int__learnsets') }}

),

ohko_moves as (

    select lower(move_name) as move_name
    from {{ ref('ohko_moves') }}

),

filtered as (

    select distinct
        p.*
    from pokemons p
    join learnsets l
        on l.id = p.id
    join ohko_moves m
        on lower(l.move_name) = m.move_name

)

select *
from filtered