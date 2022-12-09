### 基本操作：
```sql

CREATE DATABASE grafana
--CREATE USER ‘username’@‘host’ IDENTIFIED BY ‘password’;
CREATE USER 'grafana'@'%' IDENTIFIED BY 'Grafana_123';

--更更改权限
alter user 'root'@'%' IDENTIFIED BY 'Grafana_123';

--用不了？报错
UPDATE mysql.user SET Password=PASSWORD('Grafana_123') WHERE User='grafana';

--赋权
--GRANT privilege ON databasename.tablename TO ‘username’@‘host’
GRANT ALL ON grafana.* TO grafana@'%' IDENTIFIED BY 'Grafana_123';



--SET PASSWORD FOR ‘username’@‘host’ = PASSWORD(‘newpassword’);
SET PASSWORD FOR 'pig'@'%' = PASSWORD("123456");


SELECT *
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA='mysql'
AND table_name = 'user';


```