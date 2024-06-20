-- Modelo intermediate para unir order_items products y orders.
-- Combina la información de ventas por producto y los costos 
-- asociados por pedido, lo que permite un análisis más completo 
-- de las ventas y los costos 

{{
  config(
    materialized='table'
  )
}}

WITH stg_order_items AS 
(
    SELECT *
    FROM {{ ref("stg_sql_server_dbo__order_items") }}

),


stg_products AS 
(
    SELECT 
        product_id,
        price_usd
    FROM {{ ref("stg_sql_server_dbo__products") }}
),

stg_orders AS 
(
    SELECT *
    FROM {{ ref("stg_sql_server_dbo__orders") }}
),

-- Agrupa las ventas por product_id y calcula la cantidad total vendida y las ventas totales
-- Uso la tabla de order_items para obtener la cantidad de productos vendidos y la tabla products para 
-- obtener el precio de cada producto 
total_sales_per_product AS (
    SELECT 
        oi.product_id,
        p.price_usd,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.quantity * p.price_usd) AS total_sales_usd
    FROM stg_order_items oi
    JOIN stg_products p ON oi.product_id = p.product_id
    GROUP BY oi.product_id, p.price_usd
),

-- Agrupa los costes por order_id y user_id calculando los costes totales de
-- items, de envío y del pedido completo
-- Uso  la tabla orders para obtener los costes de los items, de envío y el coste total de pedido 
total_order_costs AS (
    SELECT 
        o.order_id,
        o.user_id,
        SUM(o.item_order_cost_usd) AS total_items_cost,
        SUM(o.shipping_cost_usd) AS total_shipping_cost,
        SUM(o.order_total_cost_usd) AS total_order_cost
    FROM stg_orders o
    GROUP BY o.order_id, o.user_id
)

SELECT 
    tsp.product_id, -- ID de un único producto
    tsp.price_usd, -- precio del producto
    tsp.total_quantity_sold, -- la cantidad total de unidades vendidas del producto (suma quantity)
    tsp.total_sales_usd, -- precio total generado por las ventas del producto 
    toc.order_id, -- ID único del pedido
    toc.user_id, -- ID único del usuario
    toc.total_items_cost, -- Coste total de los items (del producto concreto, no de todos los != productos del pedido) en el pedido 
    toc.total_shipping_cost, -- Coste total del envio del pedido (suma shipping_cost_usd) por cada pedido
    toc.total_order_cost -- Coste total del pedido incluyendo coste de los items del pedido y el coste del envío
FROM total_sales_per_product tsp
JOIN total_order_costs toc ON toc.order_id = (SELECT MIN(order_id) FROM stg_order_items WHERE product_id = tsp.product_id)
