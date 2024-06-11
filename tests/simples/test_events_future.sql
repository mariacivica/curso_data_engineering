/* Comprueba que las marcas de tiempo no esten establecidas en el futuro */
SELECT *
FROM {{ ref('stg_sql_server_dbo__events') }}
WHERE  CREATED_AT_UTC > CURRENT_TIMESTAMP
