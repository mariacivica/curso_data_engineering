/*Se comprueba que haya información asociada al seguimiento (tracking_id), 
servicio de envío (shipping_service) y fechas relevantes (created, delivered y days) 
en pedidos marcados como “entregados”.*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__orders') }}
WHERE STATUS_ORDER = 'delivered' AND TRACKING_ID is null 
                            AND SHIPPING_SERVICE=''
                            AND CREATED_AT_UTC=''
                            AND DELIVERED_AT_UTC is null
                            AND DAYS_TO_DELIVER is null