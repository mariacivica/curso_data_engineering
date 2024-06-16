-- Este modelo incremental de eventos, ingiere datos. 
-- Al ser incremental, el modelo solo procesa datos nuevos desde la ultima ejecucion
-- Los datos de eventos tendran información adicional de usuarios y fechas

-- append_new_columns sirve para manejar los cambios automaticamente en el esquema
-- (para cuando se añadan columnas nuevas con frecuencia)

{{ config(
    materialized='incremental',
    unique_key = 'event_id',
    on_schema_change='append_new_columns', 
    tags = ["incremental_events"],
    ) 
}}

WITH stg_events AS(
    SELECT 
        event_id,
        session_id,
        user_id,
        event_type,
        product_id,
        order_id,
        page_url,
        created_at_utc as created_at_utc,
        created_at_utc::date as created_at_utc_date,
        date_load
    FROM {{ ref('stg_sql_server_dbo__events') }}

    {% if is_incremental() %}
	  WHERE date_load > (SELECT max(date_load) FROM {{ this }}) 
    {% endif %}
),

dim_users AS (
    SELECT *
    FROM {{ ref('dim_users') }}
),

dim_products AS(
    SELECT *
    FROM {{ ref('dim_products') }}
),

dim_date AS(
    SELECT * FROM {{ ref('dim_date') }}
),

-- Tabla de hechos
fact_events AS(
    SELECT
        a.event_id,
        a.session_id,
        b.user_id_1,  
        a.event_type,
        d.product_id_1,  
        a.order_id,
        f.date_key,
        to_char(date_trunc('hour', a.created_at_utc), 'HH24MI') as time_key,  -- Trunca la hora de tiempo a la más cercana (min y seg a 0) y lo convierte a cadena
        a.created_at_utc,
        a.created_at_utc::time as time,
        a.page_url,
        a.date_load,

        -- La columna batch_id serán los valores de las filas que se generan
        '{{invocation_id}}' AS batch_id
    FROM stg_events a 
    LEFT JOIN dim_users b ON b.user_id_2 = a.user_id
    LEFT JOIN dim_products d ON d.product_id_2 = a.product_id
    LEFT JOIN dim_date f ON f.date_day = a.created_at_utc
)

SELECT * FROM fact_events
ORDER BY created_at_utc
