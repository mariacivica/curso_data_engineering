/*Este test verifca que un pedido en preparacion no tiene que tener un 
identificador de seguimiento asignado, ni una fecha estimada de entrega 
ya que suele asignarse una vez el pedido ha sido enviado, ni una fecha de entrega
ni el servicio de envio que tambien suele ser determinado una vez el pedido 
esta listo para ser enviado*/
SELECT *
FROM {{ ref('stg_sql_server_dbo__orders') }}
WHERE STATUS_ORDER = 'preparing'  AND TRACKING_ID is not null 
                            AND ESTIMATED_DELIVERY is not null 
                            AND DELIVERED_AT_UTC is not null
                            AND SHIPPING_SERVICE !=''