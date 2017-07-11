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
            :1234/ ==> Frontend:5000 (Pushstate Server)
            :1234/api/ ==> Backend:3000 (prest)
                ==> Db:5432 (Postgres)
```

## JWT Authorization

Added JWT Authorization but as a **static** JWT token for **GET** and **POST** calls to the API. (as a proof of concept)

The token was generated using https://jwt.io/ and key 'not_secret_at_all'
any token generated using the key 'not_secret_at_all' would work.

To test the JWT you can use curl as follows:

``` bash
$ curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNzYyODk2Mzk4IiwibmFtZSI6IlJhd2FkIEdoeiJ9.KmLBqe3NsGX2VHHJ2J8MVd3fxTn1i6GLAnNOLIWI8cY" localhost:1234/api/users_dev/public/users
```

### Rationale

While JWT tests worked fine, it is obviously incorrect to store the token within the frontend scripts themselves. The correct approach would be to login the user using any means, then have the server generate the token and reply back to the user with that token. This token could be stored anywhere on the client (cookies, local-storage) and then any API call can be combined with this token for authorization.

Granted we do not have any custom services beyond prest, the proof of concept does not cater for this scenario for now.

*Possible improvements*:  add a service (Go?) that logs in the user based on the available users list in the database.
