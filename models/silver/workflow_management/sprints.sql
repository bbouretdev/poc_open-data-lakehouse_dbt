{{
    config(
      materialized = 'incremental',
      unique_key='id',
      incremental_strategy='merge',
      )
}}

SELECT *, current_timestamp AS run_time
FROM {{ source('bronze', 'sprints_bronze_generated') }}
LIMIT 3