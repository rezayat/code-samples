\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

    
insert into basic_auth.login_users values ('pg','1234','postgres');
insert into basic_auth.login_users values ('admin','1234','admin');
insert into basic_auth.login_users values ('omar','1234','employee');
insert into basic_auth.login_users values ('rawad','1234','employee');

insert into public.applicants (username, email, active, created_at, row_role) values ('test_user 1','test.user_1@gmail.com',true,'2017-6-7 01:23:45','employee');
insert into public.applicants (username, email, active, created_at, row_role) values ('test_user 2','test.user_2@gmail.com',true,'2017-7-8 01:23:45','employee');
insert into public.applicants (username, email, active, created_at, row_role) values ('test_user 3','test.user_3@gmail.com',true,'2017-8-9 01:23:45','admin');
