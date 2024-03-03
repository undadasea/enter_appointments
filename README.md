# enter_appointments
_This repository is a submission of a challenge._ \
\
Project architecture looks like this: \
<img width="738" alt="image" src="https://github.com/undadasea/enter_appointments/assets/25858004/03a47d31-a843-4242-bc78-e89dd2ba7944">

It consists of a 
- dbt project `enter`
- SQL file `integration`
- SQL file `checks_and_tests`

In the `integration` file you can find queries for creating proper tables in PostgresSQL to integrate the source csv files. In the `checks_and_tests` file there are examples of data inconsistencies and solutions for them. 
