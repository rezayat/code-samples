\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

create role admin;
create role employee;

revoke all on applicants from public;
grant select,insert on applicants to public;

-- grant sequences usage to all
grant usage, select on all sequences in schema public to public;

create role anon;
create role authenticator noinherit;
grant anon to authenticator;


grant usage on schema public, basic_auth to anon;
grant select on table pg_authid, basic_auth.login_users to anon;
grant execute on function public.login(text,text) to anon;

alter table applicants enable row level security;

CREATE POLICY applicants_policy ON applicants
  USING (row_role = current_user);
  -- WITH CHECK (row_role = current_user)
