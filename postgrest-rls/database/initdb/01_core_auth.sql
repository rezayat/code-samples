\set JWT_SECRET `echo "$JWT_SECRET"`
\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

-- add existing extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- add custom extensions
CREATE EXTENSION IF NOT EXISTS pgjwt;

ALTER DATABASE :POSTGRES_DB SET "app.jwt_secret" TO :'JWT_SECRET';
  
CREATE SCHEMA IF NOT EXISTS basic_auth;

CREATE TYPE basic_auth.jwt_token as (
  token text
);

CREATE TABLE IF NOT EXISTS
basic_auth.login_users (
  username    text primary key not null, --check ( username ~* '^.+@.+\..+$' ),
  pass     text not null check (length(pass) < 512) default '1234',
  in_role     name not null check (length(in_role) < 512)
  -- role     name not null check (length(role) < 512) default ''
);


CREATE OR REPLACE FUNCTION
basic_auth.check_role_exists() returns trigger
  language plpgsql
  as $$
  
begin
    IF new.in_role = 'postgres' THEN
      RAISE invalid_role_specification USING MESSAGE =
        'invalid database role: ' || new.in_role;
      RETURN null;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles as r WHERE r.rolname = new.in_role) THEN
      RAISE foreign_key_violation USING MESSAGE =
        'unknown database role: ' || new.in_role;
      RETURN null;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles as r WHERE r.rolname = new.username) THEN
        EXECUTE ('CREATE ROLE ' || quote_ident(new.username) || ' in role ' || quote_ident(new.in_role) || ' ; ' );
    
    END IF;

    RETURN new;
END
$$;


drop trigger IF EXISTS ensure_user_role_exists ON basic_auth.login_users;
CREATE constraint trigger ensure_user_role_exists
  after insert or update ON basic_auth.login_users
  for each row
  EXECUTE procedure basic_auth.check_role_exists();

CREATE or replace FUNCTION
basic_auth.setup_user() returns trigger
  language plpgsql
  as $$
begin
  IF tg_op = 'INSERT' or new.pass <> old.pass THEN
    new.pass = crypt(new.pass, gen_salt('bf'));
  END IF;

  RETURN new;
END
$$;


drop trigger if exists login_users_before_upsert on basic_auth.login_users;
create trigger login_users_before_upsert
  before insert or update on basic_auth.login_users
  for each row
  execute procedure basic_auth.setup_user();


CREATE or replace FUNCTION
basic_auth.get_role(username text, pass text) returns name
  language plpgsql
  as $$
begin
  RETURN (

  SELECT u.username FROM basic_auth.login_users u
   WHERE u.username = get_role.username
     AND u.pass = crypt(get_role.pass, u.pass)
  );
END;
$$;

CREATE or replace FUNCTION
public.login(username text, pass text) returns basic_auth.jwt_token
  language plpgsql
  as $$
declare
  _role name;
  result basic_auth.jwt_token;
begin
  -- check username AND password
  SELECT basic_auth.get_role(username, pass) into _role;
  IF _role is null THEN
    RAISE invalid_password USING MESSAGE = 'invalid user or password';
  END IF;

  SELECT sign(
      row_to_json(r), current_setting('app.jwt_secret')
    ) as token
    FROM (
      SELECT login.username as role, login.username as username,
         extract(epoch FROM now())::integer + 60*60 as exp
    ) r
    into result;

  RETURN result;
END;
$$;

-- required roles for postgrest authorization/ authentication
CREATE ROLE anon;
CREATE ROLE authenticator NOINHERIT;
GRANT anon TO authenticator;


-- required permissions for postgrest authorization/ authentication
GRANT usage ON SCHEMA public, basic_auth TO anon, authenticator;
GRANT SELECT ON TABLE pg_authid, basic_auth.login_users TO anon;
GRANT EXECUTE ON FUNCTION public.login(text,text) TO anon;

