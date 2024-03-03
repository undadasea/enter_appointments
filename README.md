# enter_appointments
_This repository is a submission of a challenge._ \
\
Project architecture looks like this: \
<img width="738" alt="image" src="https://github.com/undadasea/enter_appointments/assets/25858004/03a47d31-a843-4242-bc78-e89dd2ba7944">

It consists of a 
- dbt project `/enter`
- SQL file `integration`
- SQL file `checks_and_tests`

In the `integration` file you can find queries for creating proper tables in PostgresSQL to integrate the source csv files. In the `checks_and_tests` file there are examples of data inconsistencies and solutions for them. \
\
Main logic of the challenge is at `/enter/models/`. There's a two layers of data models: staging and marts. At staging there's cleaned data with fixed inconsistencies. At the mart layer you can find `customer_interactions` mart which combines orders and appointments for easier analysis. And the second mart `order_funnel` which shows aggregated information about customer conversion. 

To run it locally
- clone repository `$ git clone git@github.com:undadasea/enter_appointments.git`
- set up python env `python3 -m venv venv_dbt`
- activate the environment `source venv_dbt/bin/activate`
- install dbt `pip install dbt-postgres`
- copy `profiles_example.yml` to the directory .dbt as the following `~/.dbt/profiles.yml`
- [setup Postgres](https://ubuntu.com/server/docs/databases-postgresql)
- create schema `enter` and role `enter`
- give permissions on schema `enter` to the role `enter`
- use queries from `1_integration.sql` to upload csv files
- test the connection between the dbt project and your local postgres `dbt debug`
