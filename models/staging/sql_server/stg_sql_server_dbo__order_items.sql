--  Modelo diseñado para procesar de manera incremental los datos de la tabla "order_items", lo que significa que solo procesará los 
--  nuevos datos que se han añadido o modificado desde la última ejecución.
{{
  config(
    materialized='incremental',
    unique_key='order_item_id'
  )
}}

WITH src_order_items AS (
    SELECT * 
    FROM {{source('sql_server', 'order_items')}}
    
    -- Condicional que verifica si el modelo se está ejecutando de forma incremental, si es que si aplica la condicion para filtrar los datos de entrada
    {% if is_incremental() %}
        where _fivetran_synced > (select max(date_load) from {{ this }}) -- condición que asegura la selección de registros nuevos o modificados desde la 
    {% endif %}                                                          -- ultima ejecución del modelo
),

renamed_casted AS (
    SELECT
       {{ my_generate_surrogate_key(['order_id', 'product_id']) }}::varchar(64) AS order_item_id -- usa las columnas order_id y product_id para generar el surrogate key 
                                                                                                 -- cada combinacion representa un producto específico en un pedido específico
        , decode(order_id,'','unknown',null,'unknown',order_id)::varchar(64) AS order_id -- si order_id es cadena vacia o null devuelve unknown, sino devuelve el order_id.
        , decode(product_id,'','unknown',null,'unknown',product_id)::varchar(64) AS product_id -- si product_id es cadena vacia o null devuelve unknown, sino devuelve el product_id.
        , quantity::integer AS quantity
        , CONVERT_TIMEZONE('UTC', _fivetran_synced)::timestamp AS date_load -- Conversión a UTC.
    FROM src_order_items
    )

SELECT * FROM renamed_casted ORDER BY order_id