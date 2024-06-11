/*Con inner join entre orders y promos se comprueba que el order_total está 
bien  calculado
En este test aparecen valores lo que indica que hay discrepancias en la forma
en que se calculan los totales.
Para las filas en cuestion la formula falla, esto quiere decir que hay poca 
precisión de los decimales */

SELECT
    ITEM_ORDER_COST_USD,
    SHIPPING_COST_USD,
    ORDER_TOTAL_COST_USD,
    DISCOUNT_TOTAL_USD
FROM {{ ref('stg_sql_server_dbo__orders') }}
INNER JOIN {{ ref('stg_sql_server_dbo__promos') }}
USING(promo_id)
WHERE ABS((ITEM_ORDER_COST_USD + SHIPPING_COST_USD) - DISCOUNT_TOTAL_USD - ORDER_TOTAL_COST_USD) > 0.01