### 更新zabbix.repo源
```bash
rpm -ivh http://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm 
yum clean all
yum makecache
```

### 安装zabbix组件
```bash
yum install zabbix-server-mysql zabbix-agent –y 
yum list all |grep -i scl-util # 查看某个包是否存在
yum list php # 查看某个包是否存在
yum search php7
```

### 安装php组件 修改zabbix php前端文件
```bash
yum install centos-release-scl -y
yum --disablerepo="" --enablerepo="scl" list available
yum --disablerepo="" --enablerepo="scl" search <keywords>
yum install zabbix-web-mysql-scl zabbix-apache-conf-scl -y 
vi /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf  #编辑日期 后要 重启服务 
systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
vi /etc/httpd/conf.d/zabbix.conf #里边要加上 zabbix文件夹，不知道为啥不加就报错 mkdir /var/www/html/zabbix/

yum install php php-pear php-cgi php-common php-mbstring php-snmp php-gd php-pecl-mysql php-xml php-mysql php-gettext php-bcmath
#yum install -y zabbix-web-mysql-scl zabbix-apache-conf-scl zabbix-server-mysql zabbix-agent --enablerepo=zabbix-frontend
#修改php_value[date.timezone] = Europe/Riga 为 Asia/Shanghai 
```



### 安装mariadb


### 更新zabbix关于db 的配置
```bash
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz |mysql -uzabbix -p zabbix
mysql -uzabbix -plfl #检查数据库是否导入成功
MariaDB [(none)]> show databases;
MariaDB [(none)]> use zabbix
MariaDB [zabbix]> show tables;  #可以看到导入的表 ctrl c 退出 mariadb
``` 


### 更改数据库后修改zabbix db文件
```bash
vi /etc/zabbix/zabbix_server.conf #修改DBPassword=lfl 修改密码, 修改zabbix服务配置文件
grep '^DPPa' /etc/zabbix/zabbix_server.conf 
``` 

### 修改端口号
```bash

``` 