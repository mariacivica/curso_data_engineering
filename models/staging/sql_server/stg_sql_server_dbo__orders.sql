{{
  config(
    materialized='view'
  )
}}

WITH src_orders AS (
    SELECT * 
    FROM {{source('sql_server', 'orders')}}
    ),

renamed_casted AS (
    SELECT
        ORDER_ID
        , USER_ID
        , md5(PROMO_ID) as PROMO_ID
        , ADDRESS_ID
        , PROMO_ID as DESCRIPTION
        , ORDER_COST AS ITEM_ORDER_COST_USD
        , SHIPPING_COST AS SHIPPING_COST_USD
        , ORDER_TOTAL AS ORDER_TOTAL_COST_USD
        , TRACKING_ID
        , SHIPPING_SERVICE
        , CONVERT_TIMEZONE('UTC', CREATED_AT) AS CREATED_AT_UTC
        ,   CASE
                WHEN ESTIMATED_DELIVERY_AT IS NOT NULL THEN CONVERT_TIMEZONE('UTC', ESTIMATED_DELIVERY_AT)
                ELSE NULL
            END AS ESTIMATED_DELIVERY
        , CONVERT_TIMEZONE('UTC', DELIVERED_AT) AS DELIVERED_AT_UTC
        , DATEDIFF(day, CREATED_AT, DELIVERED_AT) AS DAYS_TO_DELIVER
        , STATUS AS STATUS_ORDER
        , coalesce(_FIVETRAN_DELETED, false) as _fivetran_deleted
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc
    FROM src_orders
    )

SELECT * FROM renamed_casted