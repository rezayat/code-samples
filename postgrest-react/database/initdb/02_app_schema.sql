\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB

Create table public.applicants (
    id serial primary key not null,
    username varchar(100) not null,
    email varchar(500) not null,
    active boolean not null default TRUE,
    row_role varchar(100) default current_role,
    created_at timestamp default CURRENT_TIMESTAMP
);

