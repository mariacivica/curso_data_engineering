/*Se comprueba que haya información (contenido) asociado al seguimiento (tracking_id), 
esta información es 
servicio de envío (shipping_service) y fechas relevantes (created, delivered y days) 
en pedidos marcados como “entregados”.
Los pedidos entregados tienen que tener 100% un tracking un servicio de envio y fechas*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__orders') }}
WHERE STATUS_ORDER = 'delivered' AND TRACKING_ID is null 
                            AND SHIPPING_SERVICE=''
                            AND CREATED_AT_UTC=''
                            AND DELIVERED_AT_UTC is null
                            AND DAYS_TO_DELIVER is null
