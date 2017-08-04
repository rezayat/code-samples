\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

-- add existing extensions
create extension if not exists pgcrypto;

-- add custom extensions
create extension if not exists pgjwt;


CREATE SCHEMA if not exists basic_auth;

CREATE TYPE basic_auth.jwt_token AS (
  token text
);

CREATE TABLE if not exists
basic_auth.login_users (
  username    text primary key not null, --check ( username ~* '^.+@.+\..+$' ),
  pass     text not null check (length(pass) < 512) default '1234',
  role     name not null check (length(role) < 512)
);


CREATE OR REPLACE FUNCTION
basic_auth.check_role_exists() returns trigger
  language plpgsql
  as $$
  
begin
    if new.role = 'postgres' then
      raise invalid_role_specification using message =
        'invalid database role: ' || new.role;
      return null;
    end if;
    if not exists (select 1 from pg_roles as r where r.rolname = new.role) then
      raise foreign_key_violation using message =
        'unknown database role: ' || new.role;
      return null;
    end if;

    if not exists (select 1 from pg_roles as r where r.rolname = new.username) then
        EXECUTE ('create role ' || quote_ident(new.username) || ' in role ' || quote_ident(new.role) || ' ; ' );
    
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
  public.encrypt_pass() returns trigger
    language plpgsql
    as $$
  begin
    if tg_op = 'INSERT' or new.pass <> old.pass then
      new.pass = crypt(new.pass, gen_salt('bf'));
    end if;
    return new;
  end
  $$;
