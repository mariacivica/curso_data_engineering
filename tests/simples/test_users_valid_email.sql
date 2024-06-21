/*Test singular que comprueba que el is_valid_email sea verdadero en todos los campos*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__users') }}
WHERE IS_VALID_EMAIL = FALSE AND EMAIL LIKE '%_@__%.__%'
