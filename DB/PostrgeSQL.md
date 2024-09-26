АНАЛИЗ Безопасности
https://github.com/HexaCluster/pgdsat


```
# Inside the VM
sudo -i -u postgres

# Open PostgreSQL cli
psql

# and create a new user. 
mydatabase=# CREATE ROLE "user" WITH SUPERUSER LOGIN ENCRYPTED PASSWORD 'pass';
mydatabase=# \q # exit

# open conections
/etc/postgresql/14/main/postgresql.conf
>>> listen_addresses 0.0.0.0

# HBA config allows all users to connect from anywhere using their passwords
/etc/postgresql/14/main/pg_hba.conf 
>>> host all all 0.0.0.0/0 md5
```
