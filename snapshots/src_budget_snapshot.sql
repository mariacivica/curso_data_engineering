-- dbt puede "instantanear" cambios para ayudar a comprender cómo cambian los valores de una fila con el tiempo;
-- por ejemplo si un pedido el 01-02 esta en preparación y el 03-02 ha sido enviado.
-- Hay que configurar el snapshot para indicar a dbt cómo detectar cambios en los registros.

{% snapshot src_budget_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='_row',
      strategy='timestamp',
      updated_at='_fivetran_synced',
      invalidate_hard_deletes=True,
    )
}}
-- strategy='timestamp' ; updated_at='_fivetran_synced'
-- se usa el atributo _fivetran_synced para determinar cuando se actualizaron los datos en la fuente de origen (budget)
-- dbt identificará los cambios en los datos según la marca de tiempo indicada en _fivetran_synced
-- si _fivetran_synced cambia para un registro, dbt lo considerará como una actualización o un nuevo registro.

select * from {{ source('google_sheets', 'budget') }}

{% endsnapshot %}