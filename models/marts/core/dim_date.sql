-- Como esta dimension la utilizan varias tablas va dentro del core
-- Se crea una tabla "fechaa" que contiene una dimension de fechas desde el 01-01-2010 hasta el 31-12-2030 
-- luego selecciona columnas específicas relacionadas con dias, meses y trimestres de estas fechas.
-- La salida final será una tabla materializada que contiene las columnas seleccionadas en este rango de fechas.

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