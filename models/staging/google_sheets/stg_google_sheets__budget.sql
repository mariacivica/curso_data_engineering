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
        _row
        , product_id
        , quantity
        , month
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc

    FROM src_budget
    )

SELECT * FROM renamed_casted