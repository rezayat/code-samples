CREATE DATABASE earth;

\connect earth

Create table public.users (
    id serial primary key not null,
    username varchar(100) not null,
    email varchar(500) not null,
    active boolean not null default TRUE,
    created_at timestamp default CURRENT_TIMESTAMP
);

insert into public.users (username, email, active, created_at) values ('test_user','test.user@gmail.com',true,'2017-6-7 01:23:45');
