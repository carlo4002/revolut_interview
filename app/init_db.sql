\c postgres
create table birthdays ( username varchar(250) primary key, birthday date not null);
create role app_role;
grant insert on birthdays to app_role;
grant select  on birthdays to app_role;
create user app with login password 'password' in role app_role;