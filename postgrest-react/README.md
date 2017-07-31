# postgrest-react

A proof of concept stack with **postgrest** wrapping a postgres database and exposing schema "public" as an endpoint.

- **Authentication** is implemented on the database level via schema `basic_auth` using table `login_USERS` and function `login()` to store and authenticate login_users.
- **Authorization** is implemented on the database level via schema `basic_auth` using function `sign()` to generate JWT tokens.

<!-- **React App**
- Authenticates login_users using an **HTTP POST request** to `(postgrest)/rpc/login`
- Gets applicants using an **HTTP GET request** to `(postgrest)/applicants`
- Adds applicants using an **HTTP POST request** to `(postgrest)/applicants` -->

## Project Directory Structure
``` bash
.
├── database                     # database service
│   ├── Dockerfile
│   ├── extension                   # pgjwt extension files
│   │   ├── pgjwt--0.0.1.sql
│   │   └── pgjwt.control
│   └── initdb                      # database initialization scripts (SQL)
│       ├── 01_core_auth.sql           # implements authentication (schema, tables, functions)
│       ├── 02_app_schema.sql          # creates application databases
│       ├── 03_permissions_config.sql  # implements database roles and grants permissions
│       └── 04_fixtures.sql            # adds example data
├── docker-compose.yml
├── nginx                        # nginx service
│   └── nginx.conf
├── react                        # react service
│   ├── Dockerfile
│   ├── package.json                # node required packages
│   ├── public
│   │   ├── favicon.ico
│   │   ├── index.html
│   │   └── manifest.json
│   ├── README.md
│   └── src                         # react sources
│       ├── components
│       │   ├── AddApplicant.jsx
│       │   ├── ApplicantsList.jsx
│       │   ├── LoginUser.jsx
│       │   └── LogoutUser.jsx
│       ├── index.js
│       ├── logo.svg
│       └── registerServiceWorker.js
├── README.md                 # this file
└── rest                        # postgrest service
    ├── config.toml                 # postgrest configuration
    └── Dockerfile
```
## Infrastructure (nginx service)

The current configuration allows for a containerized application that uses the following infrastructure:
(defined in nginx.conf)
```
    nginx (webserver)
        == Reverse Proxy =>
            :1234/ ==> react: 5000 (React Application)
            :1234/api/ ==> rest: 3000 (Postgrest)
                ==> database: 5432 (Postgres Database)
            :1234/login ==> rest: 3000/rpc/login (Postgrest User Login and JWT token Generator)
```

## Database (database service)
### Structure

```yaml
database: recruitment
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

### Dependencies

**Extensions**
- pgcrypto
- pgjwt

### General

In order to initialize the database as desired, database initialization script SQL files are defined in _./database/initdb_.
Files get executed in alphabetical order by postgres after postgres is up.
Initialization scripts serve the purpose of defining:

1. **Core Authentication**  _01_core_auth.sql_
1. **Application Schema**  _02_app_schema.sql_
1. **Permissions Configuration**  _03_permissions_config.sql_
1. **Example Fixtures**  _04_fixtures.sql_

#### Core Authentication

| Object  | Location | Description |
|----------|-------------|------------------------------|
| SCHEMA  | `basic_auth` | Authentication schema |
| TABLE  | `basic_auth.login_users` | Login Users Table |
| FUNCTION  | `basic_auth.login` | returns `jwt token` when provided **correct** credentials |
| FUNCTION  | `basic_auth.check_role_exists` | prevents adding a `basic_auth.login_users` _login_user_ which is **not mapped** to an existing **Database Role** other helper functions |
| DATABASE_VARIABLE  | `app.jwt_secret` | stores db variable jwt_secret |
| FUNCTION  | `basic_auth.sign` | that generates `jwt token` based on database variable `app.jwt_secret` |
| ROLEs  | {anon/ authenticator} | can access funciton `basic_auth.login` used to set `current_role` to other roles |

#### Application Schema

| Object  | Location | Description |
|----------|-------------|------------------------------|
| **TABLE** | `public.applicants`| example applicants table |

#### Permissions Configuration

| Object  | Description |
|----------|----------------------------------------------|
| ROLEs | example roles {admin,employee} |
| PERMISSIONs | simple permissions allow insert and select for defined `Database Role`s |
| ROW_LEVEL_SECURITY | allow each role to view it's own `public.applicants` rows |

#### Example Fixtures
| Object  | Location | Description |
|----------|-------------|-------------------------------------------|
| ROWs | `basic_auth.login_users` | example _login_users_ that map to a defined `Database Role` |
| ROWs | `public.applicants` | example _applicants_ assumed to be inserted by specific `Database Role` |

### Roles

In order to demonstrate Authorization and Authentication the following **Database Roles** where implemented:
- postgres (implemented by default)
- admin
- employee

##### Fixture Data

**Login users** you can use to login using the following credentials:

| username | password  | database role |
|----------|-----------|---------------|
| pg       | 1234      | postgres      |
| admin    | 1234      | admin         |
| omar     | 1234      | employee      |
| rawad    | 1234      | employee      |

#### Permissions
- Role **postgres** has _(by default - unless manually revoked)_ grant permission over the whole db (db owner)

#### Row level security

**Row Level Security** enabled on table applicants as follows:

- Role **postgres** can view (select) all records
- Roles **{admin, employee}** can view their own records only
    - using **row.row_role = current_role** (logged-in role)
- All roles can insert into table applicants
    - using **row_role = current_role**

## React (react service)
- Authenticates login_users using an **HTTP POST request** to _[postrest]/rpc/login_
    - **postgrest** returns **'jwt token'** when provided **correct** credentials via route: /rpc/logins
- Gets applicants using an **HTTP GET request** to _[postrest]/applicants_
- Adds applicants using an **HTTP POST request** to _[postrest]/applicants_

## How to run

```bash
$ docker-compose up --build
$ python -m webbrowser http://localhost:1234
```

## Testing Authentication

```bash
# Failed Login

$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"incorrect_pass"}' http://localhost:1234/login
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"missing_password"}' http://localhost:1234/login
$ curl -X POST -H 'Content-Type: application/json' -d '{"pass":"missing_email"}' http://localhost:1234/login

# Successful Login

# log in as user "pg" of role "postgres" and get Authorizaion Token for role "postgres"
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"pg","pass":"1234"}' http://localhost:1234/login
# log in as user "rawad" of role "employee" and get Authorizaion Token for role "employee"
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"1234"}' http://localhost:1234/login
```

## Test Authorization

```bash
$ curl -H 'Authorization: Bearer some.invalid.token' http://localhost:1234/api/applicants

<< Invalid JWT Token >>

$ curl http://localhost:1234/api/applicants

<< Unauthorized Access >>

$ curl -H 'Authorization: Bearer {jwt token for employee}' http://localhost:1234/api/applicants

<< Success only views records for "employee" >>

$ curl -H 'Authorization: Bearer {jwt token for postgres}' http://localhost:1234/api/applicants

<< Success only views records for "postgres" (all records) >>

```
