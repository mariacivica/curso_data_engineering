with stg_budget as(

    select * from {{ ref('stg_google_sheets__budget') }}
),

dim_products as (
    from {{ ref('dim_products') }}
),

dim_date as (
    from {{ ref('dim_date') }}
),

fact_budget as(
    
    select
        a.budget_id,
        b.product_id,
        a.quantity,
        c.date_key

    from stg_budget a
    left join dim_products b on b.product_id = a.product_id
    left join dim_date c on c.month_of_year = a.date
)

SELECT * FROM fact_budget ORDER BY 4 -- ordena los resultados por date_key