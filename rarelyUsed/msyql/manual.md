



### 外接mysql 
```sql
alter user 'root'@'localhost' identified by '123456';

CREATE DATABASE IF NOT EXISTS grafana default charset utf8 COLLATE utf8_general_ci;
create user grafana identified by 'grafana';
grant all on grafana.* to 'grafana'@'%';
flush privileges;
```

### grafana更改登录账密
还在使用sqlite的情况下
```bash
k exec -it -n prometheus prometheus-grafana-cb95847d8-9xx9d -- sh  #
./bin/grafana-cli admin reset-admin-password admin
```
如果已经改为mysql作为后台数据库
```bash
mysql -uroot -p -h mysql.prometheus.svc
mysql> use grafana;
mysql> update grafana.user set password='59acf18b94d7eb0694c61e60ce44c110c7a683ac6a8f09580d626f90f4a242000746579358d77dd9e570e83fa24faa88a8a6', salt = 'F3FAxVm33R' where login = 'admin';
mysql> quit;
```

### 基本操作：
```sql

CREATE DATABASE grafana
--CREATE USER ‘username’@‘host’ IDENTIFIED BY ‘password’;
CREATE USER 'grafana'@'%' IDENTIFIED BY 'Grafana_123';

-- nacos mysql 账密 root/nacos_New@123
CREATE USER 'prod_cxp_nacos'@'%' IDENTIFIED BY '23!Sj#%Q@W$yQd@7';

--更更改权限
alter user 'root'@'%' IDENTIFIED BY 'Grafana_123';

--用不了？报错
UPDATE mysql.user SET Password=PASSWORD('Grafana_123') WHERE User='grafana';

--赋权
--GRANT privilege ON databasename.tablename TO ‘username’@‘host’
GRANT ALL ON grafana.* TO grafana@'%';  


-- drop user in mysql
DROP USER 'grafana'@'%';

--SET PASSWORD FOR ‘username’@‘host’ = PASSWORD(‘newpassword’);
SET PASSWORD FOR 'pig'@'%' = PASSWORD("123456");


SELECT *
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA='mysql'
AND table_name = 'user';


```