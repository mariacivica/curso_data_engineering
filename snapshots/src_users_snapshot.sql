{% snapshot src_users_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='timestamp',
      updated_at='updated_at', 
      invalidate_hard_deletes=True,
    )
}}
-- strategy='timestamp' ; updated_at='_fivetran_synced'
-- se usa el atributo _fivetran_synced para determinar cuando se actualizaron los datos en la fuente de origen (users)
-- dbt identificará los cambios en los datos según la marca de tiempo indicada en _fivetran_synced
-- si _fivetran_synced cambia para un registro, dbt lo considerará como una actualización o un nuevo registro.

select * from {{ source('sql_server', 'users') }}

{% endsnapshot %}