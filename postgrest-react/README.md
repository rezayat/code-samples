# postgrest-react

A proof of concept stack with **postgrest** wrapping a postgres database and exposing schema "public" as an endpoint.

- **Authentication** is implemented on the database level via schema `basic_auth` using table `login_USERS` and function `login()` to store and authenticate login_users.
- **Authorization** is implemented on the database level via schema `basic_auth` using function 'sign()' to generate JWT tokens.

**React App**
- Authenticates login_users using an **HTTP POST request** to (postgrest)/rpc/login
- Gets applicants using an **HTTP GET request** to (postgrest)/applicants
- Adds applicants using an **HTTP POST request** to (postgrest)/applicants

## How to run

```bash
$ docker-compose build
$ docker-compose up
$ python -m webbrowser http://localhost:1234
```

## Infrastructure

The current configuration allows for a containerized application that uses the following architecture:

```
    webserver: nginx
        == Reverse Proxy =>
            :1234/api/ ==> rest: 3000 (Postgrest)
                ==> database: 5432 (postgres database)
            :1234/login ==> rest: 3000/rpc/login (Postgrest User Login and JWT token Generator)
```

## Database Main Structure

```yaml
database: earth
    schema: public   # main data schema (for api access)
        table: applicants
            column: email
            column: row_role
            ...

    schema: basic_auth  # authentication schema
        table: login_users
            column: username
            column: pass
            column: role

        function: login
        function: sign
```

## Fixture Data

**JWT Secret Key**: not_secret_at_all

You can login using the following credentials:

| username | password  | role      |
|----------|-----------|-----------|
| pg       | 1234      | postgres  |
| admin    | 1234      | admin     |
| omar     | 1234      | employee  |
| rawad    | 1234      | employee  |

## Row Level Security

**Row Level Security** enabled on table applicants as follows:

- Role **postgres** can view (select) all records
- Roles can view their own records only
- All roles can insert into table applicants

## Testing Authentication

```bash
# Failed Login

$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"incorrect_pass"}' http://localhost:1234/login
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"missing_password"}' http://localhost:1234/login
$ curl -X POST -H 'Content-Type: application/json' -d '{"pass":"missing_email"}' http://localhost:1234/login

# Successful Login

# log in as user "pg" of role "postgres"
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"pg","pass":"1234"}' http://localhost:1234/login
# log in as user "rawad" of role "employee"
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"1234"}' http://localhost:1234/login
```

## Test Authorization

```bash
$ curl -H 'Authorization: Bearer some.invalid.token' http://localhost:1234/api/applicants

<< Invalid JWT Token >>

$ curl http://localhost:1234/api/applicants

<< Unauthorized Access >>

$ curl -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiZW1wbG95ZWUiLCJ1c2VybmFtZSI6InJhd2FkIiwiZXhwIjoxNTAxMjQ3MDg0fQ.NqTJiHS1ABEi7M14OnCrjPHZxb9XXgRt8N0XsQEQH1o' http://localhost:1234/api/applicants

<< Success only views records for "employee" >>

$ curl -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoicG9zdGdyZXMiLCJ1c2VybmFtZSI6InBnIiwiZXhwIjoxNTAxMjQ3MDMwfQ.uC0xKCBHwjWchKiZNLFOB-555iVuSpJthtH81hSEXOY' http://localhost:1234/api/applicants

<< Success only views records for "postgres" (all records) >>

```
