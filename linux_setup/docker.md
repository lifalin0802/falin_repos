



### 常用命令：
```bash
docker exec -it 45bc58dd2814 ip addr #不进入容器 打印ip地址
for i in $(docker ps -q); do docker exec -it $i ip addr ;done  # 打印出每个镜像的ip
for i in $(docker ps -a|grep demo|awk '{print $1}');do docker rm $i;done  #移除指定的镜像

```

### 查看宿主机中容器的1号进程对应哪个进程号
docker inspect containerName |grep Pid
```bash
[root@centos-master lifalin]# docker inspect 45bc58dd2814|grep Pid
            "Pid": 77564,
            "PidMode": "",
            "PidsLimit": null,
[root@centos-master lifalin]# ps -ef |grep 77564
root      77564  77539  0 21:31 ?        00:00:00 ping 114.114.114.114
root      78738  15502  0 21:39 pts/1    00:00:00 grep --color=auto 77564
```

### docker exec 进入容器内部
grep threads /proc/*/sched
```bash
[root@centos-master lifalin]# docker ps |grep demo
45bc58dd2814   demo:1                 "ping 114.114.114.114"   3 hours ago    Up 9 minutes             great_villani
[root@centos-master lifalin]# docker exec -it 45bc58dd2814 bash
[root@45bc58dd2814 /]# lsns
        NS TYPE  NPROCS PID USER COMMAND
4026531837 user       3   1 root ping 114.114.114.114
4026532520 mnt        3   1 root ping 114.114.114.114
4026532521 uts        3   1 root ping 114.114.114.114
4026532522 ipc        3   1 root ping 114.114.114.114
4026532523 pid        3   1 root ping 114.114.114.114
4026532525 net        3   1 root ping 114.114.114.114

[root@45bc58dd2814 /]# grep threads /proc/*/sched
/proc/1/sched:ping (77564, #threads: 1)
/proc/7/sched:bash (79244, #threads: 1)
/proc/self/sched:grep (79299, #threads: 1)

```


### dockerfile 覆盖CMD 命令：
```bash
#dockerfile2
[root@centos-master lifalin]# cat dockerfile2
FROM centos:latest
CMD ["/bin/bash"] 


docker build -f dockerfile2 -t demo:2 .

#1. 覆盖MCMD, 常ping 
docker run -dit demo:2 ping 8.8.8.8

#2. 直接run 不加任何后缀命令run，也可以保持住docker up的状态
docker run -dit demo:2

#覆盖CMD/ENTRYPOINT 参考 https://blog.csdn.net/luanpeng825485697/article/details/82726725
docker run --entrypoint /bin/bash ...  #，给出容器入口的后续命令参数
docker run --entrypoint="/bin/bash ..." ... #，给出容器的新Shell
docker run -it --entrypoint="" mysql bash  #，重置容器入口
docker run ... <New_Command>      #，可以给出其他命令以覆盖Dockerfile文件中的默认指令

```

### dockerfile中entrypoint和CMD的区别
```bash
FROM centos:latest
CMD ["ls","-a"] 

docker run -dit demo ls -al #可以  瞬时exit
docker run -dit /bin/bash # 能up
docker run -dit demo -al #报错 只能覆盖entrypiont

FROM centos:latest
ENTRYPOINT ["ls","-a"]
docker run -dit demo ls #错的！ 但瞬时exit
docker run -dit demo -al # 可以 


docker run -dit entrydemo /bin/bash  #
[root@centos-master dockerfilescripts]# docker ps -a |grep entry
42f97e70c2f1   entrydemo:1            "ls -a /bin/bash"        20 seconds ago       Exited (0) 19 seconds ago             intelligent_ramanujan

docker network create -d bridge --subnet "192.168.2.0/24" --gateway "192.168.2.1" br0  #

docker network ls #查看自定义的bridge
docker run -it --name b1 --network br0 busybox

docker network create -d bridge --subnet "192.168.5.0/24" --gateway "192.168.5.2" br0  #错误！！执行之后ssh就立刻断连接了！！！查看发现多了 这个网卡 br-1e23d51908ea，从windows宿主机tracert 到这台linux虚拟机都不对了 发现下一条变成了19.168.167.99 ？

#能看到宿主机所有的网卡信息 
$ docker run --net=host -dit --name sharehost busybox
511a20b78943e16d649b3ae311b553e8ff90900c5936dbc7ee47ef9474c5325e
$ docker exec -it 511a20 ip a
。。。。#此处能看到宿主机所有的网卡
[root@centos ~]# docker inspect 511a20 |grep -i pid
            "Pid": 16140,
            "PidMode": "",
            "PidsLimit": null,
[root@centos ~]# lsns |grep 16140   #果然没有net 新的namespace
4026532705 mnt        1 16140 root   sh
4026532706 uts        1 16140 root   sh
4026532707 ipc        1 16140 root   sh
4026532708 pid        1 16140 root   sh






[lifalin@centos ~]$ ifconfig
br-1e23d51908ea: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.5.2  netmask 255.255.255.0  broadcast 192.168.5.255
        ether 02:42:85:e5:63:03  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


#　解决办法：ifconfig xx  down 删除某个网卡
ifconfig br-1e23d51908ea down 
　



```


### namespace :
```bash

unshare --fork --pid --mount-proc /bin/bash  #隔离PID  exit之后 进程就会死掉
unshare --fork --uts /bin/bash #隔离主机名


[root@centos ~]# unshare --fork --pid --mount-proc /bin/bash
[root@centos ~]# lsns
        NS TYPE  NPROCS PID USER COMMAND
4026531837 user       2   1 root /bin/bash
4026531838 uts        2   1 root /bin/bash
4026531839 ipc        2   1 root /bin/bash
4026531956 net        2   1 root /bin/bash
4026532705 mnt        2   1 root /bin/bash
4026532706 pid        2   1 root /bin/bash
[root@centos ~]# ps
   PID TTY          TIME CMD
     1 pts/0    00:00:00 bash
    30 pts/0    00:00:00 ps
[root@centos ~]# ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 01:24 pts/0    00:00:00 /bin/bash
root         31      1  0 01:24 pts/0    00:00:00 ps -ef
[root@centos ~]# ll /proc/1/ns
total 0
lrwxrwxrwx 1 root root 0 Aug 18 01:24 ipc -> ipc:[4026531839]
lrwxrwxrwx 1 root root 0 Aug 18 01:24 mnt -> mnt:[4026532705]
lrwxrwxrwx 1 root root 0 Aug 18 01:24 net -> net:[4026531956]
lrwxrwxrwx 1 root root 0 Aug 18 01:24 pid -> pid:[4026532706]  
lrwxrwxrwx 1 root root 0 Aug 18 01:24 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Aug 18 01:24 uts -> uts:[4026531838]


[root@centos ~]# ps -ef
...
root      13572   4421  0 01:24 pts/0    00:00:00 unshare --fork --pid --mount-proc /bin/bash
root      13573  13572  0 01:24 pts/0    00:00:00 /bin/bash
root      13587      1  0 01:24 ?        00:00:00 /usr/sbin/abrt-dbus -t133
root      13650    777  0 01:24 ?        00:00:00 sleep 60
root      13731   1065  0 01:25 ?        00:00:00 sshd: root@pts/1
root      13737  13731  0 01:25 pts/1    00:00:00 -bash
root      13796  13737  0 01:25 pts/1    00:00:00 ps -ef
[root@centos ~]# ll /proc/13572/ns
total 0
lrwxrwxrwx 1 root root 0 Aug 18 01:26 ipc -> ipc:[4026531839]
lrwxrwxrwx 1 root root 0 Aug 18 01:26 mnt -> mnt:[4026532705]
lrwxrwxrwx 1 root root 0 Aug 18 01:26 net -> net:[4026531956]
lrwxrwxrwx 1 root root 0 Aug 18 01:26 pid -> pid:[4026531836]
lrwxrwxrwx 1 root root 0 Aug 18 01:26 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Aug 18 01:26 uts -> uts:[4026531838]
[root@centos ~]# lsns |grep 13572
4026532705 mnt        2 13572 root   unshare --fork --pid --mount-proc /bin/bash

```