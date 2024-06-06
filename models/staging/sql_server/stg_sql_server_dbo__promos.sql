{{
  config(
    materialized='view'
  )
}}

WITH src_promos AS (
    SELECT * 
    FROM {{source('sql_server', 'promos')}}
    ),

renamed_casted AS (
    SELECT
          md5(PROMO_ID) as PROMO_ID
        , PROMO_ID as DESCRIPTION
        , DISCOUNT as DISCOUNT_TOTAL_USD
        , STATUS
        , coalesce(_FIVETRAN_DELETED, false) as _fivetran_deleted
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc
    FROM src_promos
    )

SELECT * FROM renamed_casted