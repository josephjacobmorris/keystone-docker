create database if not exists keystone;
create user if not exists keystone@'%' IDENTIFIED BY "opensds#123";
create user if not exists keystone@'localhost' IDENTIFIED BY "opensds#123";
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY "opensds#123";
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY "opensds#123";
FLUSH PRIVILEGES;