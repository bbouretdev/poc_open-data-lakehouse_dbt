{{ config(alias='learnsets') }}
{{ config(materialized='table') }}

with pokemons__main as (
  select 
    $1:_dlt_id::string as dlt_id,
    $1:id::int as id,
    $1:species__name::string as species_name
  from {{ source('pokemon', 'pokemon_pokemons__main') }}
),

pokemons__moves as (
  select 
    $1:_dlt_parent_id::string as dlt_parent_id,
    $1:move__name::string as move_name
  from {{ source('pokemon', 'pokemon_pokemons__moves') }}
),

final as (
    select
        p.species_name as species_name,
        p.id::int as id,
        pm.move_name as move_name
    from pokemons__main p
    left join pokemons__moves pm
        on pm.dlt_parent_id = p.dlt_id
)

select 
    id::int as id,
    species_name,
    move_name::varchar as move_name
from final