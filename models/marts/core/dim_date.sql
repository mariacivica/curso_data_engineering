-- Como esta dimension la utilizan varias tablas va dentro del core

{{ config(materialized='table') }}
WITH fechaa AS (
{{ dbt_date.get_date_dimension("2010-01-01", "2030-12-31") }}
)

Select date_day
, day_of_week
, day_of_month
, day_of_year
, month_of_year
, quarter_of_year
from fechaa