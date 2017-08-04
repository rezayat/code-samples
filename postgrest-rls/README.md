# postgrest-rls

A proof of concept stack that demonstrates a postgres database with PERMISSIONS and  ROW LEVEL SECURITY ready to be integrated with "postgrest".

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
└─ README.md                 # this file
```

## Database (database service)
### Structure

```yaml
database: recruitment
    schema: public   # main data schema (for api access)
        table: product
            column: price
            column: row_role
            ...
        table: invoice
            column: amount
            column: salesman
            column: row_role
            ...

    schema: basic_auth  # authentication schema
        table: login_users
            column: username
            column: pass
            column: role
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

Once a `login user` is defined a `database role` is created for that login user, in order to benefit from postgres `system information functions` such as **pg_has_role** used in ROW LEVEL SECURITY policies.

### Application Schema

Application schema is defined independently in file `./database/initdb/02_app_schema.sql` in which an example table `public.applicants` is defined.

Tables in schema `public` are application specific and follow application requirements.

### Permissions Configuration

After defining authentication/ authorization mechanisms and the required application schema, **database roles** and **permission** are defined in file `./database/initdb/03_permissions_config.sql`.

Database roles (those which login users are assigned to) are defined in a flat or hierarchical style in accordance with the organizational role hierarchy.

Roles are granted/revoked permissions on database/schema/table/function... operations {insert, update, delete, select, use, execute ...} as well as Row level securtiy policies might be implemented as required by the application specifications.

> TODO: showcase our example roles

<!-- In our example: two roles `admin` and `employee` are defined and granted the permission to view (select) their own `public.applicants` rows using `public.applicants.row_role = current_role`, whereas role `postgres` is allowed (unless it is manually revoked) to view all records because it holds the database ownership. -->

### Example Fixtures

In order to clearly demonstrate this demo, example data was added in file `./database/initdb/04_fixtures.sql`.


Some example `public.invoice` and `public.product` records where inserted and provided random valid `row_role` values.

### Database Diagram 
> TODO: add database diagram

![database diagram](./database.png)

## Infrastructure

### Defined in docker-compose.yml

| Container | Port | Public Port | Links    |
| --------- | ---- | ----------- | -------- |
| database  | 5432 | -           | -        |

### Infrastructure Diagram
> TODO: add infrastructure diagram

![infrastructure diagram](./infrastructure.png)

## How to run

```bash
$ docker-compose up -d --build 
```

## Testing

In order to carry tests, open a bash into the running 'database' container using:

```bash
$ docker-compose run database bash
bash-4.3# psql -h database -U postgres recruitment
Password for user postgres:
psql (9.5.7)
Type "help" for help.

recruitment=>

```

### Testing Roles
> TODO: comment the test code

```bash
recruitment=> set role imad;
SET
recruitment=> select * from product;
 id |     name     | price | dummy | row_role |         created_at
----+--------------+-------+-------+----------+----------------------------
  3 | carton       |     2 |       | imad     | 2017-08-04 12:00:38.47544
  4 | carbon fiber |    37 |       | imad     | 2017-08-04 12:00:38.476382
  5 | caramel      |    14 |       | imad     | 2017-08-04 12:00:38.478394
(3 rows)

recruitment=> select * from invoice;
 id | type | amount  | dummy | salesman | row_role |         created_at
----+------+---------+-------+----------+----------+----------------------------
  2 | in   |  829997 |       | imad     | rawad    | 2017-08-04 12:00:38.463204
  3 | in   |    3232 |       | imad     | man      | 2017-08-04 12:00:38.46422
  7 | in   | 1723297 |       | imad     | jawad    | 2017-08-04 12:00:38.470157
(3 rows)

recruitment=> set role rawad;
SET
recruitment=> select * from product;
ERROR:  permission denied for relation product
recruitment=> select * from invoice;
 id | type | amount | dummy | salesman | row_role |         created_at
----+------+--------+-------+----------+----------+----------------------------
  2 | in   | 829997 |       | imad     | rawad    | 2017-08-04 12:00:38.463204
  5 | out  |  99097 |       | ziad     | rawad    | 2017-08-04 12:00:38.467262
(2 rows)

recruitment=> set role omar;
SET
recruitment=> select * from product;
ERROR:  permission denied for relation product
recruitment=> select * from invoice;
 id | type | amount  | dummy | salesman | row_role |         created_at
----+------+---------+-------+----------+----------+----------------------------
  1 | out  | 3112197 |       | ziad     | jawad    | 2017-08-04 12:00:38.460888
  2 | in   |  829997 |       | imad     | rawad    | 2017-08-04 12:00:38.463204
  3 | in   |    3232 |       | imad     | man      | 2017-08-04 12:00:38.46422
  4 | out  | 1101097 |       | ziad     | jawad    | 2017-08-04 12:00:38.466265
  5 | out  |   99097 |       | ziad     | rawad    | 2017-08-04 12:00:38.467262
  6 | out  |    4327 |       | ziad     | man      | 2017-08-04 12:00:38.4693
  7 | in   | 1723297 |       | imad     | jawad    | 2017-08-04 12:00:38.470157
(7 rows)

recruitment=> set role joe;
SET
recruitment=> select * from product;
 id |     name     | price | dummy | row_role |         created_at
----+--------------+-------+-------+----------+----------------------------
  1 | car          | 10203 |       | ziad     | 2017-08-04 12:00:38.472213
  2 | carpet       |   250 |       | ziad     | 2017-08-04 12:00:38.473347
  3 | carton       |     2 |       | imad     | 2017-08-04 12:00:38.47544
  4 | carbon fiber |    37 |       | imad     | 2017-08-04 12:00:38.476382
  5 | caramel      |    14 |       | imad     | 2017-08-04 12:00:38.478394
(5 rows)

recruitment=> select * from invoice;
 id | type | amount  | dummy | salesman | row_role |         created_at
----+------+---------+-------+----------+----------+----------------------------
  1 | out  | 3112197 |       | ziad     | jawad    | 2017-08-04 12:00:38.460888
  2 | in   |  829997 |       | imad     | rawad    | 2017-08-04 12:00:38.463204
  3 | in   |    3232 |       | imad     | man      | 2017-08-04 12:00:38.46422
  4 | out  | 1101097 |       | ziad     | jawad    | 2017-08-04 12:00:38.466265
  5 | out  |   99097 |       | ziad     | rawad    | 2017-08-04 12:00:38.467262
  6 | out  |    4327 |       | ziad     | man      | 2017-08-04 12:00:38.4693
  7 | in   | 1723297 |       | imad     | jawad    | 2017-08-04 12:00:38.470157
(7 rows)

recruitment=> set role man;
SET
recruitment=> select * from invoice;
 id | type | amount  | dummy | salesman | row_role |         created_at
----+------+---------+-------+----------+----------+----------------------------
  1 | out  | 3112197 |       | ziad     | jawad    | 2017-08-04 12:00:38.460888
  2 | in   |  829997 |       | imad     | rawad    | 2017-08-04 12:00:38.463204
  3 | in   |    3232 |       | imad     | man      | 2017-08-04 12:00:38.46422
  4 | out  | 1101097 |       | ziad     | jawad    | 2017-08-04 12:00:38.466265
  5 | out  |   99097 |       | ziad     | rawad    | 2017-08-04 12:00:38.467262
  6 | out  |    4327 |       | ziad     | man      | 2017-08-04 12:00:38.4693
  7 | in   | 1723297 |       | imad     | jawad    | 2017-08-04 12:00:38.470157
(7 rows)

recruitment=> select * from product;
 id |     name     | price | dummy | row_role |         created_at
----+--------------+-------+-------+----------+----------------------------
  1 | car          | 10203 |       | ziad     | 2017-08-04 12:00:38.472213
  2 | carpet       |   250 |       | ziad     | 2017-08-04 12:00:38.473347
  3 | carton       |     2 |       | imad     | 2017-08-04 12:00:38.47544
  4 | carbon fiber |    37 |       | imad     | 2017-08-04 12:00:38.476382
  5 | caramel      |    14 |       | imad     | 2017-08-04 12:00:38.478394
(5 rows)

recruitment=> set role man;
SET
recruitment=> select * from invoice;
 id | type | amount  | dummy | salesman | row_role |         created_at
----+------+---------+-------+----------+----------+----------------------------
  1 | out  | 3112197 |       | ziad     | jawad    | 2017-08-04 12:00:38.460888
  2 | in   |  829997 |       | imad     | rawad    | 2017-08-04 12:00:38.463204
  3 | in   |    3232 |       | imad     | man      | 2017-08-04 12:00:38.46422
  4 | out  | 1101097 |       | ziad     | jawad    | 2017-08-04 12:00:38.466265
  5 | out  |   99097 |       | ziad     | rawad    | 2017-08-04 12:00:38.467262
  6 | out  |    4327 |       | ziad     | man      | 2017-08-04 12:00:38.4693
  7 | in   | 1723297 |       | imad     | jawad    | 2017-08-04 12:00:38.470157
(7 rows)

recruitment=> select * from product;
 id |     name     | price | dummy | row_role |         created_at
----+--------------+-------+-------+----------+----------------------------
  1 | car          | 10203 |       | ziad     | 2017-08-04 12:00:38.472213
  2 | carpet       |   250 |       | ziad     | 2017-08-04 12:00:38.473347
  3 | carton       |     2 |       | imad     | 2017-08-04 12:00:38.47544
  4 | carbon fiber |    37 |       | imad     | 2017-08-04 12:00:38.476382
  5 | caramel      |    14 |       | imad     | 2017-08-04 12:00:38.478394
(5 rows)

recruitment=> update product set dummy = 'dum' where id =2;
ERROR:  new row violates row-level security policy for table "product"
recruitment=> update invoice set dummy = 'dum' where id =5;
ERROR:  new row violates row-level security policy for table "invoice"
recruitment=> update invoice set dummy = 'dum' where id =3;
UPDATE 1
recruitment=> select * from invoice where id = 3;
 id | type | amount | dummy  | salesman | row_role |        created_at
----+------+--------+--------+----------+----------+---------------------------
  3 | in   |   3232 | dum    | imad     | man      | 2017-08-04 12:00:38.46422
(1 row)

```
