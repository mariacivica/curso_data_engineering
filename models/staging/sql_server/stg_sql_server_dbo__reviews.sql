--  Incremental
{{ config(
    materialized='incremental',
    unique_key = 'review_id'
    ) 
}}

--  Extracción de la fuente origen (tabla origen). 
WITH src_reviews AS (
    SELECT * 
    FROM {{source('sql_server', 'reviews')}}

    {% if is_incremental() %}
        AND _fivetran_synced > (select max(date_load) from {{ this }}) 
    {% endif %}
),

--  Transformaciones y conversiones.
renamed_casted AS (
    SELECT
        review_id::varchar(64) AS review_id -- aseguramos que cada registro tenga una única clave única para evitar posibles problemas futuros
        , decode(product_id,'','unknown',null,'unknown',product_id)::varchar(64) AS product_id -- si product_id es cadena vacia o null devuelve unknown, sino devuelve el product_id.
        , quality_rating::varchar(64) AS quality_rating
        , usability_rating::varchar(64) AS usability_rating
        , value_for_money_rating::varchar(64) AS value_for_money_rating
        , delivery_speed_rating::varchar(64) AS delivery_speed_rating
        , CONVERT_TIMEZONE('UTC', _fivetran_synced)::timestamp AS date_load -- Conversión a UTC.

    FROM src_reviews
    )
SELECT * FROM renamed_casted