/*  Creo un intermediate combinando usuarios con direcciones.
    Esto implica la eliminación de duplicados y la combinacion de datos de diferentes fuentes.
    Se materializa en forma de tabla porque estas operaciones son mas costosas computacionalmente
    y así solo se realizan una vez en lugar de cada vez que se accede (como ocurre con las vistas).
    En resumen, mejora el rendimiento y eficiencia, reduce la carga en la base de datos y garantiza
    la consistencia de los datos cuando hay consultas frecuentes.
*/

{{
  config(
    materialized='table'
  )
}}

WITH stg_sql_server_dbo_addresses AS
(
    SELECT DISTINCT ADDRESS_ID
    FROM {{ ref('stg_sql_server_dbo__addresses') }}
),

stg_sql_server_dbo__users AS
(
    SELECT DISTINCT ADDRESS_ID
    FROM {{ ref('stg_sql_server_dbo__users') }}
),

/*Todos los ADDRESS_ID repetidos*/
all_addresses_duplicates AS
(
    SELECT * 
    FROM stg_sql_server_dbo_addresses
    UNION ALL
    SELECT *
    FROM stg_sql_server_dbo__users
),

all_addresses_without_duplicates AS
(
    SELECT DISTINCT(ADDRESS_ID)
    FROM all_addresses_duplicates
)

SELECT 
     address_id
    , ADDRESS::varchar(64) AS ADDRESS
    , COUNTRY::varchar(64) AS COUNTRY
    , STATE::varchar(64) AS STATE
    , ZIPCODE::integer AS ZIPCODE  
    , DATE_LOAD
FROM all_addresses_without_duplicates
FULL JOIN {{ ref('stg_sql_server_dbo__addresses') }}
USING(ADDRESS_ID)