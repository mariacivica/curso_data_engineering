--  Modelo diseñado para procesar de manera incremental los datos de la tabla "orders", lo que significa que solo procesará los 
--  nuevos datos que se han añadido o modificado desde la última ejecución.
--  

{{
  config(
    materialized ='incremental',
    unique_key ='order_id'
  )
}}

WITH src_orders AS (
    SELECT * 
    FROM {{source('sql_server', 'orders')}}

    -- Condicional que verifica si el modelo se está ejecutando de forma incremental, si es que si aplica la condicion para filtrar los datos de entrada
    {% if is_incremental() %}
        where _fivetran_synced > (select max(date_load) from {{ this }}) -- condición que asegura la selección de registros nuevos o modificados desde la 
    {% endif %}     

),

renamed_casted AS (
    SELECT
        -- claves
        order_id::varchar(64) AS order_id -- aseguramos que cada registro tenga una única clave única para evitar posibles problemas futuros
        , user_id::varchar(64) AS user_id
        , address_id::varchar(64) AS address_id
        , {{ my_generate_surrogate_key(['promo_id']) }}::varchar(64) AS promo_id
        , CASE promo_id 
            WHEN 'instruction set' THEN 'Instruction Set Promo'
            WHEN 'Optional' THEN 'Optional Promo'
            WHEN 'Mandatory' THEN 'Mandatory Promo'
            WHEN 'leverage' THEN 'Leverage Promo'
            WHEN 'Digitized' THEN 'Digitalized Promo'
            WHEN 'task-force' THEN 'Task-force Promo'
            ELSE 'No Promo'
          END AS promo_description

          -- Medidas potenciales
        , order_cost::decimal(16,2) AS item_order_cost_usd
        , shipping_cost::decimal(16,2) AS shipping_cost_usd
        , order_total::decimal(16,2) AS order_total_cost_usd
        
        -- Envios y entregas
        , status::varchar(64) AS status_order
        , CASE  -- si el estado es "en preparacion" el tracking_id sera "no definido", si no está "en preparación" devuelve el valor de tracking_id y si es null devuelve "undefined"
            WHEN status = 'preparing' THEN 'undefined'
            ELSE COALESCE(tracking_id, 'undefined')
          END AS tracking_id
        , CASE   -- si el estado es "en preparacion" el shipping_service sera "no definido", si no está "en preparación" devuelve el valor de shipping_service y si es null devuelve "undefined"
            WHEN status = 'preparing' THEN 'undefined'
            ELSE COALESCE(shipping_service, 'undefined')
          END AS shipping_service

        -- Fechas
        , CONVERT_TIMEZONE('UTC', created_at)::timestamp AS created_at_utc
        ,   CASE
                WHEN estimated_delivery_at IS NOT NULL THEN CONVERT_TIMEZONE('UTC', estimated_delivery_at)::timestamp
                ELSE NULL
            END AS estimated_delivery
        , CONVERT_TIMEZONE('UTC', delivered_at)::timestamp AS delivered_at_utc
        , DATEDIFF(day, created_at, delivered_at) AS days_to_deliver

        -- 
        , CONVERT_TIMEZONE('UTC', _fivetran_synced)::timestamp AS date_load
    FROM src_orders
    )

SELECT * FROM renamed_casted