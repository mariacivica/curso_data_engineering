{{
  config(
    materialized='view'
  )
}}

WITH src_order_items AS (
    SELECT * 
    FROM {{source('sql_server', 'order_items')}}
    ),

renamed_casted AS (
    SELECT
        ORDER_ID
        , PRODUCT_ID
        , QUANTITY
        , coalesce(_FIVETRAN_DELETED, false) as _fivetran_deleted
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc
    FROM src_order_items
    )

SELECT * FROM renamed_casted