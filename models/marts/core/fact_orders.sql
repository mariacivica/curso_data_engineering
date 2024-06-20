{{
  config(
    materialized='table'
  )
}}

WITH stg_orders AS
(
    SELECT *
    FROM {{ref("int_orders")}}
)

SELECT *
FROM stg_orders
