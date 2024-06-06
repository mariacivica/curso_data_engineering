{{
  config(
    materialized='view'
  )
}}

WITH src_addresses AS (
    SELECT * 
    FROM {{source('sql_server', 'addresses')}}
    ),

renamed_casted AS (
    SELECT
        address_id
        , zipcode
        , country
        , address
        , state
        , coalesce(_FIVETRAN_DELETED, false) as _fivetran_deleted_utc
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc
    FROM src_addresses
    )

SELECT * FROM renamed_casted