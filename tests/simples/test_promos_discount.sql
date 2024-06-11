/*Test singular que comprueba que el descuento sea mayor o igual a 0*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__promos') }}
WHERE DISCOUNT_TOTAL_USD < 0