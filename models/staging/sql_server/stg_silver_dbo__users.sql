{{
  config(
    materialized='view'
  )
}}

WITH src_users AS (
    SELECT * 
    FROM {{source('sql_server', 'users')}}
    ),

renamed_casted AS (
    SELECT
        USER_ID
        , ADDRESS_ID
        , FIRST_NAME
        , LAST_NAME
        , PHONE_NUMBER
        , EMAIL
        -- la validacion del email tambien se podria hacer como test unitario para comprobar que no hay emails incorrectos en la tabla
        , coalesce (regexp_like(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')= true,false) AS IS_VALID_EMAIL
        , CONVERT_TIMEZONE('UTC', CREATED_AT) AS CREATED_AT_UTC
        , CONVERT_TIMEZONE('UTC', CREATED_AT) AS UPDATED_AT_UTC
        , TOTAL_ORDERS -- Este campo esta vacio para todos los usuarios asi que con el campo total_orders_update hacemos un conteo y un agrupado con la tabla de orders
        , coalesce(_FIVETRAN_DELETED, false) as _fivetran_deleted
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc
    FROM src_users
    ),

    -- Creo orders_user para contar de la tabla de orders los pedidos por user_id
    orders_user AS (
        SELECT
            USER_ID
            , COUNT(ORDER_ID) AS TOTAL_ORDERS_UPDATE
        FROM {{ ref('stg_silver_dbo__orders') }}
        GROUP BY USER_ID
    )

   -- En vez de hacer un select solo del renamed_casted, incluyo la nueva columna calculada a partir de la tabla orders
    SELECT
        r.* 
        , o.TOTAL_ORDERS_UPDATE
    FROM renamed_casted r
    LEFT JOIN orders_user o
        ON r.USER_ID=o.USER_ID
