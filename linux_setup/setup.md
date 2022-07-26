
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

#linux ll命令时间,Linux ll命令显示年月日 时分秒
alias ll='ls -lh  --time-style=+"%Y-%m-%d %H:%M:%S"'


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

### 安装docker
```bash
cd /etc/yum.repos.d/
wget http://mirrors.aliyun.com/repo/Centos-7.repo
sed -i 's/$releasever/7/g' /etc/yum.repos.d/Centos-7.repo
yum makecache

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce  
systemctl start docker
systemctl enable docker

```




### nexus 机器安装docker-compose：
```bash
$ curl -L https://github.com/docker/compose/releases/download/1.29.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

$ chmod +x /usr/local/bin/docker-compose
$ docker-compose --version 

#启动服务
docker-compose -f docker-compose.yml up -d

#停止服务
docker-compose -f docker-compose.yml stop

#停止并删除服务
docker-compose -f docker-compose.yml down 
```



### 翻不了墙 ？ 
```bash
$ vi /etc/profile
export http_proxy=http://40.125.172.218:7878
export https_proxy=http://40.125.172.218:7878
$ source /etc/profile
# 取消代理
$ unset http_proxy
$ unset http_proxy
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
      - /home/lifalin/nexus.vmoptions:/opt/sonatype/nexus/bin/nexus.vmoptions #添加选项 -Dstorage.diskCache.diskFreeSpaceLimit=2048 否则内存不足

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

### 安装 nvm:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
mv root/.nvm /opt/nvm
export NVM_DIR="/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#检查nvm下安装了哪些node版本
nvm ls
nvm install 8.9.1
nvm use 8.9.1

nvm ls-remote
nvm install v16.16.0
chown -R jenkins:jenkins /var/lib/jenkins/workspace/deepwebclient/UI

```
### 安装 cli:
编译报错时候, 删除node_modules 文件夹重新安装npm 依赖包 npm install
没有哪个模块(vue-cli-service) 看node_modules/.bin 下是否有该执行文件
```bash
npm install -g @vue/cli
npm install -g @vue/cli-service

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
$ ln -s /usr/local/python3/bin/python3 /usr/bin/python3 
$ ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3 
$ ln -s /usr/local/python3/bin/gunicorn /usr/bin/gunicorn 
$ yum install --reinstall python3-pip 
$ python3 -V 

export PYTHON_HOME= /usr/local/python3
export PATH=$PYTHON_HOME/bin:$PATH

$ pip3 install --upgrade pip #升级pip3
$ pip3 install grpcio
$ pip3 install grpcio-tools googleapis-common-protos   

yum install python-pip


```

### 安装go:
```bash
$ wget https://go.dev/dl/go1.18.1.linux-amd64.tar.gz
$ tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz 
$ go version
$ cat /etc/profile|grep GO
export GO_HOME=/usr/local/go
export GO_ROOT=/usr/local/go
export GO_PATH=/opt/go
export GO111MODULE=on
export GOPROXY=http://192.168.2.99:9081/repository/group-go/ #http://devops:devops@192.168.2.99:9081/repository/group-go/
PATH=$PATH:$GO_HOME:$GO_ROOT:$GO_PATH:$GO_HOME/bin

$ go env -w GOSUMDB=off

$ go get -u github.com/gin-gonic/gin@v1.4.0 # 测试下载
$ go get -u github.com/smartystreets/goconvey@v1.6.4 --registory=http://192.168.2.99:9081/repository/go-proxy

# go to http://www.tcpdump.org/#latest-release，
# 参考https://blog.csdn.net/wuyou1995/article/details/104742424
$ wget https://www.tcpdump.org/release/libpcap-1.10.1.tar.gz
$ tar -vxzf libpcap-1.10.1.tar.gz
$ cd libpcap-1.10.1 && ./configure
$ cp pcap.h /usr/include/

$ yum install libpcap-devel 缺少pcap组件
 
$ pip3 install -r requirements.txt
$ pip3 install --upgrade gevent==20.9.0

```


### 安装harbor :
```bash
wget https://github.com/goharbor/harbor/releases/download/v1.9.3/harbor-offline-installer-v1.9.3.tgz 
tar xf harbor-offline-installer-v1.9.3.tgz
cp harbor.yml harbor.yml.bak  
sed -i "s|reg.mydomain.com|192.168.1.208|g" harbor/harbor.yml  #调整配置文件
sed -i "s|Harbor12345|whsir.com|g" harbor/harbor.yml

./harbor/install.sh --with-clair #安装harbor


#client 机器上如何登录harbor
vim /etc/docker/daemon.json
{
  "insecure-registries":["harbor机器IP"]
}
systemctl daemon-reload
systemctl restart docker
./harbor/install.sh #重启docker ，因为cs 同在一个机器

docker login http://192.168.2.142  #admin/Harbor12345

#docker login -u admin --password-stdin http://192.168.2.142

docker image save centos:deeptunBase_20210624 > centos_deeptunbase.tar

wget -c --http-user=clouddeep --http-passwd='Clouddeep@8890'  http://139.217.185.199:18180/centos_deeptunbase.tar

docker load < centos_deeptunbase.tar
docker tag centos:deeptunBase_20210624 192.168.2.142/library/centos:deeptunBase_20210624
docker push 192.168.2.142/library/centos:deeptunBase_20210624


mv XX /project/devops_web/ 

wget -c --http-user=clouddeep --http-passwd='Clouddeep@8890'  http://139.217.185.199:18180/redcore_manager.6.8.8.635e806.tar.gz
wget -c --http-user=clouddeep --http-passwd='Clouddeep@8890'  http://139.217.185.199:18180/deeppush.1.2.3.b229161.tar.gz 
```



### 磁盘扩容方法：
```bash
#查看磁盘分区情况
[root@jenkins_falin deepdns]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   45G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
├─sda2            8:2    0   15G  0 part 
│ ├─centos-root 253:0    0 13.4G  0 lvm  /
│ └─centos-swap 253:1    0  1.6G  0 lvm  [SWAP]
└─sda3            8:3    0   24G  0 part 
sr0              11:0    1  4.4G  0 rom  

[root@jenkins_falin demo]# pvcreate /dev/sda3
  Physical volume "/dev/sda3" successfully created.
[root@jenkins_falin demo]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               <15.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              3839
  Free PE               0
  Allocated PE          3839
  PV UUID               9NYTeH-PgGE-50x3-RBOT-8daX-rjKe-5g2Ady
   
  "/dev/sda3" is a new physical volume of "24.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sda3
  VG Name               
  PV Size               24.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               b2vMOm-gZ80-fhYl-46Kh-l5Dp-skCT-uO9mmO
   
[root@jenkins_falin demo]# mkfs.ext4 /dev/sda3
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
1572864 inodes, 6291456 blocks
314572 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2153775104
192 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done   

[root@jenkins_falin demo]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               <15.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              3839
  Free PE               0
  Allocated PE          3839
  PV UUID               9NYTeH-PgGE-50x3-RBOT-8daX-rjKe-5g2Ady
   
[root@jenkins_falin demo]# pvcreate /dev/sda3
WARNING: ext4 signature detected on /dev/sda3 at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/sda3.
  Physical volume "/dev/sda3" successfully created.
[root@jenkins_falin demo]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               <15.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              3839
  Free PE               0
  Allocated PE          3839
  PV UUID               9NYTeH-PgGE-50x3-RBOT-8daX-rjKe-5g2Ady
   
  "/dev/sda3" is a new physical volume of "24.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sda3
  VG Name               
  PV Size               24.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               Z5tVum-eSwz-0J9R-HXDo-EQb1-X1n5-gr3uNN
   
[root@jenkins_falin demo]# vgextend centos /dev/sda3
  Volume group "centos" successfully extended
[root@jenkins_falin demo]# lvextend -L +24G /dev/mapper/centos-root
  Insufficient free space: 6144 extents needed, but only 6143 available
[root@jenkins_falin demo]# cat /etc/fstab | grep centos-root
/dev/mapper/centos-root /                       xfs     defaults        0 0
[root@jenkins_falin demo]# xfs_growfs /dev/mapper/centos-root
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=877824 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=3511296, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@jenkins_falin demo]# lvextend -L +9G /dev/mapper/centos-root
  Size of logical volume centos/root changed from 13.39 GiB (3429 extents) to 22.39 GiB (5733 extents).
  Logical volume centos/root successfully resized.
   
[root@jenkins_falin demo]# xfs_growfs /dev/mapper/centos-root
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=877824 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=3511296, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 3511296 to 5870592
[root@jenkins_falin demo]# df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 1.9G     0  1.9G   0% /dev
tmpfs                    1.9G     0  1.9G   0% /dev/shm
tmpfs                    1.9G  8.9M  1.9G   1% /run
tmpfs                    1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/mapper/centos-root   23G  9.3G   14G  42% /
/dev/sda1               1014M  150M  865M  15% /boot
tmpfs                    379M     0  379M   0% /run/user/0
tmpfs                    379M     0  379M   0% /run/user/998

$ fdisk -l 
$ fdisk /dev/sda    #后依次输入n, p, 3, w
$ reboot            #一定要重启，否则下边操作 会报 /dev/sda3 not found
$ pvcreate /dev/sda3
$ mkfs.ext4 /dev/sda3
$ vgextend centos /dev/sda3
$ cat /etc/fstab | grep centos-root
$ lvextend -L +9G /dev/mapper/centos-root
$ xfs_growfs /dev/mapper/centos-root #使用相应的命令来扩展磁盘空间
$ lvextend -L +14G /dev/mapper/centos-root
$ xfs_growfs /dev/mapper/centos-root

# 参考
# https://www.jb51.net/article/230685.htm
# https://blog.csdn.net/qq_45143653/article/details/119649813
```


### 安装elasticsearch
```bash
$ wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.7.0-linux-x86_64.tar.gz
$ tar -vxzf elasticsearch-6.7.0-linux-x86_64.tar.gz

$ mv ./elasticsearch-6.7.0/* /usr/local/elasticsearch/ #
$ cat /usr/local/elasticsearch/config/elasticsearch.yml |grep -v "^#"

cluster.name: my-application                  
path.data: /usr/local/elasticsearch/data          
path.logs: /usr/local/elasticsearch/log
bootstrap.memory_lock: false     
network.host: 0.0.0.0                     #允许任何机器访问
http.port: 9200
# xpack.security.enabled: false             #es8默认是true,要改成false,即关闭安全认证
# xpack.security.enrollment.enabled: true
# xpack.security.http.ssl:
#   enabled: false
#   keystore.path: certs/http.p12
# xpack.security.transport.ssl:
#   enabled: true
#   verification_mode: certificate
#   keystore.path: certs/transport.p12
#   truststore.path: certs/transport.p12
# cluster.initial_master_nodes: ["targetserver_falin"]
# ingest.geoip.downloader.enabled: false

http.cors.enabled: true
http.cors.allow-origin: "*"


$ cat /usr/local/elasticsearch/config jvm.options |grep -Xms # 调整内存 默认即可

$ mkdir -p /usr/local/elasticsearch
$ useradd esSS
$ passwdadd es

$ chown -R es:es /usr/local/elasticsearch/data
$ chown -R es:es /usr/local/elasticsearch/log
$ chown -R es:es /usr/local/elasticsearch   #别写错了 一定要有权限启动
$ vim /etc/systemd/system/elasticsearch.service #  std机器上的配置文件路径是 /usr/lib/systemd/system/elasticsearch.service

[Unit]
Description=elasticsearch

[Service]
User=es
Group=es
Type=forking
LimitNOFILE=65535
LimitNPROC=4096
ExecStart=/usr/local/elasticsearch/bin/elasticsearch -d

[Install]
WantedBy=multi-user.target

$ sudo su elasticsearch
$ /etc/elasticsearch/bin/elasticsearch

$ vim /etc/sysctl.conf
vm.max_map_count = 262144 #添加参数
$ sysctl -p #重新加载/etc/sysctl.conf配置


$ vim /etc/security/limits.conf #改完需要重新登录才能生效，或者切换用户
*  hard nofile 65536
*  soft nofile 131072
*  soft nproc 4096
*  hard nproc 4096

$ su es #切换用户
$ su root

cat /etc/ssh/sshd_config |grep UsePAM 
UsePAM yes

cat /etc/pam.d/system-auth | grep pam_limits.so 
session required pam_limits.so

cat /etc/pam.d/login | grep pam_limits.so #
session required /lib64/security/pam_limits.so

cat /etc/security/limits.d/20-nproc.conf |grep nofile
*  hard nofile 65536
*  soft nofile 65536


vi /etc/pam.d/su #注释掉以下，否则服务切换用户
#session               include         system-auth

```


### 安装es head：
```bash
yum install -y unzip

# go to github download source code: https://github.com/mobz/elasticsearch-head
cd elasticsearch-head
npm install
#出错 ： Error: phantomjs-prebuilt@2.1.16 install: `node install.js`
#解决办法：
npm -g install phantomjs-prebuilt@2.1.16 --ignore-script  
#再出同样的错也不用管了， 直接npm run start就可以
npm run start
#接着可以访问 http://ip:9100 

vim Gruntfile.js 
# 添加hostname: "*", 
    connect: {
          server: {
            options: {
              hostname: "*",
              port: 9100,
              base: '.',
              keepalive: true
            }
			  }
    }

```


### 安装filebeat:
```bash
$ vim /etc/yum.repos.d/filebeat.repo
[filebeat-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md 
$ yum install filebeat -y

```


### 安装kibana:
调整cpu 核数为2 ，
```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.2.2-x86_64.rpm
cd /etc/kibana

cat 
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://127.0.0.1:9200"]      # 连接es地址
kibana.index: ".kibana"                             # 开启索引数据库文件
elasticsearch.username: "elastic"                   # 这里如果es还没设置密码，这里写上密码也不影响kibana启动
elasticsearch.password: "Clouddeep@8890"


```

### 安装mysql
```bash
wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.37-linux-glibc2.12-i686.tar.gz
tar -xvf mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz
mv mysql-5.7.22-linux-glibc2.12-x86_64 /usr/local/mysql 
groupadd mysql
useradd -r -g mysql mysql
chown mysql:mysql -R /data/mysql
mkdir -p /data/mysql



wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.37-1.el7.x86_64.rpm-bundle.tar  #下载
tar -xvf mysql-5.7.37-1.el7.x86_64.rpm-bundle.tar -C /usr/local/mysql
cd /usr/local/mysql/
yum install mysql-community-libs-5.7.37-1.el7.x86_64.rpm mysql-community-libs-compat-5.7.37-1.el7.x86_64.rpm mysql-community-common-5.7.37-1.el7.x86_64.rpm
yum install mysql-community-client-5.7.37-1.el7.x86_64.rpm 
yum install mysql-community-server-5.7.37-1.el7.x86_64.rpm

echo 'skip-grant-tables' > /etc/my.cnf  # 跳过授权表,run this command for logging in without passwd
mysql -u root # 空密码登录
mysql> UPDATE mysql.user SET authentication_string=password('Clouddeep@8890') WHERE User='root';  # 更新密码
mysql> flush privileges;              # 刷新策略
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'Clouddeep@8890';                              # 再次修改密码24
# 删除/etc/my.cnf中的skip-grant-tables，并重启mysql
systemctl restart mysqld  # 重启mysql

mysql> show databases;    # 查看
mysql> create database rdc_manager;

#添加用户
mysql> create user clouddeep;
mysql> UPDATE mysql.user SET authentication_string=password('Clouddeep@8890') WHERE User='clouddeep';
mysql> ALTER USER 'clouddeep'@'%' IDENTIFIED BY 'Clouddeep@8890'; 


```



### 设置vscode:
```bash
#设置zoom in/out in editor by mouse scheel
# F1, 搜索 settings.json , open settings (JSON) 添加
 "editor.mouseWheelZoom": true,  #only save, 即刻生效 

```



### 安装nginx:
```bash
yum isntall -y nginx 
ps -ef|grep nginx 

nginx -t #查看nginx 配置文件
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


### 通过ssh expect 间接登录主机
```bash


# 安装expect 
$ yum install tcl-devel
$ yum install expect

```

### windows 中跑windows docker 容器：
```bash

#安装docker for windows 4.4.4 版本别高了
#别在C:\User\XX 下运行Dockerfile 会报错
#将"experimental" 设置为true，应用并重启
#写好Dockerfile
mkdir dockerfiles
cd dockerfiles
vi Dockerfile
docker build -t mytag .  #. 表示当前路径

# 进入容器
docker exec -it dockerid cmd

docker build -f DockerfileSDP -t sdp:6.9.4 .
docker build -f DockerfileWG -t wg:1 .

# 1. run 
docker run -d wg:2 cmd /S /C ping -t 114.114.114.114

#启动容器
docker run -idt wg:1 cmd.exe
docker run --user "NT Authority\System" -dit  wg:1 cmd.exe
#进入容器，admin 权限
docker exec --user ContainerAdministrator -it <container_id> cmd
docker exec --user "NT Authority\System" -it 8717d716d431 cmd


echo %USERDOMAIN%\%USERNAME%


docker build -f DockerfileWG3 -t wg:3 .
docker rm -f $( docker ps -aq --no-trunc  --filter ancestor=wg:1)

taskkill /f /pid 1868



#退出容器
exit 

```



### wireguard:
```bash

wg-quick up wg0    #启动服务端
wg-quick down wg0  #停止服务端
wg #查看节点列表


#server :
[Interface]
Address = 10.100.0.1/16  # 这里指的是使用 10.100.0.1，网段大小是 16 位
SaveConfig = true
ListenPort = 51820  # 监听的 UDP 端口
PrivateKey = KMAVNsiiW1gtiWN+N0Bf9bcXznv7r5o2z/6qTXu7JVM=
# 下面这两行规则允许访问服务器的内网,注意替换`eth0`
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens192 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens192 -j MASQUERADE

# Client，可以有很多 Peer
[Peer]
PublicKey = 4Zw2U+iyql0ByXxt1Oy5jGIxTp5Y3sG3C3gepyH39nk=
AllowedIPs = 10.100.0.2/32

[Peer]
PublicKey = MmmfJH3oOXSQPKk+Urv/97AVo5bVOEQl6vTLLJclPFc=
AllowedIPs = 10.100.0.3/32





#client2 :
[Interface]
PrivateKey = eEq8t1nSuf52+e9Pq9qN2FVnNW7dhXTUpPhzLNVyD1M=
Address = 10.100.0.2/32
DNS = 8.8.8.8  # 连接后使用的 DNS, 如果要防止 DNS 泄露，建议使用内网的 DNS 服务器

[Peer]
PublicKey = 16bMBy7J70JVASjKMsG8SvfJ093IQt1PiQU9Q11H3Ak=
Endpoint = 192.168.2.248:51820  # 服务端公网暴露地址，51280 是上面指定的
AllowedIPs = 10.100.0.0/16,172.17.0.11/20  # 指定要访问的服务端网段,或者设置0.0.0.0/0来进行全局代理.
PersistentKeepalive = 25



#client3 :
[Interface]
PrivateKey = 8N+n+lwrhaGt1FhF3zzKTg5kNtAzgM8h1EUoeDXNcFM=
Address = 10.100.0.3/32
DNS = 8.8.8.8  # 连接后使用的 DNS, 如果要防止 DNS 泄露，建议使用内网的 DNS 服务器

[Peer]
PublicKey = 16bMBy7J70JVASjKMsG8SvfJ093IQt1PiQU9Q11H3Ak=
Endpoint = 192.168.2.248:51820  # 服务端公网暴露地址，51280 是上面指定的
AllowedIPs = 10.100.0.0/16,172.17.0.11/20  # 指定要访问的服务端网段,或者设置0.0.0.0/0来进行全局代理.
PersistentKeepalive = 25

```


### clickhouse-server, clickhouse-client 安装：
```bash
yum install clickhouse-server
yum install clickhouse-client

systemctl start clickhouse-server
yum remove clickhouse-server

#生成password命令：
echo -n Clouddeep@8890 | openssl dgst -sha256

#登录：-m 进入交互界面 可以换行，命令以;分号结束
clickhouse-client -m #以default user身份登录
clickhouse-client -m -u clouddeep --password #以clouddeep user身份登录

shou databases;
shou tables;
#离开
quit


```


```xml
<!--设置用户名i密码：-->
<!--修改/etc/clickhouse-server/users.xml，在users中添加节点：
password 生成命令： echo -n Clouddeep@8890 | openssl dgst -sha256
填入 password_sha256_hex 节点中
或者直接用password 节点明文显示密码
echo -n 123 | openssl dgst -sha256
a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
<password_sha256_hex>a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3</password_sha256_hex>

echo -n Clouddeep@8890 | sha256sum | tr -d '-'
echo -n Clouddeep@8890 | openssl dgst -sha256
0f872baa8ac9553a224e5c2d6e5a0ec3e46cf25a780f979dd5b4dde8474ff772
<password_sha256_hex>0f872baa8ac9553a224e5c2d6e5a0ec3e46cf25a780f979dd5b4dde8474ff772</password_sha256_hex>
-->
<clouddeep>           
      <networks>
      <ip>::/0</ip>
      </networks>
      <profile>default</profile>
      <quota>default</quota>
      <!-- <password>Clouddeep@8890</password> -->
			<password_sha256_hex>0f872baa8ac9553a224e5c2d6e5a0ec3e46cf25a780f979dd5b4dde8474ff772</password_sha256_hex>
</clouddeep>

```


### scp via jumpserver:
```bash
https://superuser.com/questions/276533/scp-files-via-intermediate-host
https://mperdikeas.github.io/networking.html.files/scp-a-file-through-jump-host.html
https://blog.csdn.net/sj349781478/article/details/114308331 密码带有特殊符号
```bash

#work
scp -oProxyCommand="ssh -W %h:%p B" thefile C:destination
scp -oProxyCommand="ssh -W %h:%p 192.168.2.99" anaconda-ks.cfg 192.168.2.248:/env

yum install sshpass
sshpass -p 'Clouddeep@8890' scp -o 'ProxyCommand ssh root@192.168.2.99 -W %h:%p' anaconda-ks.cfg root@192.168.2.248:/env

#不太work, 因为有堡垒机
[root@jenkins ~]# sshpass scp -o "ProxyCommand sshpass -p ''JenkinsClouddeep@8890!'' ssh jenkins@139.217.97.252  -W %h:%p" anaconda-ks.cfg jmsadmin@120.92.91.72:/env
-bash: !'': event not found

[root@jenkins ~]# sshpass scp -o 'ProxyCommand sshpass -p ''JenkinsClouddeep@8890!'' ssh jenkins@139.217.97.252  -W %h:%p' anaconda-ks.cfg jmsadmin@120.92.91.72:/env
channel 0: open failed: unknown channel type: unsupported channel type
stdio forwarding failed
ssh_exchange_identification: Connection closed by remote host
lost connection

[jmsadmin@jenkins ~]$ sudo -i
[root@jenkins ~]# sshpass -p 'JenkinsClouddeep@8890!' scp anaconda-ks.cfg jenkins@139.217.97.252:/Default/rc/spa/rc-spa
No PTY requested.

sshpass -p "user_password" sftp user@sftp.server.com:remote_dir <<< $'put *.csv'


```


### sftp 传文件：
```bash
$ sftp remote-system
Password: password
sftp> put filename
sftp> bye
```

### nginx 安装：
```bash
yum install gcc-c++
yum install -y openssl openssl-devel
yum install -y pcre pcre-devel
yum install -y zlib zlib-devel
mkdir /usr/local/nginx
cd /home/lifalin
wget https://nginx.org/download/nginx-1.23.0.tar.gz
tar -zxvf -1.23.0.tar.gz

#手动创建用户和用户组
groupadd nginx
useradd nginx -g nginx -s /sbin/nologin -M

cd nginx-1.23.0
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --user=nginx --group=nginx

make			# 编译
make install  		# 安装


#修改nginx.conf, 修改端口 
user  nginx nginx;
http {  
    server {
        listen       18180;      
    }
}

/usr/local/nginx/sbin/nginx            # 启动服务
/usr/local/nginx/sbin/nginx -s reload  # 重新加载服务
/usr/local/nginx/sbin/nginx -s stop  # 停止服务

vim /lib/systemd/system/nginx.service  
# /etc/systemd/system     #存放系统启动的默认级别及启动的unit的软连接，优先级最高。
# /run/systemd/system     #系统执行过程中产生的服务脚本，优先级次之。
# /usr/lib/systemd/system #存放系统上所有的启动文件。优先级最低

[Unit]
Description=The NGINX HTTP and reverse proxy server

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit

[Install]
WantedBy=multi-user.target

systemctl deamon-reload
```

### linux 创建cronjob:
```bash

vim /project/cronjob/clear_image.sh
#!/bin/bash
time=`docker images |grep 'months' |grep 'deeptun'|awk '{print $4}'`
for i in $time
do
  if [ $i -ge 6 ]; then
    docker images | awk '{print $3}' |xargs docker rmi 
  fi
done

crontab -e    # 编辑crontab 指令
crontab -l    # 查看 定时任务 列表
0 0 1,15 * * /bin/bash   /project/cronjob/clear_image.sh  # 每个月1号15号运行该脚本 
```


