--  Materializado en forma de vista ya que se pretende que los datos se actualicen 
--  automaticamente cada vez que se accede, por si hubiera cambios.
--  Se podría considerar cambiar a "table" si las transformaciones son costosas.

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
        product_id::varchar(64) as product_id
        , price::decimal(32,2) AS price_usd
        , name::varchar(64) AS product_name
        , inventory::int AS inventory
        , CONVERT_TIMEZONE('UTC', _fivetran_synced)::timestamp AS date_load
    FROM src_products
    )

SELECT * FROM renamed_casted 
