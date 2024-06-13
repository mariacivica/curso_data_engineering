--  Materializado en forma de vista ya que se pretende que los datos se actualicen 
--  automaticamente cada vez que se accede, por si hubiera cambios.
--  Se podría considerar cambiar a "table" si las transformaciones son costosas.
{{
  config(
    materialized='view' 
  )
}}

--  Extracción de la fuente origen (tabla origen). 
WITH src_events AS (
    SELECT * 
    FROM {{source('sql_server', 'events')}}
    ),

--  Transformaciones y conversiones.
renamed_casted AS (
    SELECT
       event_id::varchar(64) AS event_id -- aseguramos que cada registro tenga una única clave única para evitar posibles problemas futuros
        , session_id::varchar(64) AS session_id
        , user_id::varchar(64) AS user_id
        , event_type::varchar(64) AS event_type
        , decode(product_id,'','unknown',null,'unknown',product_id)::varchar(64) AS product_id -- si product_id es cadena vacia o null devuelve unknown, sino devuelve el product_id.
        , decode(order_id,'','unknown',null,'unknown',order_id)::varchar(64) AS order_id -- si order_id es cadena vacia o null devuelve unknown, sino devuelve el order_id.
        , page_url::varchar(256) AS page_url
        , CASE -- Validación de urls
                WHEN left(page_url, 8) = 'https://' THEN true
                ELSE FALSE
            END AS is_valid_page_url
        , CONVERT_TIMEZONE('UTC', created_at)::timestamp AS created_at_utc -- Conversión a UTC.
        , CONVERT_TIMEZONE('UTC', _fivetran_synced)::timestamp AS date_load -- Conversión a UTC.
    FROM src_events
    )

SELECT * FROM renamed_casted