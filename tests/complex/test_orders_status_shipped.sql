/*Se comprueba que el pedido tenga un identificador de seguimiento asignado,
un servicio de envio y no la fecha de llegada ni los dias de envio*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__orders') }}
WHERE STATUS_ORDER = 'shipped'    
                            AND TRACKING_ID =''
                            AND SHIPPING_SERVICE=''
                            AND DELIVERED_AT_UTC is not null 
                            AND DAYS_TO_DELIVER is not null