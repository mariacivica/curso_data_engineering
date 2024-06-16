-- Modelo 

{{ config(
    materialized='incremental',
    unique_key = ['order_id','product_id'],
    on_schema_change='fail',
    tags = ["incremental_orders"],
)
}}

with stg_order_items as (
    select * from {{ ref('stg_sql_server_dbo__order_items') }}
    
    {% if is_incremental() %}
	  where date_load > (select max(order_items_load) from {{ this }}) 
    {% endif %}
),

stg_orders as (
    select * from {{ ref('stg_sql_server_dbo__orders') }}
    
    {% if is_incremental() %}
	  where date_load > (select max(orders_load) from {{ this }}) 
{% endif %}
),


-- Combinación de orders con order_items
int_orders_2 as (
    select

        a.order_id,
        b.user_id,
        b.address_id,
        a.product_id,
        a.quantity,                                  
        b.promo_id,
        b.status_order,
        b.shipping_service,
        b.tracking_id,
        b.created_at_utc,                                  
        b.estimated_delivery,                       
        b.delivered_at_utc,
        a.date_load as order_items_load,
        b.date_load as orders_load

    from stg_sql_server_dbo__order_items as a
    full outer join stg_sql_server_dbo__orders as b on b.order_id = a.order_id
    order by 1
),


-- Consulta que agrupa las ventas por mes y calcula la cantidad total vendida por mes.
int_summary_orders as(
    select
        date_trunc('month', created_at_utc) as month,
        sum(quantity) as monthly_quantity
    from int_orders_2
    group by 1
),

-- Consulta que calcula el total de productos por pedido
int_count_orders_quantity as( 

    select
        order_id,
        case when sum(quantity) <=0 then 1 
        else sum(quantity) end as total_quantity_sold
    from stg_sql_server_dbo__order_items
    group by 1
    order by 1
), 


-- Union de tablas
int_orders as(
    select
    --keys
        a.order_id,     --1
        a.user_id,
        a.address_id,
        a.product_id,
        a.promo_id,     --5

    -- measures
        a.quantity, -- cantidad de producto vendido
        d.price_usd as unit_price_usd, -- precio unitario del producto
        (a.quantity * d.price_usd) as gross_line_sales_usd,   -- cantidad de producto * precio unitario

        -- descuento total aplicado 
        ((f.promo_discount/100) * (a.quantity*d.price_usd)) as discount_usd,

        -- Costo total de producto para ese pedido
        (d.price_usd * a.quantity) as product_cost_usd, --10
        
        -- costo total del envio * (proporción de la cantidad vendida en la línea de pedido actual en relación con la cantidad total vendida en la orden)
        -- costo del envío asignado a esa línea específica
        round(g.shipping_cost_usd*(a.quantity/h.total_quantity_sold) ,2) as shipping_line_usd,

    --shipping_related
        a.status_order,
        a.shipping_service,                 

    --dates related
        a.created_at_utc as created_at_utc,         --14                              
        a.estimated_delivery as estimated_delivery_at_utc,
        a.delivered_at_utc as delivered_at_utc,
        a.created_at_utc::date as created_at_date,                      
        a.order_items_load,
        a.orders_load,

        '{{invocation_id}}' as batch_id
          
    from int_orders_2 a
    left join stg_sql_server_dbo__products d on d.product_id = a.product_id
    left join stg_sql_server_dbo__promos f on f.promo_id = a.promo_id
    left join stg_sql_server_dbo__orders g on g.order_id = a.order_id
    left join int_count_orders_quantity h on h.order_id = a.order_id
)

select * from int_orders order by 14  --ordenado por fecha de creación