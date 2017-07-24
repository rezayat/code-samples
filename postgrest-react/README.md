# postgrest-react

A proof of concept stack with **postgrest** wrapping a postgres database and exposing schema "public" as an endpoint.
 - **Authentication** is implemented on the database level via schema "basic_auth" using table 'users' and function 'login()' to store and authenticate users.
 - **Authorization** is implemented on the database level via schema "basic_auth" using function 'sign()' to generate JWT tokens.

## How to run

```bash
$ docker-compose build
$ docker-compose up
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
    schema: public   # main data schema
        table: animals
            column: ...
            column: ...
        table: ...
            column: ...
            column: ...
        table: ...
            column: ...

    schema: basic_auth  # authentication schema
        table: users
            column: email
            column: pass
            column: role

        function: login
        function: sign
```

## Data used

**JWT token key : 'not_secret_at_all'**

You can login using the following credentials:

| username | password  |
|----------|-----------|
| admin@gmail.com    | 123456789 |
| omar@gmail.com     | 987654321 |
| rawad@gmail.com    | 123456    |


## Test login and token generating

```bash
# failing logins

$ curl -X POST -H 'Content-Type: application/json' -d '{"email":"rawad@gmail.com","pass":"incorrect_pass"}' http://localhost:1234/login
$ curl -X POST -H 'Content-Type: application/json' -d '{"email":"missing@password.com"}' http://localhost:1234/login
$ curl -X POST -H 'Content-Type: application/json' -d '{"pass":"missing_email"}' http://localhost:1234/login
```

```bash
# successfull login

$ curl -X POST -H 'Content-Type: application/json' -d '{"email":"rawad@gmail.com","pass":"123456"}' http://localhost:1234/login
```

## Test access
```bash
# invalid jwt token

$ curl -H -i 'Authorization: Bearer invalid.jwt.token' http://localhost:1234/api/animals
```

```bash
# unauthorized access

$ curl -i http://localhost:1234/api/animals
```

```bash
# authorized access

$ curl -H -i 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoicG9zdGdyZXMiLCJlbWFpbCI6InJhd2FkQGdtYWlsLmNvbSIsImV4cCI6MTUwMDg5NTk4OX0.Vdud2_Gu1RMa81fyGMNonZbnEywKhd7yU2NohyaBfWs' http://localhost:1234/api/animals
```
