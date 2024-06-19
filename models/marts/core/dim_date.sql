-- 

{{ config(materialized='table') }}
WITH fechaa AS (
{{ dbt_date.get_date_dimension("2020-01-01", "2025-12-31") }}
)

Select  to_char(date_day, 'YYYYMMDD') AS date_key
, date_day
, day_of_week
, day_of_month
, day_of_year
, month_of_year
, quarter_of_year
from fechaa
order by date_day