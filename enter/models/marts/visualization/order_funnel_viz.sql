with funnel as (
    select * from {{ ref('order_funnel') }}
)

select
    'orders' as stage,
    amount_orders as amount,
    orders_rate as rate
from funnel
where month is null

union all

select
    'on_site_appointment' as stage,
    amount_on_site as amount,
    on_site_rate as rate
from funnel
where month is null

union all

select
    'project_call' as stage,
    amount_project_call as amount,
    project_call_rate as rate
from funnel
where month is null

union all

select
    'final_call' as stage,
    amount_final_call as amount,
    final_call_rate as rate
from funnel
where month is null
