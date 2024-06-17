-- Snapshot porque es importante tener un seguimiento histórico de cambios en el precio (y en el inventario¿?)

WITH src_products AS (
    SELECT * 
    FROM {{ ref('src_products_snapshot') }}
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
