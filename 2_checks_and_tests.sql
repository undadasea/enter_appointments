-- Check duplicates: should be max 3 rows.

with dupl as (
    select customer_id from enter.customer_interactions group by 1 having count(*) > 3
)

select
    count(distinct c.customer_id)
from enter.customer_interactions c
join dupl d on c.customer_id = d.customer_id
;
-- 722 customer with duplicated appointments


with dupl as (
    select customer_id from enter.customer_interactions group by 1 having count(*) > 3
)

select
    c.*
from enter.customer_interactions c
join dupl d on c.customer_id = d.customer_id
order by customer_id, appointment_timestamp
;
-- examples
 customer_id |   order_timestamp   | order_postal_code | account_type | appointment_timestamp |  appointment_type   
-------------+---------------------+-------------------+--------------+-----------------------+---------------------
 0054bd306a  | 2023-09-15 02:00:00 |              4474 | A            | 2023-09-25 11:45:00   | on_site_appointment
 0054bd306a  | 2023-09-15 02:00:00 |              4474 | A            | 2023-10-13 11:45:00   | project_call
 0054bd306a  | 2023-09-15 02:00:00 |              4474 | A            | 2023-11-03 11:15:00   | final_call
 0054bd306a  | 2023-09-15 02:00:00 |              4474 | A            |                       | final_call
 0054bd306a  | 2023-09-15 02:00:00 |              4474 | A            |                       | final_call
 0079dafcf7  | 2023-10-05 00:00:00 |                   | A            | 2023-10-25 08:15:00   | on_site_appointment
 0079dafcf7  | 2023-10-05 00:00:00 |                   | A            | 2023-11-01 09:30:00   | project_call
 0079dafcf7  | 2023-10-05 00:00:00 |                   | A            | 2023-11-10 14:15:00   | final_call
 0079dafcf7  | 2023-10-05 00:00:00 |                   | A            | 2023-11-13 15:15:00   | final_call
 0079dafcf7  | 2023-10-05 00:00:00 |                   | A            | 2023-12-13 15:00:00   | final_call

-- ids: '0054bd306a', '0079dafcf7', '00a4b77f29', '02b74921c5', '04c8ab5dfb', '066a15dde7', '067a953659'

-- decision on duplicated appointments with the same type: take the latest one
-- data after implementation:
-- 63 duplicates remain

select
    *
from enter.customer_interactions
where customer_id in ('0054bd306a', '0079dafcf7', '00a4b77f29', '02b74921c5', '04c8ab5dfb', '066a15dde7', '067a953659')
order by customer_id, appointment_timestamp
;

 customer_id |   order_timestamp   | order_postal_code | account_type | appointment_timestamp |  appointment_type   
-------------+---------------------+-------------------+--------------+-----------------------+---------------------
 0054bd306a  | 2023-09-15 02:00:00 |              4474 | A            | 2023-09-25 11:45:00   | on_site_appointment
 0054bd306a  | 2023-09-15 02:00:00 |              4474 | A            | 2023-10-13 11:45:00   | project_call
 0054bd306a  | 2023-09-15 02:00:00 |              4474 | A            | 2023-11-03 11:15:00   | final_call
 0079dafcf7  | 2023-10-05 00:00:00 |                   | A            | 2023-10-25 08:15:00   | on_site_appointment
 0079dafcf7  | 2023-10-05 00:00:00 |                   | A            | 2023-11-01 09:30:00   | project_call
 0079dafcf7  | 2023-10-05 00:00:00 |                   | A            | 2023-12-13 15:00:00   | final_call


-- investigating 63 duplicates
with dupl as (
    select customer_id from enter.customer_interactions group by 1 having count(*) > 3
)

select
    c.*
from enter.customer_interactions c
join dupl d on c.customer_id = d.customer_id
order by customer_id, appointment_timestamp
;

 customer_id |   order_timestamp   | order_postal_code | account_type | appointment_timestamp |  appointment_type   
-------------+---------------------+-------------------+--------------+-----------------------+---------------------
 ----- type 1 of inconsistency
 015e83f32a  | 2023-09-21 01:00:00 |             28843 | A            | 2023-10-18 18:15:00   | on_site_appointment
 015e83f32a  | 2023-09-21 01:00:00 |             28843 | A            | 2023-10-25 09:30:00   | project_call
 015e83f32a  | 2023-09-21 01:00:00 |             28843 | A            | 2023-11-27 14:00:00   | final_call
 015e83f32a  | 2023-09-21 01:00:00 |             28843 | A            |                       | 
 ----- type 2 of inconsistency
 1243e1acaa  | 2023-09-08 00:00:00 |             67538 | A            | 2023-09-15 17:15:00   | on_site_appointment
 1243e1acaa  | 2023-09-08 00:00:00 |             67538 | A            | 2023-09-26 10:45:00   | project_call
 1243e1acaa  | 2023-09-08 00:00:00 |             67538 | A            | 2023-10-23 15:15:00   | 
 1243e1acaa  | 2023-09-08 00:00:00 |             67538 | A            |                       | final_call
 ----- type 3 of inconsistency
 2a96cc34e7  | 2023-10-05 01:00:00 |             50394 | A            | 2023-10-25 09:15:00   | on_site_appointment
 2a96cc34e7  | 2023-10-05 01:00:00 |             50394 | A            | 2023-11-01 09:15:00   | project_call
 2a96cc34e7  | 2023-10-05 01:00:00 |             50394 | A            | 2023-11-13 15:30:00   | 
 2a96cc34e7  | 2023-10-05 01:00:00 |             50394 | A            | 2023-12-13 14:30:00   | final_call
 
-- Appointments with no duplicates but with nulls in type
 ---- type 4 of inconsistency
 0071c337ce  | 2023-10-13 00:00:00 |             30201 | A            | 2023-11-10 10:00:00   | on_site_appointment
 0071c337ce  | 2023-10-13 00:00:00 |             30201 | A            | 2023-11-10 10:15:00   | 
 0071c337ce  | 2023-10-13 00:00:00 |             30201 | A            | 2023-12-01 13:00:00   | final_call

-- ! Disclaimer
-- Before making any decisions, I would consult the data owners i.e. operations team and the stakeholders

-- My opinion on how to proceed:
-- type 1: ignore
-- because since we have neither - timestamp nor type, I'd think this entry was created by mistake
-- type 2: merge
-- from the looks of it, seems like a backend error
-- type 3: let it be
-- type 4: fill
-- only those groups, where it's obvious from previous data
-- appointment groups of three where known types are in their right place

-- type 1:
-- fixed in staging layer

-- type 4:
-- fixed in staging layer

-- type 2:
-- fill with the following type
-- fixed in staging layer
-- example
select
    *
from enter.customer_interactions
where customer_id = '1243e1acaa'
order by appointment_timestamp
;
 customer_id |   order_timestamp   | order_postal_code | account_type | appointment_timestamp |  appointment_type   
-------------+---------------------+-------------------+--------------+-----------------------+---------------------
 1243e1acaa  | 2023-09-08 00:00:00 |             67538 | A            | 2023-09-15 17:15:00   | on_site_appointment
 1243e1acaa  | 2023-09-08 00:00:00 |             67538 | A            | 2023-09-26 10:45:00   | project_call
 1243e1acaa  | 2023-09-08 00:00:00 |             67538 | A            | 2023-10-23 15:15:00   | final_call
(3 rows)