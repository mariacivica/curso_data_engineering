-- Cuando un pedido (status_order) cambie de estado (order_id) comparado con la fila anterior, significa que ha habido un cambio de estado.
-- Las filas donde status_change_date no es null (tiene fecha y hora) significa que ha habido un cambio de estado del pedido


{{ config(
    materialized='incremental',
    unique_key = ['order_id', 'status_order', 'status_change_date'],
    on_schema_change='append_new_columns',
    tags = ["fact_order_status"],
)
}}

-- Definimos las CTEs
WITH int_orders as (
    select * from {{ ref('int_orders') }}
    
    {% if is_incremental() %}
	  where date_load > (select max(orders_load) from {{ this }}) 
{% endif %}
),

dim_users AS (
    select * from {{ ref('dim_users') }}
),
dim_addresses AS (
    select * from {{ ref('dim_addresses') }}
),
dim_products AS (
    select * from {{ ref('dim_products') }}
),
dim_promos AS (
    select * from {{ ref('dim_promos') }}
),

fact_order_status AS (
    select
        a.order_id,
        a.product_id,
        a.user_id,
        a.address_id,
        a.promo_id,
        a.status_order,
        case 
            when a.status_order != lag(a.status_order) over (partition by a.order_id order by a.created_at_utc)
            then a.created_at_utc 
            else null 
        end as status_change_date,
        a.estimated_delivery_at_utc,
        a.delivered_at_utc,
        a.created_at_date,
        a.quantity,
        a.unit_price_usd,
        a.product_cost_usd,
        a.shipping_line_usd,
        a.batch_id,
        greatest(a.order_items_load, a.orders_load) as date_load,
        b.address,
        b.address_number,
        b.address_name,
        b.country,
        b.state,
        b.zipcode,
        c.product_name,
        c.inventory,
        d.promo_description,
        d.discount_unit,
        d.promo_status,
        e.full_name,
        e.email,
        e.phone_number
    from int_orders a
    left join dim_addresses b on b.address_id = a.address_id
    left join dim_products c on c.product_id = a.product_id
    left join dim_promos d on d.promo_id = a.promo_id
    left join dim_users e on e.user_id = a.user_id
)

-- Seleccionamos los registros con cambios de estado
select * 
from fact_order_status
where status_change_date is not null
order by status_change_date
