
with stg_sql_server_dbo__promos as (
    
    select * from {{ ref('stg_sql_server_dbo__promos') }}
),

dim_promos as(
    select
        promo_id,
        promo_description,
        decode(promo_discount,null,0,promo_discount/100) as discount_unit,
        promo_status

    from stg_sql_server_dbo__promos
    )
    
select * from dim_promos