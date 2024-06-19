-- Este modelo incremental de eventos.
-- Al ser incremental, el modelo solo procesa datos nuevos desde la ultima ejecucion


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
        created_at_utc_dma,
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
        b.user_id,  
        d.product_id,
        a.order_id,  
        a.event_type,
        f.date_key,
        a.created_at_utc_dma,
        a.page_url,
        a.date_load,

        -- La columna batch_id serán los valores de las filas que se generan
        '{{invocation_id}}' AS batch_id
    FROM stg_events a 
    LEFT JOIN dim_users b ON b.user_id = a.user_id
    LEFT JOIN dim_products d ON d.product_id = a.product_id
    LEFT JOIN dim_date f ON f.date_day = a.created_at_utc_dma
)

SELECT * FROM fact_events
ORDER BY created_at_utc_dma
