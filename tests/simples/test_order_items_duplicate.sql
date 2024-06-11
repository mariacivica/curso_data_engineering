/* Comprueba que cada producto aparezca solo una vez por pedido*/
SELECT order_id, product_id
FROM {{ ref('stg_sql_server_dbo__order_items') }}
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
