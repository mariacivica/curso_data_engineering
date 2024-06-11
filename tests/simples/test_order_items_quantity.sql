/* Comprueba que la cantidad de productos en un pedido siempre es positiva*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__order_items') }}
WHERE QUANTITY <= 0
