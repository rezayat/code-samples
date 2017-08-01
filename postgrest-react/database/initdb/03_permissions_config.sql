\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

-- Application Roles

create role admin;
create role employee;

revoke all privileges on applicants from public;
grant select,insert on applicants to admin, employee, postgres;

-- grant sequences usage to all
grant usage, select on all sequences in schema public to public;

alter table applicants enable row level security;

CREATE POLICY applicants_policy ON applicants
  USING (row_role = current_role);
  -- WITH CHECK (row_role = current_role)
