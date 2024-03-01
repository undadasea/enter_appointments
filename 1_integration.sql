-- Orders
| order_date          | customer_id | postal_code | account_type |
| ------------------- | ----------- | ----------- | ------------ |
| 2023-09-06 03:00:00 | 7c0b78693f  | 1475.0      | A            |
| 2023-09-08 01:00:00 | 302b577b16  |             | A            |

create table enter.order (
    order_date timestamp,
    customer_id text,
    postal_code numeric,
    account_type text
);
\copy enter.order from '/Users/undadasea/projects/enter_challenge/orders.csv' with csv header;

-- Appointments
| customer_id | timestamp           | type                |
| ----------- | ------------------- | ------------------- |
| ff58fb3560  | 2024/01/10 11:45:00 | final_call          |
| 33dde97d25  | 2023/10/27 13:30:00 | on_site_appointment |
| 2bd1df73e4  |                     | on_site_appointment |


create table enter.appointments(
    customer_id text,
    timestamp timestamp,
    type text
);

\copy enter.appointments from '/Users/undadasea/projects/enter_challenge/appointments.csv' with csv header;