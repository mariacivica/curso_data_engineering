{{ config(
    materialized='incremental',
    unique_key = ['order_id'],
    on_schema_change='append_new_columns',
    tags = ["incremental_orders"],
)
    }}

with int_orders as(    
    select * from {{ ref('int_orders') }}

    {% if is_incremental() %}
	  where orders_load > (select max(orders_load) from {{ this }}) 
    {% endif %}

),

dim_date as (
    select* from {{ ref('dim_date') }}
),

dim_users as (
    select* from {{ ref('dim_users') }}
),

dim_addresses as (
    select* from {{ ref('dim_addresses') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

dim_promos as (
    select * from {{ ref('dim_promos') }}
),



fact_orders as(

    select
    --keys
        b.date_key,
        {{my_generate_surrogate_key(['a.order_id','a.product_id'])}} as order_id,
        a.order_id,
        c.user_id_1,  
        d.address_id,
        a.shipping_service,
        g.promo_id,
        f.product_id_1,              --8

    -- shipping
        a.status_order,

    -- measures (money related)

        a.quantity,          
        f.price_usd,
        a.gross_line_sales_usd,
        a.discount_usd,
        a.shipping_line_usd,
    
        a.product_cost_usd,         

    -- medidas de tiempo
        {{ dbt.datediff("a.created_at_utc", "a.delivered_at_utc", "day") }} as days_to_deliver,
        {{ dbt.datediff("a.estimated_delivery_at_utc", "a.delivered_at_utc", "day") }} as deliver_precision_days,  
        
    -- just in case you need
        a.created_at_utc,  --18            
        a.created_at_date,
        to_char(date_trunc('hour', a.created_at_utc), 'HH24MI') as time_key,
        a.orders_load,

        '{{invocation_id}}' as batch_id         
 
    from int_orders a

    left join dim_date b on b.date_day = a.created_at_date
    left join dim_users c on c.user_id_2 = a.user_id
    left join dim_addresses d on d.address_id = a.address_id
    left join dim_products f on f.product_id_1 = a.product_id
    left join dim_promos g on g.promo_id = a.promo_id
)

select * from fact_orders ORDER BY 18