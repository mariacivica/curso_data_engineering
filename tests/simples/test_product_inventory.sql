/*Test singular que comprueba que el inventario sea mayor o igual a 0*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__products') }}
WHERE INVENTORY < 0