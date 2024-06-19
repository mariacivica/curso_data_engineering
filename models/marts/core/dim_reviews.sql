-- Dimension de reseñas, una reseña es unica pero un mismo producto puede tener distintas reseñas (!= ids)

with stg_sql_server_dbo__reviews as(
    
    select * from {{ ref('stg_sql_server_dbo__reviews') }}
),

dim_reviews as (

    select
        review_id,
        product_id,
        quality_rating,
        usability_rating,
        value_for_money_rating,
        delivery_speed_rating
    from stg_sql_server_dbo__reviews   
)

select * from dim_reviews