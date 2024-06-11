/*Test singular que comprueba que el precio sea mayor o igual a 0*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__products') }}
WHERE PRICE_USD <= 0