with orders as (
    select * from {{ ref('stg_orders') }}
),
appointments as (
    select * from {{ ref('stg_appointments') }}
),

app_with_time_to as (
    select
        o.customer_id,
        o.order_timestamp,
        o.order_postal_code,
        o.account_type,
        a.appointment_timestamp,
        a.appointment_type,
        DATE_PART('day', appointment_timestamp - order_timestamp) as time_to_appointment_in_days
    from appointments as a
    left join orders as o on o.customer_id = a.customer_id
    -- we won't show here the new orders with no appointments yet
    -- because this is the analytical mart for historical data.
    -- I'd show 'online analytics' in a separate mart
)

select
    customer_id,
    order_timestamp,
    order_postal_code,
    account_type,
    appointment_timestamp,
    appointment_type,
    case
        when time_to_appointment_in_days - lag(time_to_appointment_in_days) over (partition by customer_id order by appointment_timestamp)
            is null
        then time_to_appointment_in_days
        else time_to_appointment_in_days - lag(time_to_appointment_in_days) over (partition by customer_id order by appointment_timestamp)
    end as time_to_appointment_in_days
from app_with_time_to
