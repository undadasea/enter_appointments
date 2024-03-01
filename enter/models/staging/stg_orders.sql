with orders as (
    select * from {{ source("postgres", "order") }}
)

select
    -- ids
    customer_id,

    -- timestamps
    order_date as order_timestamp,
    
    -- numerics
    cast(postal_code as integer) as order_postal_code,

    -- text
    account_type
from orders
