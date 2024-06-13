
{% snapshot src_order_items_snapshot %}

{{
    config(
      target_schema='snapshots',
      strategy='check',
      unique_key="id",
      check_cols=['quantity','product_id'],   
    )
}}

-- strategy='check' ; check_cols=['---','---']

select 
    md5(concat(order_id, product_id)) as id
    ,* 
from {{ source('sql_server', 'order_items') }}

{% endsnapshot %}
