--Dimensión producto. Distintos productos, todos unicos (no se repiten)
with stg_sql_server_dbo__products as(
    
    select * from {{ ref('stg_sql_server_dbo__products') }}
),

dim_products as (

    select
        product_id,
        product_name,
        price_usd,
        inventory
    from stg_sql_server_dbo__products    
)

select * from dim_products