with orders as (
    select * from {{ ref('stg_orders') }}
),
customer_interactions as (
    select * from {{ ref('customer_interactions') }}
),

customer_interactions_with_total_time as (
    select
        *,
        sum(time_to_appointment_in_days) over (partition by customer_id) as total_order_processing_days
    from customer_interactions
),

amount_apps as (
    select
        count(case when appointment_type = 'on_site_appointment' then customer_id else null end) as amount_on_site,
        count(case when appointment_type = 'project_call' then customer_id else null end) as amount_project_call,
        count(case when appointment_type = 'final_call' then customer_id else null end) as amount_final_call,
        avg(total_order_processing_days) as avg_order_processing_days
    from customer_interactions_with_total_time
),
amount_orders as (
    select
        count(distinct customer_id) as amount_orders
    from orders as o
    -- only if in orders we don't have "new orders" which we haven't started processing
    -- at the moment it's impossible to distingiush between "dropped off" and "to be processed"
),
final_total as (
    select
        cast(null as date) as month,
        amount_orders,
        amount_on_site,
        amount_project_call,
        amount_final_call,
        round(1::numeric, 2) as orders_rate,
        round(amount_on_site::numeric / amount_orders, 2) as on_site_rate,
        round(amount_project_call::numeric / amount_orders, 2) as project_call_rate,
        round(amount_final_call::numeric / amount_orders, 2) as final_call_rate,
        round(avg_order_processing_days::numeric, 2) as avg_order_processing_days
    from amount_apps
    cross join amount_orders
),

amount_apps_and_orders_monthly as (
    select
        date_trunc('month', order_timestamp) as month,
        count(distinct customer_id) as amount_orders,
        count(case when appointment_type = 'on_site_appointment' then customer_id else null end) as amount_on_site,
        count(case when appointment_type = 'project_call' then customer_id else null end) as amount_project_call,
        count(case when appointment_type = 'final_call' then customer_id else null end) as amount_final_call,
        avg(total_order_processing_days) as avg_order_processing_days
    from customer_interactions_with_total_time
    group by 1
),
final_monthly as (
    select
        date(month) as month,
        amount_orders,
        amount_on_site,
        amount_project_call,
        amount_final_call,
        round(1::numeric, 2) as orders_rate,
        round(amount_on_site::numeric / nullif(amount_orders, 0), 2) as on_site_rate,
        round(amount_project_call::numeric / nullif(amount_orders, 0), 2) as project_call_rate,
        round(amount_final_call::numeric / nullif(amount_orders, 0), 2) as final_call_rate,
        round(avg_order_processing_days::numeric, 2) as avg_order_processing_days
    from amount_apps_and_orders_monthly
    where month is not null
)

select * from final_total
union all
select * from final_monthly
