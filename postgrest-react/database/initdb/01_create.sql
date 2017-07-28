CREATE DATABASE test_db;

\connect test_db

Create table public.users (
    id serial primary key not null,
    username varchar(100) not null,
    email varchar(500) not null,
    active boolean not null default TRUE,
    row_role varchar(100) default current_role,
    created_at timestamp default CURRENT_TIMESTAMP
);

insert into public.users (username, email, active, created_at, row_role) values ('test_user 1','test.user_1@gmail.com',true,'2017-6-7 01:23:45','rawad');
insert into public.users (username, email, active, created_at, row_role) values ('test_user 2','test.user_2@gmail.com',true,'2017-7-8 01:23:45','employee');
insert into public.users (username, email, active, created_at, row_role) values ('test_user 3','test.user_3@gmail.com',true,'2017-8-9 01:23:45','admin');

