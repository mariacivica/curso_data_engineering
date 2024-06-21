-- Ayuda al departamento a entender tanto la popularidad como el impacto de cada producto, 
-- lo que puede informar decisiones de marketing, mejoras de productos y estrategias comerciales.

{{
  config(
    materialized='table'
  )
}}

WITH fact_reviews AS(
    SELECT
        review_id,
        product_id,
        quality_rating,
        usability_rating,
        value_for_money_rating,
        delivery_speed_rating
    FROM {{ ref("fact_reviews") }}
),

-- Info de productos
dim_products AS (
    SELECT
        product_id,
        product_name,
        price_usd
    FROM {{ ref("dim_products") }}
),

-- Info de pedidos 
fact_orders AS(
        SELECT
        order_id,
        product_id
    FROM {{ ref("fact_orders") }}
),


-- Calcula promedios de las puntuaciones de calidad usabilidad relacion calidad-precio velocidad de entrega
-- Agrupa los resultados por product_id y product_name
product_reviews AS (
    SELECT
        r.product_id,
        p.product_name,
        AVG(r.quality_rating) AS avg_quality_rating,
        AVG(r.usability_rating) AS avg_usability_rating,
        AVG(r.value_for_money_rating) AS avg_value_for_money_rating,
        AVG(r.delivery_speed_rating) AS avg_delivery_speed_rating
    FROM fact_reviews r
    JOIN dim_products p ON r.product_id = p.product_id
    GROUP BY r.product_id, p.product_name
),

-- Calcula el total de ventas y los ingresos totales por producto.
product_sales AS (
    SELECT
        o.product_id,
        COUNT(o.order_id) AS total_sales,
        SUM(p.price_usd) AS total_revenue
    FROM fact_orders o
    JOIN dim_products p ON o.product_id = p.product_id
    GROUP BY o.product_id
)

-- Junta los datos de reseñas y ventas de productos, ordenando los resultados 
-- por ingresos totales en orden descendente.
-- total_sales indica la popularidad de un producto en terminos de volumen de ventas
-- total_revenue muestra el impacto financiero total de las ventas del producto
SELECT
    pr.product_id,
    pr.product_name,
    pr.avg_quality_rating,
    pr.avg_usability_rating,
    pr.avg_value_for_money_rating,
    pr.avg_delivery_speed_rating,
    ps.total_sales, -- numero total de ventas de un producto (numero de veces q se ha vendido un prod)
    ps.total_revenue -- ingresos totales generados por las ventas de ese producto
FROM product_reviews pr
LEFT JOIN product_sales ps ON pr.product_id = ps.product_id
ORDER BY ps.total_revenue DESC