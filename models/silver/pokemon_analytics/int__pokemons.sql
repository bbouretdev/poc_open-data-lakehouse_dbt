{{ config(alias='pokemons') }}
{{ config(materialized='table') }}

with pokemons__main as (
  select 
    $1:_dlt_id::string as dlt_id,
    $1:species__name::string as species_name
  from {{ source('pokemon', 'pokemons') }}
),

pokemons__abilities as (
  select 
    $1:_dlt_parent_id::string as dlt_parent_id,
    $1:ability__name::string as ability_name,
    $1:is_hidden::boolean as is_hidden,
    $1:slot::int as slot
  from {{ source('pokemon', 'pokemon_pokemons__abilities') }}
),

pokemons__stats as (
  select 
    $1:_dlt_parent_id::string as dlt_parent_id,
    $1:stat__name::string as stat_name,
    $1:base_stat as base_stat
  from {{ source('pokemon', 'pokemon_pokemons__stats') }}
),

pokemons__types as (
  select 
    $1:_dlt_parent_id::string as dlt_parent_id,
    $1:type__name::string as type_name,
    $1:slot::int as slot
  from {{ source('pokemon', 'pokemon_pokemons__types') }}
),

abilities_pivot as (
    select
        dlt_parent_id,
        max(case when slot = 1 and is_hidden = false then ability_name end) as ability_1,
        max(case when slot = 2 and is_hidden = false then ability_name end) as ability_2,
        max(case when is_hidden = true then ability_name end) as ability_hidden
    from pokemons__abilities
    group by dlt_parent_id
),

stats_pivot as (
    select
        dlt_parent_id,
        max(case when stat_name = 'hp'              then base_stat end) as hp,
        max(case when stat_name = 'attack'          then base_stat end) as atk,
        max(case when stat_name = 'defense'         then base_stat end) as def,
        max(case when stat_name = 'special-attack'  then base_stat end) as spa,
        max(case when stat_name = 'special-defense' then base_stat end) as spd,
        max(case when stat_name = 'speed'           then base_stat end) as spe
    from pokemons__stats
    group by dlt_parent_id
),

types_pivot as (
    select
        dlt_parent_id,
        max(case when slot = 1 then type_name end) as type_1,
        max(case when slot = 2 then type_name end) as type_2
    from pokemons__types
    group by dlt_parent_id
),

final as (
    select
        p.species_name,
        a.ability_1,
        a.ability_2,
        a.ability_hidden,
        s.hp,
        s.atk,
        s.def,
        s.spa,
        s.spd,
        s.spe,
        t.type_1,
        t.type_2
    from pokemons__main p
    left join abilities_pivot a
        on a.dlt_parent_id = p.dlt_id
    left join stats_pivot s
        on s.dlt_parent_id = p.dlt_id
    left join types_pivot t
        on t.dlt_parent_id = p.dlt_id
)

select *
from final