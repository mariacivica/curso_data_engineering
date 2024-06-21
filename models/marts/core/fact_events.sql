{{
  config(
    materialized='table'
  )
}}

WITH stg_events AS 
(
    SELECT *
    FROM {{ ref("stg_sql_server_dbo__events") }}
)

SELECT
    event_id
    , session_id
    , user_id
    , order_id
    , product_id
    , event_type
    , page_url
    , is_valid_page_url
    , created_at_utc_dma
    , created_at_utc
    , date_load
    
FROM stg_events