CREATE DATABASE test_db;

\connect test_db

Create table public.applicants (
    id serial primary key not null,
    username varchar(100) not null,
    email varchar(500) not null,
    active boolean not null default TRUE,
    row_role varchar(100) default current_role,
    created_at timestamp default CURRENT_TIMESTAMP
);

