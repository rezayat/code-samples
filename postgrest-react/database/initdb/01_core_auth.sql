\set JWT_SECRET `echo "$JWT_SECRET"`

\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

-- add existing extensions
create extension if not exists pgcrypto;

-- add custom extensions
create extension if not exists pgjwt;


ALTER DATABASE :POSTGRES_DB SET "app.jwt_secret" TO :'JWT_SECRET';

CREATE SCHEMA if not exists basic_auth;

CREATE TYPE basic_auth.jwt_token AS (
  token text
);

CREATE TABLE if not exists
basic_auth.login_users (
  username    text primary key not null, --check ( username ~* '^.+@.+\..+$' ),
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
basic_auth.get_role(username text, pass text) returns name
  language plpgsql
  as $$
begin
  return (
  select role from basic_auth.login_users u
   where u.username = get_role.username
     and u.pass = crypt(get_role.pass, u.pass)
  );
end;
$$;

CREATE OR REPLACE FUNCTION
public.login(username text, pass text) returns basic_auth.jwt_token
  language plpgsql
  as $$
declare
  _role name;
  result basic_auth.jwt_token;
begin
  -- check username and password
  select basic_auth.get_role(username, pass) into _role;
  if _role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;


  select sign(
      row_to_json(r), current_setting('app.jwt_secret')
    ) as token
    from (
      select _role as role, login.username as username,
         extract(epoch from now())::integer + 60*60 as exp
    ) r
    into result;

  return result;
end;
$$;


-- Required Roles for Authorization/ Authentication
create role anon;
create role authenticator noinherit;
grant anon to authenticator;


-- Required Permissions for Authorization/ Authentication
grant usage on schema public, basic_auth to anon;
grant select on table pg_authid, basic_auth.login_users to anon;
grant execute on function public.login(text,text) to anon;

