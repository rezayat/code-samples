\connect earth

-- JWT Extensions related

ALTER DATABASE earth SET "app.jwt_secret" TO 'not_secret_at_all';

CREATE SCHEMA if not exists basic_auth;

CREATE TYPE basic_auth.jwt_token AS (
  token text
);

create extension if not exists pgcrypto;
create extension if not exists pgjwt;

CREATE OR REPLACE FUNCTION jwt_test() RETURNS basic_auth.jwt_token
    LANGUAGE sql
    AS $$

SELECT sign(
  row_to_json(r), 'any_secret'
) AS token

  FROM (
    SELECT
      'my_role'::text as role,
      extract(epoch from now())::integer + 300 AS exp
  ) r;
$$;

-- USER auth support

CREATE TABLE if not exists
basic_auth.login_users (
  email    text primary key check ( email ~* '^.+@.+\..+$' ),
  pass     text not null check (length(pass) < 512),
  role     name not null check (length(role) < 512)
);


CREATE OR REPLACE FUNCTION
basic_auth.check_role_exists() returns trigger
  language plpgsql
  as $$
begin
  if not exists (select 1 from pg_roles as r where r.rolname = new.role) then
    raise foreign_key_violation using message =
      'unknown database role: ' || new.role;
    return null;
  end if;
  return new;
end
$$;

drop trigger if exists ensure_user_role_exists on basic_auth.login_users;
create constraint trigger ensure_user_role_exists
  after insert or update on basic_auth.login_users
  for each row
  execute procedure basic_auth.check_role_exists();

  CREATE OR REPLACE FUNCTION
  basic_auth.encrypt_pass() returns trigger
    language plpgsql
    as $$
  begin
    if tg_op = 'INSERT' or new.pass <> old.pass then
      new.pass = crypt(new.pass, gen_salt('bf'));
    end if;
    return new;
  end
  $$;

  drop trigger if exists encrypt_pass on basic_auth.login_users;
  create trigger encrypt_pass
    before insert or update on basic_auth.login_users
    for each row
    execute procedure basic_auth.encrypt_pass();

CREATE OR REPLACE FUNCTION
basic_auth.user_role(email text, pass text) returns name
  language plpgsql
  as $$
begin
  return (
  select role from basic_auth.login_users u
   where u.email = user_role.email
     and u.pass = crypt(user_role.pass, u.pass)
  );
end;
$$;

CREATE OR REPLACE FUNCTION
login(email text, pass text) returns basic_auth.jwt_token
  language plpgsql
  as $$
declare
  _role name;
  result basic_auth.jwt_token;
begin
  -- check email and password
  select basic_auth.user_role(email, pass) into _role;
  if _role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  select sign(
      row_to_json(r), 'not_secret_at_all'
    ) as token
    from (
      select _role as role, login.email as email,
         extract(epoch from now())::integer + 60*60 as exp
    ) r
    into result;
  return result;
end;
$$;


-- Add fixtures

create role anon;
create role authenticator noinherit;
grant anon to authenticator;

insert into basic_auth.login_users values ('admin@gmail.com','123456789','postgres');
insert into basic_auth.login_users values ('omar@gmail.com','987654321','postgres');
insert into basic_auth.login_users values ('rawad@gmail.com','123456','postgres');

grant usage on schema public, basic_auth to anon;
grant select on table pg_authid, basic_auth.login_users to anon;
grant execute on function login(text,text) to anon;
