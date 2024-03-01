with appointments as (
    select * from {{ source("postgres", "appointments") }}
),
appointments_without_empty_entries as (
-- and with merged by timestamp duplicates
    select
        customer_id,
        max(timestamp) as appointment_timestamp,
        type as appointment_type
    from appointments
    where timestamp is not null or type is not null
    group by customer_id, type
),

-- stage for filling in the empty type for only obviously correct groups
correct_groups as (
    select
        customer_id,
        'correct' as group_type,
        count(*)
    from appointments_without_empty_entries a
    group by customer_id having count(*) = 3
),
app_numerated as (
    select
        a.*,
        group_type,
        row_number() over (partition by a.customer_id order by appointment_timestamp) as row_number
    from appointments_without_empty_entries a
    left join correct_groups c on a.customer_id = c.customer_id
)

select
    customer_id,
    appointment_timestamp,
    case when group_type = 'correct' and appointment_type is null then
        case when row_number = 1 then 'on_site_appointment'
             when row_number = 2 then 'project_call'
             else 'final_call'
        end
        else appointment_type
    end as appointment_type
from app_numerated
