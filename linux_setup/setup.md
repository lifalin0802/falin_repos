
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
hostnamectl set-hostname Jfrog  #设置主机名

cat /etc/hostname  #检查主机名
reboot # 重启机器
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
vi /etc/profile
export http_proxy=http://40.125.172.218:7878
export https_proxy=http://40.125.172.218:7878
source /etc/profile
```



### yum install 不好使？
直接找 ```http://www.rpmfind.net/linux/rpm2html/search.php?query=wget(x86-64)``` linux rpm resource 搜索, 下载rpm 包离线安装


### 安装jfrog
```bash
docker run --name artifactory -d -p 8081:8081 -p 8082:8082 \
   -v /jfrog/artifactory:/var/opt/jfrog/artifactory \
   -e EXTRA_JAVA_OPTIONS='-Xms512m -Xmx2g -Xss256k -XX:+UseG1GC' \
   docker.bintray.io/jfrog/artifactory-cpp-ce:latest
```

