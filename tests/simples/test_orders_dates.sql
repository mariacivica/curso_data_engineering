/* Comprueba si hay algún caso en el que la fecha de entrega sea anterior a la fecha en que se realizó el pedido */
SELECT *
FROM {{ ref('stg_sql_server_dbo__orders') }}
WHERE DELIVERED_AT_UTC < CREATED_AT_UTC
