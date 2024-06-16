with stg_sql_server_dbo__products as(
    
    select * from {{ ref('stg_sql_server_dbo__products') }}
),

dim_products as (

    select
        {{my_generate_surrogate_key(['product_id','product_name'])}} AS product_id_1,
        product_id AS product_id_2,
        product_name,
        price_usd,
        inventory
    from stg_sql_server_dbo__products    
)

select * from dim_products