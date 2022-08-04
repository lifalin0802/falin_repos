



### 常用命令：
```bash
docker exec -it 45bc58dd2814 ip addr #不进入容器 打印ip地址
for i in $(docker ps -q); do docker exec -it $i ip addr ;done  # 打印出每个镜像的ip


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