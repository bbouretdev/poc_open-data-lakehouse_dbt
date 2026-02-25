with pokemons__main as (
  select 
    CAST(_dlt_id AS VARCHAR) as dlt_id,
    CAST(id AS INTEGER) as id,
    CAST(species__name AS VARCHAR) as species_name
  from {{ source('bronze', 'pokemons') }}
),

pokemons__moves as (
  select 
    CAST(_dlt_parent_id AS VARCHAR) as dlt_parent_id,
    CAST(move__name AS VARCHAR) as move_name
  from {{ source('bronze', 'pokemons__moves') }}
),

final as (
    select
        p.species_name as species_name,
        p.id as id,
        pm.move_name as move_name
    from pokemons__main p
    left join pokemons__moves pm
        on pm.dlt_parent_id = p.dlt_id
)

select 
    to_hex(md5(to_utf8(CAST(id AS VARCHAR) || '|' || move_name))) as unique_key,
    id as id,
    species_name,
    move_name as move_name
from final