create schema central;
create or replace user central identified by 'central';
grant ALL on central.* to central;

create schema local1;
create or replace user local1 identified by 'local1';
grant ALL on local1.* to local1;

create schema remote1;
create or replace user remote1 identified by 'remote1';
grant ALL on remote1.* to remote1;
