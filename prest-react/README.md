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

### JWT in Flask

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

To run the JWT you can use curl as follows:

``` bash
$ curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNzYyODk2Mzk4IiwibmFtZSI6IlJhd2FkIEdoeiJ9.KmLBqe3NsGX2VHHJ2J8MVd3fxTn1i6GLAnNOLIWI8cY" localhost:1234/api/users_dev/public/users
```

### JWT in postgres as (sign)

Added pgsign postgres extension to the containerized postgres installation

#### To run _pgsign_ (while containers are up):

```bash
$ docker exec -ti database bash
# psql -U postgres users_dev
postgres=# select sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret');
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lI....

```

In order to call "sign" from PRest, **PRest queries** are used

#### To run PRest Queries

PRest queries are stored in files:

 ./queries_directory/directory/select_example.read.sql

**Example Query Files:**
 ./queries/users_dev/test_select.read.sql
 ./queries/users_dev/test_sign.read.sql

**Run Queries:**

```bash
$ curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNzYyODk2Mzk4IiwibmFtZSI6IlJhd2FkIEdoeiJ9.KmLBqe3NsGX2VHHJ2J8MVd3fxTn1i6GLAnNOLIWI8cY" -L http://localhost:1234/api/_QUERIES/users_dev/test_select
[{"id":1,"username":"test_user","email":"test.user@gmail.com","active":true,"created_at":"2017-06-07T01:23:45"}]
```

```bash
$ curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNzYyODk2Mzk4IiwibmFtZSI6IlJhd2FkIEdoeiJ9.KmLBqe3NsGX2VHHJ2J8MVd3fxTn1i6GLAnNOLIWI8cY" -L http://localhost:1234/api/_QUERIES/users_dev/test_sign
[{"sign":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA....
```

All PRest services work well **provided an authorization token** _however:_

#### To get an authorization token via PRest (when you have no one yet):

```bash
$ curl -L http://localhost:1234/api/_QUERIES/users_dev/test_sign
```
**
``` bash
"error": "Required authorization token not found" 
```
**

**HENCE**
_You just need an authorization token in order to get an authorization token :( !!_

