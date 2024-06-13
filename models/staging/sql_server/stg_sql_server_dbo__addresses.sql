--  Materializado en forma de vista ya que se pretende que los datos se actualicen 
--  automaticamente cada vez que se accede, por si hubiera cambios.
--  Se podría considerar cambiar a "table" si las transformaciones son costosas.
{{
  config(
    materialized='view'
  )
}}

--  Extracción de la fuente origen (tabla origen). 
WITH src_addresses AS (
    SELECT * 
    FROM {{source('sql_server', 'addresses')}}
    ),

--  Transformaciones y conversiones.
renamed_casted AS (
    SELECT
        address_id::varchar(64) AS address_id -- aseguramos que cada registro tenga una única clave única para evitar posibles problemas futuros
        , address::varchar(64) AS address
        , SPLIT_PART(address, ' ', 1)::varchar(64) AS address_number -- extrae el número de la calle
        , SPLIT_PART(address, ' ', 2)::varchar(64) AS address_name -- extrae el nombre de la calle
        , country::varchar(64) AS country
        , state::varchar(64) AS state
        , zipcode::varchar(64) AS zipcode
        , CONVERT_TIMEZONE('UTC', _fivetran_synced)::timestamp AS date_load -- Conversión a UTC.
    FROM src_addresses
    )

SELECT * FROM renamed_casted