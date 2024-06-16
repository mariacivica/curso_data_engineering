with stg_sql_server_dbo__addresses as(

    select * from {{ ref('stg_sql_server_dbo__addresses') }}
),

dim_addresses as(
  
    select
        {{my_generate_surrogate_key(['address_id','address'])}} AS address_id,
        address,
        address_number,
        address_name,
        country,
        state,
        zipcode,
    from stg_sql_server_dbo__addresses
)

select * from dim_addresses