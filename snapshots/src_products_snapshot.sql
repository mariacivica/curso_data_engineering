-- Consulta que genera un id que utiliza md5 para combinar promo_id con discount. 
-- Así habrá un id unico en el snapshot

{% snapshot src_products_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='timestamp',
      updated_at='_fivetran_synced',
      invalidate_hard_deletes=True,
    )
}}
-- strategy='timestamp' ; updated_at='_fivetran_synced'
-- se usa el atributo _fivetran_synced para determinar cuando se actualizaron los datos en la fuente de origen (products)
-- dbt identificará los cambios en los datos según la marca de tiempo indicada en _fivetran_synced
-- si _fivetran_synced cambia para un registro, dbt lo considerará como una actualización o un nuevo registro.

select * from {{ source('sql_server', 'products') }}

{% endsnapshot %}