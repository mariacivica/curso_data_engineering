{{
  config(
    materialized='view'
  )
}}


WITH src_events AS (
    SELECT * 
    FROM {{source('sql_server', 'events')}}
    ),

renamed_casted AS (
    SELECT
        EVENT_ID
        , USER_ID
        , PRODUCT_ID
        , SESSION_ID
        , ORDER_ID
        , EVENT_TYPE
        , PAGE_URL
        , CASE -- Para comprobar que todos los campos de page_url son urls
                WHEN left(PAGE_URL, 8) = 'https://' then true
                ELSE FALSE
            END AS IS_VALID_PAGE_URL
        , CONVERT_TIMEZONE('UTC', CREATED_AT) AS CREATED_AT_UTC
        , coalesce(_FIVETRAN_DELETED, false) as _fivetran_deleted
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc
    FROM src_events
    )

SELECT * FROM renamed_casted