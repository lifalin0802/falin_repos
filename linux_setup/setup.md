
### 安装软件
```bash
yum search ifconfig #查找包
yum install net-tools

vi /etc/sysconfig/network-scripts/ifcfg-ens192
BOOTPROTO="static"
ONBOOT="yes"   
IPADDR=192.168.2.99  #在192.168.2.116上
GATEWAY=192.168.2.1  #设置 网关

systemctl restart network  #重启网卡
hostnamectl set-hostname Nexus  #设置主机名

cat /etc/hostname  #检查主机名
reboot # 重启机器

#安装epel 要先设置http_proxy 代理
yum install -y epel-release
yum install net-tools

```

### 机器IP 位置：
```https://192.168.2.70/ui/```  
jfrog ip: 192.168.2.99 at @ 192.168.2.116  
jenkins_falin ip: 192.168.2.142 @ 192.168.2.223 


### 连不了网？
重新编辑网卡，重启：
```bash
vi /etc/sysconfig/network-scripts/ifcfg-ens192
ONBOOT="yes"   # 设置为yes
systemctl restart network #后重启网卡
yum -y install ntpdate ntp
ntpdate cn.pool.ntp.org

docker exec -it 827 -u root /bin/sh #容器内部也需要安装ntpdate, 
cat /proc/version 

#nexus 镜像种的系统版本
sh-4.4# uname -a
Linux 827b8f45e7a1 3.10.0-957.el7.x86_64 #1 SMP Thu Nov 8 23:39:32 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
sh-4.4# cat /proc/version 
Linux version 3.10.0-957.el7.x86_64 (mockbuild@kbuilder.bsys.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-36) (GCC) ) #1 SMP Thu Nov 8 23:39:32 UTC 2018
sh-4.4# cat /etc/redhat-release
Red Hat Enterprise Linux release 8.5 (Ootpa)
#安装ntpdate
sh-4.4# wget http://mirror.centos.org/centos/7/os/x86_64/Packages/ntpdate-4.2.6p5-29.el7.centos.2.x86_64.rpm
sh-4.4# yum install ntpdate-4.2.6p5-29.el7.centos.2.x86_64.rpm
sh-4.4# vi /etc/sysconfig/clock #编辑文件
ZONE="Asia/Shanghai"
UTC=false
ARC=false
sh-4.4# ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime #linux的时区设置为上海
sh-4.4# ntpdate cn.pool.ntp.org #对准时间 refered to: https://www.jianshu.com/p/83b9b333f629

```

### 翻不了墙 ？ 
```bash
vi /etc/profile
export http_proxy=http://40.125.172.218:7878
export https_proxy=http://40.125.172.218:7878
source /etc/profile
```


### yum install 不好使？
直接找 ```http://www.rpmfind.net/linux/rpm2html/search.php?query=wget(x86-64)``` linux rpm resource 搜索, 下载rpm 包离线安装


### 安装jfrog
```bash
mkdir /jfrog/artifactory
chown -Rf 101029:101029 /jfrog/artifactory
chmod -R 777 /jfrog/artifactory
docker run --name artifactory -d -p 8081:8081 -p 8082:8082 \
   -v /jfrog/artifactory:/var/opt/jfrog/artifactory \
   -e EXTRA_JAVA_OPTIONS='-Xms512m -Xmx2g -Xss256k -XX:+UseG1GC' \
   --privileged=true \
   docker.bintray.io/jfrog/artifactory-pro:latest  # 社区版将pro改为oss
```

### 重启docker失败？
造成的原因： systemctl disable firewalld时候将iptables重置了  
这时候已经安装了docker 服务
```bash
$ docker start e3
Error response from daemon: driver failed programming external connectivity on endpoint artifactory (d23ac562578db95b2af55a74de6e1f7c14f6a624bf0800effb8a34a64b9cfbdf):  (iptables failed: iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport 8082 -j DNAT --to-destination 172.17.0.2:8082 ! -i docker0: iptables: No chain/target/match by that name.
 (exit status 1))
Error: failed to start containers: e3
#解决办法：重写iptables,重启docker服务
iptables -t nat -N DOCKER
iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL ! --dst 127.0.0.0/8 -j DOCKER
systemctl restart docker
```

### 启动docker需要设置：
```--privileged=true```
```bash
$ docker pull sonatype/nexus3
$ mkdir -p /var/apps/nexus/nexus-data
$ chmod 777 /var/apps/nexus/nexus-data
$ docker run -d --name nexus3 \
   -p 9081:8081 -p 9082:8082 -p 9083:8083 \
   --privileged=true \
   -v /var/apps/nexus/nexus-data:/nexus-data sonatype/nexus3

$ cat /var/apps/nexus/nexus-data/admin.password

vim docker-compose.yml

version: '3'
services:
  nexus:
    restart: always
    image: sonatype/nexus3
    container_name: nexus3
    ports:
      - 9081:8081
	  - 9082:8082
	  - 9083:8083
	privileged: true
	environment:
      - TZ=Asia/Shanghai
    volumes:
      - /var/apps/nexus/nexus-data:/nexus-data
```



### 安装nodejs服务：

```bash
cd /home/lifalin
wget https://nodejs.org/dist/v10.18.0/node-v10.18.0-linux-x64.tar.xz
tar -xvf node-v14.15.1-linux-x64.tar.xz
mv node-v16.15.0-linux-x64 /usr/local/node

vim /etc/profile

export NODEJS=/usr/local/node
export PATH=$NODEJS/bin:$PATH

source /etc/profile

#安装pm2, tsc
npm install -g pm2
npm install -g tsc
npm install -g typescript
npm install cross-env --save-dev 
npm install -g gulp

ln -s /usr/local/node/bin/pm2 /usr/bin/pm2
ln -s /usr/local/bin/gulp /usr/bin/gulp

#targetserver 安装软连接
ln -s "$(which node)" /usr/bin/node
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo apt-get install nodejs-legacy
```


### 配置nodejs proxy:
```bash
sed -i "s/registry.npm.taobao.org/192.168.2.99:9081\/repository\/npm-public/g" .npmrc
npm config set registry http://192.168.2.99:9081/repository/npm-public/

npm set registory=http://192.168.2.99:9081/repository/npm-public/
npm login --registry=http://192.168.2.99:9081/repository/npm-public/

# 设置base64编码
echo -n 'myuser:mypassword' | openssl base64


```

### jenkins 机器安装maven 用于上传tar.gz 包：
```bash
wget https://dlcdn.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz
tar -zxvf apache-maven-3.8.5-bin.tar.gz
mv ./apache-maven-3.8.5 /usr/local/maven
cd /usr/local/maven
mv ./settings.xml ./settings.xml.original
vi ./settings.xml
cat ./settings.xml
#settings.xml配置如下
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd"> 
  <localRepository>/m2/repository</localRepository>
</settings>

vim /etc/profile
#添加如下环境变量
MAVEN_HOME=/usr/local/maven/
PATH=$MAVEN_HOME/bin:$PATH
export MAVEN_HOME PATH
source /etc/profile
```

### 安装python3:
```bash
$ yum -y install wget gcc gcc-c++ zlib-devel bzip2-devel openssl-devel ncurses-devel\
sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel\
xz-devel libffi-devel zlib1g-dev zlib*  
$ wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz
$ tar -xvJf  Python-3.7.2.tar.xz && mkdir /usr/local/python3  
$ cd Python-3.7.2 
#检查
$ ./configure --prefix=/usr/local/python3 --enable-optimizations --with-ssl 
#编译
$ make && make install
$ ln -s /usr/local/python3/bin/python3 /usr/local/bin/python3 
$ ln -s /usr/local/python3/bin/pip3 /usr/local/bin/pip3 
$ yum install --reinstall python3-pip 
$ python3 -V 

export PYTHON_HOME= /usr/local/python3
export PATH=$PYTHON_HOME/bin:$PATH

$ pip3 install --upgrade pip #升级pip3
$ pip3 install grpcio
$ pip3 install grpcio-tools googleapis-common-protos   
```
 


### nexus 机器安装docker-compose：
```bash
$ curl -L https://github.com/docker/compose/releases/download/1.29.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

$ chmod +x /usr/local/bin/docker-compose
$ docker-compose --version 

```


### rsyslog 配置方法：

```bash
systemctl status rsyslog 
vi /etc/rsyslog.conf
vim heartbeat.conf # 这个文件做什么的？
rsyslogd -version #
yum upgrade rsyslog 
```

### ssh免密登录配置方法
场景： 从A登录B主机：  


```bash
# A主机上键入以下命令 用于配置ssh
ssh-kengen # or ssh-keygen -t rsa
ssh-copy-id remote_user@remote_IP # or ssh-copy-id -i ~/.ssh/id_rsa.pub remote-host
#测试 从A主机
ssh remote_IP # 稍等一会就可以连接上

#登录B主机，测试，查看，应与A /root/.ssh/id_rsa.pub 内容一致
#root@jenkins_falin 都是A主机的用户名@主机名
cat /remote_user/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLlJNqak24tOvH5oUKmLiNEVS3YWGy1CnWisL/8u5aI4dclXiHXjp32cYTBgS0kDID3MiUEqJDZSl92VbXJKp/vyfQ4WmzuBz+eeh+oG8iUn1Htt/y/zfQpc8vRQpY1YhodKbK5HQGJipzrUe6Qt81c1gHG/We/B86G7dq+cCj5WeGcLrRsBnTqGBmV7JOHD32h2K4/2tD2iFOYB2A279jTBeUCqv7wzJ0L/pi3S2jzztArqcxrXuG8Q+WSb+bAyUgwL7Y01wu84bs8w7Z4lYNVTB5IjwixpJRqrBG9ERVTNlUkiACjWGuUa7w6fK6yF7FWEbDpS+1kc6u18AfTnZh root@jenkins_falin

```
**说明**
1. sshd 是centos 7自带的服务
2. 


参考文献：  
https://www.appservgrid.com/paw92/index.php/2020/06/06/how-to-setup-ssh-without-passwords-linux-hint/
https://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id/