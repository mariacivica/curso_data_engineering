with stg_sql_server_dbo__users as (

    select * from {{ ref('stg_sql_server_dbo__users') }}
),

dim_users as (
    select
        user_id,
        address_id, --referencia a la direccion 
        first_name || ' ' || last_name as full_name,
        email,
        phone_number,
        created_at_utc,
        updated_at_utc
        
    from stg_sql_server_dbo__users 
)

select * from dim_users