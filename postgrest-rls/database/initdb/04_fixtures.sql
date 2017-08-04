\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

-- insert into basic_auth.login_users (username, role) values ('superman','postgres'); -- raises error
insert into basic_auth.login_users (username, role) values ('man','manager');

insert into basic_auth.login_users (username, role) values ('joe','sales_auditor');
insert into basic_auth.login_users (username, role) values ('omar','accounting_auditor');

insert into basic_auth.login_users (username, role) values ('ziad','salesman');
insert into basic_auth.login_users (username, role) values ('imad','salesman');

insert into basic_auth.login_users (username, role) values ('rawad','accountant');
insert into basic_auth.login_users (username, role) values ('jawad','accountant');


insert into public.invoice (type, amount, salesman, row_role ) values ('out', 3112197, 'ziad', 'jawad');
insert into public.invoice (type, amount, salesman, row_role ) values ('in', 829997, 'imad', 'rawad');
insert into public.invoice (type, amount, salesman, row_role ) values ('in', 3232, 'imad', 'man');
insert into public.invoice (type, amount, salesman, row_role ) values ('out', 1101097, 'ziad', 'jawad');
insert into public.invoice (type, amount, salesman, row_role ) values ('out', 99097, 'ziad', 'rawad');
insert into public.invoice (type, amount, salesman, row_role ) values ('out', 4327, 'ziad', 'man');
insert into public.invoice (type, amount, salesman, row_role ) values ('in', 1723297, 'imad', 'jawad');

insert into public.product (name, price, row_role ) values ('car', 10203, 'ziad');
insert into public.product (name, price, row_role ) values ('caramel', 14, 'imad');
insert into public.product (name, price, row_role ) values ('carbon fiber', 37, 'imad');
insert into public.product (name, price, row_role ) values ('carpet', 250, 'ziad');
insert into public.product (name, price, row_role ) values ('carton', 2, 'imad');

