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
),
final_with_filled_app_type as (
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
),

-- stage for merging rows of timestamp and appointment_type
dupl_to_merge as (
    select customer_id from final_with_filled_app_type group by 1 having count(*) > 3
),
groups_type_two_prepared as (
    select
        c.customer_id,
        sum(case when appointment_timestamp is null then 1 else 0 end) as nulls_timestamp,
        sum(case when appointment_type is null then 1 else 0 end) as nulls_type
    from final_with_filled_app_type c
    join dupl_to_merge d on c.customer_id = d.customer_id
    group by 1
),
groups_type_two as (
    select
        customer_id,
        'type_2' group_type
    from groups_type_two_prepared
    where nulls_timestamp = nulls_type
),
final_with_merged_timestamps_and_types as (
    select
        c.customer_id,
        c.appointment_timestamp,
        group_type,
        case when group_type = 'type_2' and appointment_type is null then 
            lead(appointment_type) over (partition by c.customer_id order by appointment_timestamp)
            else appointment_type
        end as appointment_type
    from final_with_filled_app_type c
    left join groups_type_two g on c.customer_id = g.customer_id
)

select
    *
from final_with_merged_timestamps_and_types
where appointment_timestamp is not null and appointment_type is not null
-- we filter them out for analysis
-- but we should alert the operations team every time there's an incomplete appointment created
