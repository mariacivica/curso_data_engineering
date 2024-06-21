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
        {{ my_generate_surrogate_key(['promo_id', 'discount']) }}::varchar(64) AS promo_id
        , promo_id::varchar(64) AS promo_description
        , decode(discount,null,0,discount)::float AS promo_discount
        , decode(status,'','inactive',null,'inactive',status)::varchar(64) AS promo_status
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS date_load
    FROM src_promos
    )

SELECT * FROM renamed_casted