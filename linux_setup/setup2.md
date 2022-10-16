### keepalive 安装：
LVS是node02, RS 分别是master01, centos

```bash

#DR:
vim /etc/sysctl.conf
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.default.arp_ignore = 1
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2

sysctl -p 

ip a add dev ens33 192.168.5.150/32

ipvsadm -A -t 192.168.5.150:80 -s rr
ipvsadm -a -t 192.168.5.150:80 -r 192.168.5.100:80 -g
ipvsadm -a -t 192.168.5.150:80 -r 192.168.5.140:80 -g


#real server:
ip a add dev lo 192.168.5.150/32  #ip a
route add -host 192.168.5.150 dev lo

#nginx配置 ： 最后要访问 http://192.168.5.150/ 这个虚拟地址
server{
    listen 80;
    #server_name www.mynginx.com
    location / {
        root /var/nginx/html;
        index abc.html;
    }
}


ipvsadm -Ln --stats 
```

### nfs安装：
参考 `https://blog.csdn.net/Ausuka/article/details/121701114`
```bash
yum install nfs-utils -y
service nfs-server start 
systemctl enable nfs-server

#配置文件路径 读写权限
[root@centos ~]# cat /etc/exports
/nfs 192.68.5.100(rw,all_squash,sync)
/nfs *(rw,sync,no_root_squash,no_all_squash)
#/opt/data: 共享目录位置。
#*: 客户端 IP 范围，* 代表所有，即没有限制。
#rw: 权限设置，可读可写。
#sync: 同步共享目录。
#no_root_squash: 可以使用 root 授权。
#no_all_squash: 可以使用普通用户授权。

# 查看配置
[root@centos ~]# exportfs -rv
exporting 192.68.5.100:/nfs

# 挂载 跑到192.168.5.140挂载 并且访问
mkdir /nfs
mount 192.168.5.100:/nfs /nfs

# 选项说明
# rw：可读写
# ro：只读
# no_root_squash：对root用户不压制，如果客户端以root用户写入，在服务端都映射为服务端的root用户
# root_squash：nfs服务：默认情况使用的是相反参数root_squash；如果客户端是用户root操作，会被压制成nobody用户
# all_squash：不管客户端的使用nfs的用户是谁，都会压制成nobody用户
# insecure：允许从客户端过来的非授权访问
# sync：数据同步写入到内存和硬盘
# async：数据先写入内存，不直接写入到硬盘
# anonuid：指定uid的值，此uid必须存在于/etc/passwd中（anoymous）
# anongid：指定gid的值# 

# 如果出现permission 




```
