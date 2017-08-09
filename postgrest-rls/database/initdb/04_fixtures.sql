\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

set role postgres;

-- insert into basic_auth.login_users (username, in_role) values ('superman','postgres'); -- raises error
insert into basic_auth.login_users (username, in_role) values ('man','manager');

insert into basic_auth.login_users (username, in_role) values ('joe','sales_auditor');
insert into basic_auth.login_users (username, in_role) values ('omar','accounting_auditor');

insert into basic_auth.login_users (username, in_role) values ('ziad','salesman');
insert into basic_auth.login_users (username, in_role) values ('imad','salesman');

insert into basic_auth.login_users (username, in_role) values ('rawad','accountant');
insert into basic_auth.login_users (username, in_role) values ('jawad','accountant');


insert into public.invoice (type, amount, salesman, created_by ) values ('out', 3112197, 'ziad', 'jawad');
insert into public.invoice (type, amount, salesman, created_by ) values ('in', 829997, 'imad', 'rawad');
insert into public.invoice (type, amount, salesman, created_by ) values ('in', 3232, 'imad', 'man');
insert into public.invoice (type, amount, salesman, created_by ) values ('out', 1101097, 'ziad', 'jawad');
insert into public.invoice (type, amount, salesman, created_by ) values ('out', 99097, 'ziad', 'rawad');
insert into public.invoice (type, amount, salesman, created_by ) values ('out', 4327, 'ziad', 'man');
insert into public.invoice (type, amount, salesman, created_by ) values ('in', 1723297, 'imad', 'jawad');

insert into public.product (name, price, created_by ) values ('car', 10203, 'ziad');
insert into public.product (name, price, created_by ) values ('caramel', 14, 'imad');
insert into public.product (name, price, created_by ) values ('carbon fiber', 37, 'imad');
insert into public.product (name, price, created_by ) values ('carpet', 250, 'ziad');
insert into public.product (name, price, created_by ) values ('carton', 2, 'imad');

