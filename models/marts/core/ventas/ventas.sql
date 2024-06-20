-- Comparación de ventas presupuestadas con ventas reales
-- Propósito: Identificar variaciones significativas entre expectativas y realidad

{{
  config(
    materialized='table'
  )
}}

-- Información del presupuesto
WITH fact_budget AS (
    SELECT
        budget_id,
        product_id,
        quantity,
        date
    FROM {{ ref("fact_budget") }}
),

-- Información de productos
dim_products AS (
    SELECT
        product_id,
        price_usd,
        product_name,
        inventory
    FROM {{ ref("dim_products") }}
),

-- Información de órdenes
fact_orders AS (
    SELECT
        order_id,
        product_id,
        user_id,
        price_usd,
        total_sales_usd,
        total_quantity_sold,
        total_shipping_cost,
        total_items_cost,
        total_order_cost
    FROM {{ ref("fact_orders") }}
),

-- Ventas totales por producto
total_sales_per_product AS (
    SELECT
        product_id,
        price_usd,
        SUM(total_quantity_sold) AS total_quantity_sold,
        SUM(total_sales_usd) AS total_sales_usd  -- Se debe sumar también total_sales_usd si es necesario
    FROM fact_orders
    GROUP BY product_id, price_usd
),

-- Costos totales de pedido
total_order_costs AS (
    SELECT
        order_id,
        user_id,
        product_id,
        SUM(total_items_cost) AS total_items_cost,
        SUM(total_shipping_cost) AS total_shipping_cost,
        SUM(total_order_cost) AS total_order_cost
    FROM fact_orders
    GROUP BY order_id, user_id, product_id
)

-- Comparación de ventas presupuestadas y reales
SELECT
    fb.date AS month,
    p.product_name,
    SUM(fb.quantity) AS total_budget_quantity,
     tsp.total_quantity_sold,
    SUM(fb.quantity * p.price_usd) AS total_budget_amount,
    tsp.total_sales_usd,
    (total_quantity_sold - total_budget_quantity) AS dif_quantity, -- resto las cantidades para sacar las diferencias
    (total_sales_usd - total_budget_amount) AS dif_sales

FROM total_sales_per_product tsp
JOIN dim_products p ON tsp.product_id = p.product_id
LEFT JOIN fact_budget fb ON tsp.product_id = fb.product_id
LEFT JOIN total_order_costs toc ON toc.product_id = tsp.product_id
GROUP BY 
    fb.date,  
    p.product_name, 
    tsp.total_quantity_sold,  
    tsp.total_sales_usd     
    
ORDER BY fb.date, tsp.total_sales_usd DESC
