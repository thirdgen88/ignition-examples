create schema central;
create or replace user central identified by 'central';
grant ALL on central.* to central;

create schema sitea;
create or replace user sitea identified by 'sitea';
grant ALL on sitea.* to sitea;

create schema siteb;
create or replace user siteb identified by 'siteb';
grant ALL on siteb.* to siteb;
