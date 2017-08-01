# postgrest-react

A proof of concept stack that demonstrates 
- **postgrest** wrapping a postgres database, exposing schema "public" as an endpoint, providing authorization and authentication mechanisms, granting permissions and setting row level security policies.
- **react.js** as a simple Single Page Application that provides a web interface to login users,view and insert records.
- nginx and other configurations that glue contianers and components together thus makeing the implementation possible.

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

1. **Core Authentication**  <!-- `01_core_auth.sql` -->
1. **Application Schema**  <!-- `02_app_schema.sql` -->
1. **Permissions Configuration**  <!-- `03_permissions_config.sql` -->
1. **Example Fixtures**  <!-- `04_fixtures.sql` -->

### Core Authentication

The core authentication script in file `./database/initdb/01_core_auth.sql` defines all the SQL statements and functions needed in order to implement **authentication** and **authorization** in an independent script thus facilitating _code reusability_.

It uses a seperate **schema** `basic_auth` and **table** `basic_auth.login_users` to store login users' data.

Defined users **MUST belong** to an **EXISTING database role** and are checked using a trigger on insert and update by function `basic_auth.check_role_exists` to have an existing database role.

A **jwt token** is generated based on database variable `app.jwt_secret` using the function `basic_auth.sign`. However, the function `basic_auth.login` authenticates login users and returns a **jwt authorization token** when provided CORRECT credentials thus serving both purposes of authenticationa and authorization.

Defined roles `anon` and `authenticator` are allowed to execute function `basic_auth.login` so they authenticate and authorize users.

### Application Schema

Application schema is defined independently in file `./database/initdb/02_app_schema.sql` in which an example table `public.applicants` is defined.

Tables in schema `public` are application specific and follow application requirements.

### Permissions Configuration

After defining authentication/ authorization mechanisms and the required application schema, **database roles** and **permission** are defined in file `./database/initdb/03_permissions_config.sql`.

Database roles (those which login users are assigned to) are defined in a flat or hierarchical style in accordance with the organizational role hierarchy.

Roles are granted/revoked permissions on database/schema/table/function... operations {insert, update, delete, select, use, execute ...} as well as Row level securtiy policies might be implemented as required by the application specifications.

In our example: two roles `admin` and `employee` are defined and granted the permission to view (select) their own `public.applicants` rows using `public.applicants.row_role = current_role`, whereas role `postgres` is allowed (unless it is manually revoked) to view all records because it holds the database ownership.

### Example Fixtures

In order to clearly demonstrate this demo, example data was added in file `./database/initdb/04_fixtures.sql`.

Some example `public.applicants` records where inserted and provided random valid `row_role` values.

Example `basic_auth.login_users` user records where inserted into the database and assigned valid roles as follows:

| username | password  | database role |
|----------|-----------|---------------|
| pg       | 1234      | postgres      |
| admin    | 1234      | admin         |
| omar     | 1234      | employee      |
| rawad    | 1234      | employee      |

## Postgrest (rest service)

Postgrest rest application is run and configured using file `./rest/config.toml` to do the following:

- connect to application database `recruitment` using db-uri = "postgres://postgres:postgres@database:5432/recruitment"
- expose a login endpoint `rest/rpc/login` in wich users are authenticated and provided a jwt authorization token
- expose schema `public` and hence table `public.applicants` enabling SELECT and INSERT operations using methods GET and POST respectively through endpoint `rest/applicants`

**NOTE THAT**: Following `curl` example tests are provided so you can test the rest service.

## React (react service)

A _Single Page Application_ frontend is implemented using React.js where it provides:

- **Case no user is logged in**
    - a login form to login the user and store aquired authorization token

- **Case a user is logged in**
    - a section to view already added applicants
    - an add user form to insert a new applicant to the database
    - a logout button :)

Under the hood, the react application makes HTTP API calls to the "rest service" in order to accomplish previous objectives as follows:

- **HTTP POST request** to _[rest]/rpc/login_ in order to authenticate login_users
- **HTTP GET request** to _[rest]/applicants_ in order to get applicants
- **HTTP POST request** to _[rest]/applicants_ in order to add applicants

## Infrastructure (nginx service)

The main pupose of the nginx service is to define and expose one or more endpoint(s) to the application and to facilitate container to container communication. These purposes are acheived through routing calls via a reverse proxy to the desired endpoint.

In our example nginx is configured using file `./nginx/nginx.conf` to listen to "port 1234" and route calls as follows:

| Calls from route | Routed to endpoint | Purpose |
| ---------- | ------------------ | ------- |
| :1234/ | react:5000/ | Expose React application |
| :1234/api | rest:3000/ | Expose postgrest |
| :1234/login | rest:3000/rpc/login | Expose postgrest login endpoint |

## How to run

```bash
$ docker-compose up --build
$ python -m webbrowser http://localhost:1234
```

## Testing Authentication

```bash
# Failed Login

$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"incorrect_pass"}' http://localhost:1234/login
{"hint":null,"details":null,"code":"28P01","message":"invalid user or password"}

$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"missing_password"}' http://localhost:1234/login
{"hint":"No function matches the given name and argument types. You might need to add explicit type casts.","details":null,"code":"42883","message":"function public.login(username => unknown) does not exist"}

$ curl -X POST -H 'Content-Type: application/json' -d '{"pass":"missing_email"}' http://localhost:1234/login
{"hint":"No function matches the given name and argument types. You might need to add explicit type casts.","details":null,"code":"42883","message":"function public.login(pass => unknown) does not exist"}

# Successful Login

# log in as user "pg" of role "postgres" and get Authorization Token for role "postgres"
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"pg","pass":"1234"}' http://localhost:1234/login
[{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoicG9zdGdyZXMiLCJ1c2VybmFtZSI6InBnIiwiZXhwIjoxNTAxNTgzMTM3fQ.2aOx_fqk8TYf9E0-vBEASz0Yaitn3AcTGpoozudvueY"}]

# log in as user "rawad" of role "employee" and get Authorization Token for role "employee"
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"1234"}' http://localhost:1234/login
[{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiZW1wbG95ZWUiLCJ1c2VybmFtZSI6InJhd2FkIiwiZXhwIjoxNTAxNTgzMTM4fQ.lXhzP0WbeYkxtLYTn9BR8AQCd1sI4Vkp5XJjv9ZQ3YE"}]

```

## Test Authorization

```bash
$ curl http://localhost:1234/api/applicants
{"hint":null,"details":null,"code":"42501","message":"permission denied for relation applicants"}

$ curl -H 'Authorization: Bearer some.invalid.token' http://localhost:1234/api/applicants
{"message":"JWT invalid"}

$ # get applicants as user "pg" of role "postgres" using previously generated 'jwt token'
$ curl -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoicG9zdGdyZXMiLCJ1c2VybmFtZSI6InBnIiwiZXhwIjoxNTAxNTgyNTY4fQ.2cS-AGmgsUJOg7dNXOSmbpPZt4j0XQvY7BocaQLSCxg' http://localhost:1234/api/applicants
[
    {
        "active": true,
        "created_at": "2017-06-07T01:23:45",
        "email": "test.user_1@gmail.com",
        "id": 1,
        "row_role": "employee",
        "username": "test_user 1"
    },
    {
        "active": true,
        "created_at": "2017-07-08T01:23:45",
        "email": "test.user_2@gmail.com",
        "id": 2,
        "row_role": "employee",
        "username": "test_user 2"
    },
    {
        "active": true,
        "created_at": "2017-08-09T01:23:45",
        "email": "test.user_3@gmail.com",
        "id": 3,
        "row_role": "admin",
        "username": "test_user 3"
    }
]

$ # get applicants as user "rawad" of role "employee" using previously generated 'jwt token'
$ curl -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiZW1wbG95ZWUiLCJ1c2VybmFtZSI6InJhd2FkIiwiZXhwIjoxNTAxNTgyNjQwfQ.v8zwy8QM2aXWaNOj4FVuvBwM_adWquSVrKYCAubHh8c' http://localhost:1234/api/applicants

[
    {
        "active": true,
        "created_at": "2017-06-07T01:23:45",
        "email": "test.user_1@gmail.com",
        "id": 1,
        "row_role": "employee",
        "username": "test_user 1"
    },
    {
        "active": true,
        "created_at": "2017-07-08T01:23:45",
        "email": "test.user_2@gmail.com",
        "id": 2,
        "row_role": "employee",
        "username": "test_user 2"
    }
]

```
