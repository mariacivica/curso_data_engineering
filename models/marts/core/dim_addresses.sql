with stg_sql_server_dbo__addresses as(

    select * from {{ ref('stg_sql_server_dbo__addresses') }}
),

dim_addresses AS(
  
    SELECT
        address_id,
        address,
        address_number,
        address_name,
        country,
        state,
        zipcode,
    FROM stg_sql_server_dbo__addresses
)

select * from dim_addresses