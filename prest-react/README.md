# prest-react

A proof of concept stack with react as a frontend and prest wrapping a postgres database and exposing a schema as endpoint. Authorization is done as JWT with tokens
placed in client explicitly. (until custom endpoint is added or other)

## How to run

```
$ docker-compose build
$ docker-compose up
$ python -m webbrowser http://localhost:1234/
```

*Note:* API URL: http://localhost:1234/api/users_dev/public/users (JWT Enabled)

## Infrastructure

The current configuration allows for a containerized application that uses the following architecture:

```
    Webserver(Nginx)
        == Reverse Proxy =>
            :1234/ ==> Frontend: 5000 (Pushstate Server)
            :1234/app/ ==> App: 4000 (Flask User Login and JWT token Generator)
            :1234/api/ ==> Backend: 3000 (PRest)
                ==> Db: 5432 (Postgres)
```

## JWT Authorization

Added a seperate container for handling JWT Authorization (a simple flask appliation)

The flask application implements a user login mechanism that provides the **logged-in** user with an authorization token.
The **React App stores the token** and calls _PRest Web Service_ providing the token through **HTTP Request Header 'Authorization'**

**JWT token key : 'not_secret_at_all'**

You can login using the following credentials:

| username | password  |
|----------|-----------|
| admin    | 123456789 |
| omar     | 987654321 |
| rawad    | 123456    |

To test the JWT you can use curl as follows:

``` bash
$ curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNzYyODk2Mzk4IiwibmFtZSI6IlJhd2FkIEdoeiJ9.KmLBqe3NsGX2VHHJ2J8MVd3fxTn1i6GLAnNOLIWI8cY" localhost:1234/api/users_dev/public/users
```
