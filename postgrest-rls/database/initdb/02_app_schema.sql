\set POSTGRES_DB `echo "$POSTGRES_DB"`
\connect :POSTGRES_DB


create table public.product (
    id serial primary key not null,
    name text default '',
    price float default 0,
    dummy text default '',
    
    created_by varchar(100) default current_role,
    created_at timestamp default current_timestamp
);

create table public.invoice (
    id serial primary key not null,
    type text default 'in',
    amount float default 0,
    dummy text default '',
    
    salesman varchar(100),
    created_by varchar(100) default current_role,
    created_at timestamp default current_timestamp
);
