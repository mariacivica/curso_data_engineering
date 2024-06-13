-- Se captura una vista de los datos de la tabla "promos" 

{% snapshot src_promos_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='md5(concat(promo_id, discount))',
      strategy='timestamp',
      updated_at='_fivetran_synced',
      invalidate_hard_deletes=True,
    )
}}

-- strategy='timestamp' ; updated_at='_fivetran_synced'
-- se usa el atributo _fivetran_synced para determinar cuando se actualizaron los datos en la fuente de origen (promos)
-- dbt identificará los cambios en los datos según la marca de tiempo indicada en _fivetran_synced
-- si _fivetran_synced cambia para un registro, dbt lo considerará como una actualización o un nuevo registro.

select  md5(concat(promo_id, discount)) as id
,*
from {{ source('sql_server', 'promos') }}

{% endsnapshot %}