/*Test singular que comprueba que first_name y last_name no son nulos*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__users') }}
WHERE FIRST_NAME IS NULL OR LAST_NAME IS NULL
