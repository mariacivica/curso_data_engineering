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
        , coalesce(_FIVETRAN_DELETED, false) as _fivetran_deleted
        , CONVERT_TIMEZONE('UTC', _fivetran_synced) AS _fivetran_synced_utc
    FROM src_users
    )

    SELECT * FROM renamed_casted
