/* Comprueba si hay algún caso en el que la fecha de creación no sea posterior a la fecha de actualizacion */
SELECT *
FROM {{ ref('stg_sql_server_dbo__users') }}
WHERE CREATED_AT_UTC > UPDATED_AT_UTC
