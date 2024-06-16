with stg_budget as(

    select * from {{ ref('stg_google_sheets__budget') }}
),

dim_products as (

    select
        product_id_1,
        product_id_2
    from {{ ref('dim_products') }}
),

dim_date as (
    select
        date_key,
        date_day
    from {{ ref('dim_date') }}
),

fact_budget as(
    
    select
        a.budget_id,
        b.product_id_1,
        a.quantity,
        c.date_key

    from stg_budget a
    left join dim_products b on b.product_id_2 = a.product_id
    left join dim_date c on c.date_day = a.date
)

SELECT * FROM fact_budget ORDER BY 4 -- ordena los resultados por date_key