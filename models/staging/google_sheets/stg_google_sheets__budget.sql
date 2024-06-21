{{
  config(
    materialized='view'
  )
}}
WITH src_budget AS (
    SELECT * 
    FROM {{source('google_sheets', 'budget')}}
    ),

renamed_casted AS (
    SELECT
        {{ my_generate_surrogate_key(['_row']) }}::varchar(64) AS budget_id
        , product_id::varchar(64) AS product_id
        , quantity::integer AS quantity
        , month AS date
        , CONVERT_TIMEZONE('UTC', _fivetran_synced)::timestamp AS date_load

    FROM src_budget
    )

SELECT * FROM renamed_casted