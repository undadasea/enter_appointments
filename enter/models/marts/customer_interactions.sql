with orders as (
    select * from {{ ref('stg_orders') }}
),
appointments as (
    select * from {{ ref('stg_appointments') }}
)

select
    o.customer_id,
    o.order_timestamp,
    o.order_postal_code,
    o.account_type,
    a.appointment_timestamp,
    a.appointment_type
from orders as o
full outer join appointments as a on o.customer_id = a.customer_id
