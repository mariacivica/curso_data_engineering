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
        user_id::varchar(64) AS user_id
        , address_id::varchar(64) AS address_id
        , first_name::varchar(64) AS first_name
        , last_name::varchar(64) AS last_name
        , phone_number::varchar(64) AS phone_number
        , email::varchar(64) AS email
        -- la validacion del email tambien se podria hacer como test unitario para comprobar que no hay emails incorrectos en la tabla
        , coalesce (regexp_like(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')= true,false) AS IS_VALID_EMAIL
        , CONVERT_TIMEZONE('UTC', CREATED_AT)::timestamp AS CREATED_AT_UTC
        , CONVERT_TIMEZONE('UTC', CREATED_AT)::timestamp AS UPDATED_AT_UTC
        , CONVERT_TIMEZONE('UTC', _fivetran_synced)::timestamp AS date_load
    FROM src_users
    )

    SELECT * FROM renamed_casted
