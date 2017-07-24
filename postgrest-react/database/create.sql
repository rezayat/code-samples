CREATE DATABASE earth;

\connect earth

Create table Animals (
    id serial primary key not null,
    kingdom varchar(200) not null default '',
    phylum varchar(200) not null default '',
    class varchar(200) not null default '',
    order_ varchar(200) not null default '',
    family varchar(200) not null default '',
    genus varchar(200) not null default '',
    species varchar(200) not null default '',
    binomial_name varchar(200) not null default '',
    known_name varchar(200) not null default '',
    conservation_status varchar(100) not null default '',
    extinct boolean not null default FALSE,
    population real not null default 0,
    created_at timestamp default CURRENT_TIMESTAMP
);

insert into Animals (
    kingdom,
    phylum,
    class,
    order_,
    family,
    genus,
    species,
    binomial_name,
    known_name,
    conservation_status,
    extinct,
    population
) values (
    'Animalia',
    'Chordata',
    'Mammalia',
    'Carnivora',
    'Felidae',
    'Panthera',
    'P. tigris',
    'Panthera tigris',
    'Tiger',
    'Endangered',
    FALSE,
    9893
);


insert into Animals (
    kingdom,
    phylum,
    class,
    order_,
    family,
    genus,
    species,
    binomial_name,
    known_name,
    conservation_status,
    extinct,
    population
) values (
    'Animalia',
    'Chordata',
    'Mammalia',
    'Carnivora',
    'Caniformia',
    'Ursidae',
    'U. arctos',
    'Ursus arctos',
    'Kodiak Bear',
    'Least Concern',
    FALSE,
    92839
);
