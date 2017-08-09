# postgrest-rls

A proof of concept stack that demonstrates a **postgres database** with PERMISSIONS and ROW LEVEL SECURITY, a **postgrest** service wrapping the database, exposing schema `public` as an endpoint and providing authorization and authentication mechanisms and an **nginx** service that proxies the functionality of the services through a consistent HTTP configuration.

The stack is to be tested in this documentation using `curl` and `psql`.

## Project Directory Structure
```bash
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
├── README.md                 # this file
└── rest                        # postgrest service
    ├── config.toml                 # postgrest configuration
    └── Dockerfile
```

## Infrastructure

### Defined in docker-compose.yml

| Container | Port | Public Port | Links   
| --------- | ---- | ----------- | --------
| database  | 5432 | -           | -       
| rest      | 3000 | -           | database
| nginx     | 1234 | 1234        | rest    

### Defined in nginx configuration

In our example nginx is configured using file `./nginx/nginx.conf` to listen to `port 1234` and route calls as follows:

| Source route | Proxy to               | Purpose
| ----------   | ---------------------- | -------
| :1234/api    | rest:3000/             | Expose postgrest
| :1234/login  | rest:3000/rpc/login    | Expose postgrest login endpoint


### Infrastructure Diagram

![infrastructure diagram](./infrastructure.png)

## Database (database service)

### Dependencies

**Extensions**
- pgcrypto
- pgjwt

### General

In order to initialize the database as desired, database initialization script SQL files are defined in _./database/initdb_.
Files get executed in alphabetical order by postgres after postgres is up.
Initialization scripts serve the purpose of defining:

1. **Core Authentication**
1. **Application Schema**
1. **Permissions Configuration**
1. **Example Fixtures**

### Core Authentication

The core authentication script in file `./database/initdb/01_core_auth.sql` defines all the SQL statements and functions needed in order to implement **authentication** and **authorization** in an independent script thus facilitating _code reusability_.

It uses a seperate **schema** `basic_auth` and **table** `basic_auth.login_users` to store login users' data.

Defined users **MUST belong** to an **EXISTING database role** and are checked using a trigger on insert and update by function `basic_auth.check_role_exists` to have an existing database role.

Once a `login user` is created a `database role` is created for that login user, in order to benefit from postgres `system information functions` such as **pg_has_role** used in ROW LEVEL SECURITY policies.

### Application Schema

Application schema is defined independently in file `./database/initdb/02_app_schema.sql` in which example tables `public.invoice` and `public.product` are defined.

Tables in schema `public` are application specific and follow application requirements.

#### Database Structure

```YAML
database: recruitment
    schema: pg_catalog   # postgres schema
        table: pg_roles
            column: rolname
            ...
    schema: public   # main data schema (for api access)
        table: product
            column: name
            column: price
            column: dummy   # to test updates
            column: created_by # references login_user.username
            column: created_at
        table: invoice
            column: type
            column: amount
            column: dummy   # to test updates
            column: salesman   # references login_user.username
            column: created_by # references login_user.username
            column: created_at
    schema: basic_auth  # authentication schema
        table: login_users
            column: username
            column: pass
            column: in_role    # references pg_roles.rolname
        function: login
        function: sign
```

#### Database Diagram

Our example can mainly be visualized in the following diagram:

![entity relationship diagram](./database_tables.png)

### Permissions Configuration

After defining authentication/ authorization mechanisms and the required application schema, **database roles** and **permission** are defined in file `./database/initdb/03_permissions_config.sql`.

Database roles (those which login users are assigned to) are defined in a flat or hierarchical style in accordance with the organizational role hierarchy.

Roles are granted/revoked permissions on database/schema/table/function... operations {insert, update, delete, select, use, execute ...} as well as Row level securtiy policies might be implemented as required by the application specifications.

In our example we added the following `database roles` with their corresponding Table Permissions:

| Role               | In Role       | Table    | Permissions              
| ------------------ | ------------- | -------- | -------------------------
| accountant         |               | invoice  | read own, write, edit own
|                    |               | product  | deny                     
| salesman           |               | invoice  | read own                 
|                    |               | product  | read own, write, edit own
| auditor            |               | invoice  | read all                 
|                    |               | product  | read all                 
| accounting_auditor | auditor       | invoice  | read all                 
|                    |               | product  | deny                     
| sales_auditor      | auditor       | invoice  | read all                 
|                    |               | product  | read all                 
| manager            |               | invoice  | read all, write, edit own
|                    |               | product  | read all, write, edit own

### Example Fixtures

In order to clearly demonstrate this demo, example data was added in file `./database/initdb/04_fixtures.sql`.

Some example `public.invoice` and `public.product` records were inserted and provided random **valid** values.

Example `basic_auth.login_users` _(which you can use to login)_ inserted are:

 Username | Password | In Role
----------|----------|--------------------
 man      | 1234     | manager
 joe      | 1234     | sales_auditor
 omar     | 1234     | accounting_auditor
 ziad     | 1234     | salesman
 imad     | 1234     | salesman
 rawad    | 1234     | accountant
 jawad    | 1234     | accountant

These `basic_auth.login_users` have corresponding `postgres roles` and could be viewed using:

```bash
$ docker-compose up -d --build
$ docker-compose exec database psql -U postgres recruitment -c "\du;"

                                             List of roles
     Role name      |                         Attributes                         |      Member of
--------------------+------------------------------------------------------------+----------------------
 accountant         | Cannot login                                               | {}
 accounting_auditor | Cannot login                                               | {auditor}
 anon               | Cannot login                                               | {}
 auditor            | Cannot login                                               | {}
 authenticator      | No inheritance, Cannot login                               | {anon}
 imad               | Cannot login                                               | {salesman}
 jawad              | Cannot login                                               | {accountant}
 joe                | Cannot login                                               | {sales_auditor}
 man                | Cannot login                                               | {manager}
 manager            | Cannot login                                               | {}
 omar               | Cannot login                                               | {accounting_auditor}
 postgres           | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 rawad              | Cannot login                                               | {accountant}
 sales_auditor      | Cannot login                                               | {auditor}
 salesman           | Cannot login                                               | {}
 ziad               | Cannot login                                               | {salesman}
```

#### Roles Hierarchy Tree

```YAML
postgres

anon:
  authenticator

accountant:
  rawad
  jawad

salesman:
  imad
  ziad

auditor:
  accounting_auditor:
    omar
  sales_auditor:
    joe

manager:
  man
```

## How to run

```bash
$ docker-compose up -d --build 
```

## Testing

In order to carry tests, open a bash into the running `database` container using:

### Database Testing

Database implementation testing is carried out in order to test Roles, Permissions and Row Level Security policies using `psql`.

Open a psql session using:

```bash
$ docker-compose exec database psql -U postgres recruitment
psql (9.5.7)
Type "help" for help.

recruitment=#
```
#### View Login Users

To view fixture `basic_auth.login_users` with their corresponding roles

```SQL
recruitment=> select * from basic_auth.login_users;

 username |                             pass                             |      in_role
----------+--------------------------------------------------------------+--------------------
 man      | $2a$06$h0zD9zASWJ4305Wm26Qr6OmDMGroEwAY9DZGxfEIKYlqu930wRyfG | manager
 joe      | $2a$06$791rBlPw53ZZXHVueXyjTeh4uR5aQSvwFC2kxww2hrsr5zxKPHXdy | sales_auditor
 omar     | $2a$06$QktMNGf.aVFmatMjbGzXbegVgX9I5.0HNc964VIAHcxverNJt.cja | accounting_auditor
 ziad     | $2a$06$QVGE4C3l9gVolfRmTf1U.OrY9jYEwhXvVdo3taEi/WMbaz/dByi26 | salesman
 imad     | $2a$06$Lstdg0YYU2p6gED4Ef4vO.ZMFghz1JAsr63.fhywAdWzLEcxw2wYu | salesman
 rawad    | $2a$06$8e8p/zUcBy8TMfxFjdRAYe1nzkPHBDQNBKiBPRbyVedPB8cIQ/eW2 | accountant
 jawad    | $2a$06$5Mk9usQ4ShbuwWrTHf4H.u5GxXpYovKWIWO8DccafrjXuZj07ZaPe | accountant
(7 rows)
```

#### Salesman Permissions

In order to test salesman permissions we need to set `current_role` to `salesman` or to a `login_user` who is a member of `salesman`.

Set role to `imad` which is a `salesman` using:

```SQL
recruitment=> set role imad;
SET
```
Test a salesman is able to view his own product records `created_by = current_role` (imad) using:

```SQL
recruitment=> select * from product;

 id |     name     | price | dummy | created_by |         created_at
----+--------------+-------+-------+----------+----------------------------
  2 | caramel      |    14 |       | imad     | 2017-08-07 08:15:25.577553
  3 | carbon fiber |    37 |       | imad     | 2017-08-07 08:15:25.579552
  5 | carton       |     2 |       | imad     | 2017-08-07 08:15:25.582814
(3 rows)
```

Test a salesman is able to view invoice records where `salesman = current_role` using:

```SQL
recruitment=> select * from invoice;

 id | type | amount  | dummy | salesman | created_by |         created_at
----+------+---------+-------+----------+----------+----------------------------
  2 | in   |  829997 |       | imad     | rawad    | 2017-08-07 08:15:25.566907
  3 | in   |    3232 |       | imad     | man      | 2017-08-07 08:15:25.567861
  7 | in   | 1723297 |       | imad     | jawad    | 2017-08-07 08:15:25.574362
(3 rows)
```
Test a salesman can edit own records only using:

```SQL
recruitment=> update product set dummy = 'dum 1' where id =1 ;
UPDATE 0

recruitment=> update product set dummy = 'dum 2' where id =2 ;
UPDATE 1
```

#### Accountant Permissions

Set role to `rawad` which is an `accountant` using:

```SQL
recruitment=> set role rawad;
SET
```

Test an accountant cannot view products using:

```SQL
recruitment=> select * from product;
ERROR:  permission denied for relation product
```

Test an accountant can view own invoice records using:

```SQL
recruitment=> select * from invoice;

 id | type | amount | dummy | salesman | created_by |         created_at
----+------+--------+-------+----------+----------+----------------------------
  2 | in   | 829997 |       | imad     | rawad    | 2017-08-07 08:15:25.566907
  5 | out  |  99097 |       | ziad     | rawad    | 2017-08-07 08:15:25.571303
(2 rows)
```

Test an accountant can edit own records only using:

```SQL
recruitment=> update invoice set dummy = 'dum 3' where id = 1;
UPDATE 0

recruitment=> update invoice set dummy = 'dum 4' where id = 5;
UPDATE 1
```

#### Accounting Auditor Permissions

Set role to `omar` which is an `accounting_auditor` using:

```SQL
recruitment=> set role omar;
SET
```

Test an accounting auditor cannot access products using:

```SQL
recruitment=> select * from product;
ERROR:  permission denied for relation product
```

Test an accounting auditor can view all invoices using:

```SQL
recruitment=> select * from invoice;

 id | type | amount  | dummy | salesman | created_by |         created_at
----+------+---------+-------+----------+----------+----------------------------
  1 | out  | 3112197 |       | ziad     | jawad    | 2017-08-07 08:15:25.564469
  2 | in   |  829997 |       | imad     | rawad    | 2017-08-07 08:15:25.566907
  3 | in   |    3232 |       | imad     | man      | 2017-08-07 08:15:25.567861
  4 | out  | 1101097 |       | ziad     | jawad    | 2017-08-07 08:15:25.569863
  6 | out  |    4327 |       | ziad     | man      | 2017-08-07 08:15:25.57337
  7 | in   | 1723297 |       | imad     | jawad    | 2017-08-07 08:15:25.574362
  5 | out  |   99097 | dum 4 | ziad     | rawad    | 2017-08-07 08:15:25.571303
(7 rows)
```

Test an accounting auditor cannot edit invoices using:

```SQL
recruitment=> update invoice set dummy = 'dum 5' where id = 3;
ERROR:  permission denied for relation invoice
```

#### Sales Auditor Permissions

Set role to `joe` which is an `sales_auditor` using:

```SQL
recruitment=> set role joe;
SET
```

Test a sales auditor can view all products and invoices using:

```SQL
recruitment=> select * from product,invoice limit 5;

 id | name | price | dummy | created_by |         created_at         | id | type | amount  | dummy | salesman | created_by |         created_at
----+------+-------+-------+------------+----------------------------+----+------+---------+-------+----------+------------+----------------------------
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  1 | out  | 3112197 |       | ziad     | jawad      | 2017-08-08 11:35:43.413316
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  2 | in   |  829997 |       | imad     | rawad      | 2017-08-08 11:35:43.415924
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  3 | in   |    3232 |       | imad     | man        | 2017-08-08 11:35:43.416974
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  4 | out  | 1101097 |       | ziad     | jawad      | 2017-08-08 11:35:43.419083
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  5 | out  |   99097 |       | ziad     | rawad      | 2017-08-08 11:35:43.42002
(5 rows)
```

Test a sales auditor cannot edit products or invoices using:

```SQL
recruitment=>  update product set dummy = 'dum 7';
ERROR:  permission denied for relation product
recruitment=>  update invoice set dummy = 'dum 7';
ERROR:  permission denied for relation invoice
```

#### Manager Permissions

Set role to `man` which is a `manager` using:

```SQL
recruitment=> set role man;
SET
```

Test a manager can view all invoices and products using:

```SQL
recruitment=> select * from product,invoice limit 5;

 id | name | price | dummy | created_by |         created_at         | id | type | amount  | dummy | salesman | created_by |         created_at
----+------+-------+-------+------------+----------------------------+----+------+---------+-------+----------+------------+----------------------------
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  1 | out  | 3112197 |       | ziad     | jawad      | 2017-08-08 11:35:43.413316
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  2 | in   |  829997 |       | imad     | rawad      | 2017-08-08 11:35:43.415924
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  3 | in   |    3232 |       | imad     | man        | 2017-08-08 11:35:43.416974
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  4 | out  | 1101097 |       | ziad     | jawad      | 2017-08-08 11:35:43.419083
  1 | car  | 10203 |       | ziad       | 2017-08-08 11:35:43.425248 |  5 | out  |   99097 |       | ziad     | rawad      | 2017-08-08 11:35:43.42002
(5 rows)
```

Test a manager can update his own invoice records only using:

```SQL
recruitment=> update invoice set dummy = 'dum 9' where id = 1;
ERROR:  new row violates row-level security policy for table "invoice"

recruitment=> update invoice set dummy = 'dum 10' where id = 6;
UPDATE 1
```

### Testing postgrest (using curl)

`curl` is used in order to test postgrest service.

#### Testing Authentication

Authentication in postgrest is simply done by sending a POST request with a username and a password in JSON data to `/login`. If the credentials are valid postgrest returns a `JWT authorization token` which would be sent along with any GET or POST request to postgrest.

Following are some **Failing** attempts to aquire a `JWT token` 

Test attempt with invalid credentials using:
```bash
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"incorrect_pass"}' http://localhost:1234/login
{"hint":null,"details":null,"code":"28P01","message":"invalid user or password"}
```

Test attempt with missing password using:
```bash
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"missing_password"}' http://localhost:1234/login
{"hint":"No function matches the given name and argument types. You might need to add explicit type casts.","details":null,"code":"42883","message":"function public.login(username => unknown) does not exist"}
```

Test attempt with missing username using:
```bash
$ curl -X POST -H 'Content-Type: application/json' -d '{"pass":"missing_username"}' http://localhost:1234/login
{"hint":"No function matches the given name and argument types. You might need to add explicit type casts.","details":null,"code":"42883","message":"function public.login(pass => unknown) does not exist"}
```

Following are some **Successful** attempts to aquire different `JWT token`s for defferent users

**Note that:** tokens expire after some time. (You cannot use tokens from this documentation)

Aquire `JWT token` for user `omar` of role `accounting_auditor` 

```bash
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"omar","pass":"1234"}' http://localhost:1234/login
[{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoib21hciIsInVzZXJuYW1lIjoib21hciIsImV4cCI6MTUwMjExOTg0Nn0.MIYDom1IQO6TwLCHkAcnga8ufEJYurGRG89QNaUIsNk"}]
```

Aquire `JWT token` for user `rawad` of role `accountant` 

```bash
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"1234"}' http://localhost:1234/login
[{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoicmF3YWQiLCJ1c2VybmFtZSI6InJhd2FkIiwiZXhwIjoxNTAyMTE5ODcwfQ.qAacTiocm9UHepppg5SXwu3uLYKa1PiAZXjwcgDtvGc"}]
```

Aquire `JWT token` for user `imad` of role `salesman` 

```bash
$ curl -X POST -H 'Content-Type: application/json' -d '{"username":"imad","pass":"1234"}' http://localhost:1234/login_users
[{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiaW1hZCIsInVzZXJuYW1lIjoiaW1hZCIsImV4cCI6MTUwMjE4NDAxOH0.Kvz42_rVb3myTF4xeEVLh787FaA72I1A9XkIkgeO7C4"}]
```

In order to easily use `JWT token`s generated you might export some tokens to the environment using:

```bash
$ export rawad_jwt=$(curl -X POST -H 'Content-Type: application/json' -d '{"username":"rawad","pass":"1234"}' http://localhost:1234/login | awk -F'"' '{print $4}')
$ export imad_jwt=$(curl -X POST -H 'Content-Type: application/json' -d '{"username":"imad","pass":"1234"}' http://localhost:1234/login | awk -F'"' '{print $4}')
$ export omar_jwt=$(curl -X POST -H 'Content-Type: application/json' -d '{"username":"omar","pass":"1234"}' http://localhost:1234/login | awk -F'"' '{print $4}')
$ export man_jwt=$(curl -X POST -H 'Content-Type: application/json' -d '{"username":"man","pass":"1234"}' http://localhost:1234/login | awk -F'"' '{print $4}')
```

#### Test Authorization

Testing postgrest rest api with/without valid `JWT tokens` to make sure Authorization, Permissions and Row Level Security measures are successfully implemented.

Test geting invoices without token using:
```bash
$ curl http://localhost:1234/api/invoice
{"hint":null,"details":null,"code":"42501","message":"permission denied for relation invoice"}
```

Test getting invoices with invalid token using:
```bash
$ curl -H 'Authorization: Bearer some.invalid.token' http://localhost:1234/api/invoice
{"message":"JWT invalid"}
```

Test getting `invoices` as user `omar` of role `accounting_auditor` using previously generated `JWT token`

All invoice records must be returned

```bash
$ curl -H 'Authorization: Bearer '$omar_jwt http://localhost:1234/api/invoice
[
    {
        "amount": 3112197,
        "created_at": "2017-08-08T07:53:13.707223",
        "dummy": "",
        "id": 1,
        "created_by": "jawad",
        "salesman": "ziad",
        "type": "out"
    },
    {
        "amount": 829997,
        "created_at": "2017-08-08T07:53:13.709797",
        "dummy": "",
        "id": 2,
        "created_by": "rawad",
        "salesman": "imad",
        "type": "in"
    },
    {
        "amount": 3232,
        "created_at": "2017-08-08T07:53:13.710841",
        "dummy": "",
        "id": 3,
        "created_by": "man",
        "salesman": "imad",
        "type": "in"
    },
    {
        "amount": 1101097,
        "created_at": "2017-08-08T07:53:13.713023",
        "dummy": "",
        "id": 4,
        "created_by": "jawad",
        "salesman": "ziad",
        "type": "out"
    },
    {
        "amount": 99097,
        "created_at": "2017-08-08T07:53:13.714081",
        "dummy": "",
        "id": 5,
        "created_by": "rawad",
        "salesman": "ziad",
        "type": "out"
    },
    {
        "amount": 4327,
        "created_at": "2017-08-08T07:53:13.716258",
        "dummy": "",
        "id": 6,
        "created_by": "man",
        "salesman": "ziad",
        "type": "out"
    },
    {
        "amount": 1723297,
        "created_at": "2017-08-08T07:53:13.717268",
        "dummy": "",
        "id": 7,
        "created_by": "jawad",
        "salesman": "imad",
        "type": "in"
    }
]
```

Test getting `invoices` as user `rawad` of role `accountant` using previously generated `JWT token`

Only records having `created_by = rawad` must be returned

```bash
$ curl -H 'Authorization: Bearer '$rawad_jwt http://localhost:1234/api/invoice
[
    {
        "amount": 829997,
        "created_at": "2017-08-08T07:53:13.709797",
        "dummy": "",
        "id": 2,
        "created_by": "rawad",
        "salesman": "imad",
        "type": "in"
    },
    {
        "amount": 99097,
        "created_at": "2017-08-08T07:53:13.714081",
        "dummy": "",
        "id": 5,
        "created_by": "rawad",
        "salesman": "ziad",
        "type": "out"
    }
]
```

Test getting `invoices` as user `imad` of role `accountant` using previously generated `JWT token`

Only records having `saleman = imad` must be returned

```bash
$ curl -H 'Authorization: Bearer '$imad_jwt http://localhost:1234/api/invoice

[
    {
        "amount": 829997,
        "created_at": "2017-08-08T08:15:27.369701",
        "dummy": "",
        "id": 2,
        "created_by": "rawad",
        "salesman": "imad",
        "type": "in"
    },
    {
        "amount": 3232,
        "created_at": "2017-08-08T08:15:27.371929",
        "dummy": "",
        "id": 3,
        "created_by": "man",
        "salesman": "imad",
        "type": "in"
    },
    {
        "amount": 1723297,
        "created_at": "2017-08-08T08:15:27.378086",
        "dummy": "",
        "id": 7,
        "created_by": "jawad",
        "salesman": "imad",
        "type": "in"
    }
]

```

Test posting an `invoice` as user `imad` which is a `salesman` using a valid `JWT token` for `imad`

User imad must not be able to post into invoices

```bash
$ curl -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer '$imad_jwt -d '{"amount":89373,"dummy":"new_record","type":"in", "salesman":"imad" }' http://localhost:1234/api/invoice
{
    "code": "42501",
    "details": null,
    "hint": null,
    "message": "permission denied for relation invoice"
}
```

Test posting an `invoice` as user `rawad` which is an `accountant` using a valid `JWT token` for `rawad`

User rawad must be able to post into invoices

```bash
$ curl -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer '$rawad_jwt -d '{"amount":89373,"dummy":"new_record","type":"in", "salesman":"imad" }' http://localhost:1234/api/invoice
```

Check record exists

```bash
$ curl -H 'Authorization: Bearer '$rawad_jwt http://localhost:1234/api/invoice?dummy=eq."new_record"

[
    {
        "amount": 89373,
        "created_at": "2017-08-08T13:41:45.234231",
        "created_by": "rawad",
        "dummy": "new_record",
        "id": 8,
        "salesman": "imad",
        "type": "in"
    }
]
```


