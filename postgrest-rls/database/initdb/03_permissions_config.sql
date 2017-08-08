\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

-- Application Roles

create role accountant nologin;
create role salesman nologin;

create role accounting_auditor nologin;
create role sales_auditor nologin;

create role auditor nologin;

create role manager nologin;

grant auditor to accounting_auditor;
grant auditor to sales_auditor;

-- table invoice
revoke all privileges on invoice from public;
grant all on invoice to manager, accountant;
grant select on invoice to accounting_auditor,manager;

grant select on invoice to salesman, sales_auditor;

-- table product
revoke all privileges on product from public;
grant all on product to manager, salesman;
grant select on product to sales_auditor,manager;

-- grant sequences usage to all
grant usage, select on all sequences in schema public to public;

alter table public.invoice enable row level security;

drop policy if exists invoice_policy on public.invoice;

create policy invoice_policy on public.invoice
  using ((current_role = created_by) or (current_role = salesman) or pg_has_role('auditor','member') or pg_has_role('manager','member')) -- select
  with check (current_role = created_by); -- delete update insert



alter table public.product enable row level security;

drop policy if exists product_policy on public.product;

create policy product_policy on public.product
  using ((current_role = created_by) or pg_has_role('auditor','member') or pg_has_role('manager','member')) -- select
  with check (current_role = created_by); -- delete update insert
