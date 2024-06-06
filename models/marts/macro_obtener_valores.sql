-- Una macro es un test generico que se puede reutilizar --

{% set event_types = obtener_valores(ref("stg_sql_server_dbo__events"), "event_type") %}
with
    stg_events as (select * from {{ ref("stg_sql_server_dbo__events") }}),

    renamed_casted as (
        select
            user_id,
            {%- for event_type in event_types %}
                sum(
                    case when event_type = '{{event_type}}' then 1 end
                ) as {{ event_type }}_amount
                {%- if not loop.last %},{% endif -%}
            {% endfor %}
        from stg_events
        group by 1
    )

select *
from renamed_casted
