with pokemons__main as (
  select 
    CAST(_dlt_id AS VARCHAR) as dlt_id,
    CAST(id AS INTEGER) as id,
    CAST(species__name AS VARCHAR) as species_name,
    CAST(height AS INTEGER) / 10 as height,
    CAST(weight AS INTEGER) / 10 as weight
  from {{ source('bronze', 'pokemons') }}
),

pokemons__abilities as (
  select 
    CAST(_dlt_parent_id AS VARCHAR) as dlt_parent_id,
    CAST(ability__name AS VARCHAR) as ability_name,
    CAST(is_hidden AS BOOLEAN) as is_hidden,
    CAST(slot AS INTEGER) as slot
  from {{ source('bronze', 'pokemons__abilities') }}
),

pokemons__stats as (
  select 
    CAST(_dlt_parent_id AS VARCHAR) as dlt_parent_id,
    CAST(stat__name AS VARCHAR) as stat_name,
    base_stat
  from {{ source('bronze', 'pokemons__stats') }}
),

pokemons__types as (
  select 
    CAST(_dlt_parent_id AS VARCHAR) as dlt_parent_id,
    CAST(type__name AS VARCHAR) as type_name,
    CAST(slot AS INTEGER) as slot
  from {{ source('bronze', 'pokemons__types') }}
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
        p.id,
        p.species_name,
        p.height,
        p.weight,
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