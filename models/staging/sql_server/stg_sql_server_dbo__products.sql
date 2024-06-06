{{
  config(
    materialized='view'
  )
}}

WITH src_products AS (
    SELECT * 
    FROM {{source('sql_server', 'products')}}
    ),

renamed_casted AS (
    SELECT
        PRODUCT_ID
        , PRICE AS PRICE_USD
        , NAME
        , INVENTORY
        , coalesce(_FIVETRAN_DELETED, false) as _fivetran_deleted
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc
    FROM src_products
    )

SELECT * FROM renamed_casted