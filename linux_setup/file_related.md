

### 标准输入输出：
stdin, stdout, stderr:   
用1表示STDOUT，2表示STDERR。  
2>&1，指将标准输出、标准错误指定为同一输出路径  
2>&1 ---标准错误重新定向到标准输出

```bash
cat >>filetest 2>&1 <<END      # 建立filetest文件，当输入遇到END时，退出

find /etc -name passwd 1>find.out 2>find.err
find /etc -name passwd 2>find.err >find.out
find /etc -name passwd 2>find.err 1>find.out

#将所有标准输出及标准错误都输出至文件，可用&表示全部1和2的信息
find /etc -name passwd &>find.all 或 find /etc -name passwd >find.all 2>&1 

#  可分解成
#  find /etc -name passwd & 表示前面的命令放到后台执行。
#  2>&1 |less 表示将标准错误重定向至标准输出，并用less进行分页显示
find /etc -name passwd &2>&1 |less

nohup XXX &
tail -f nohup.out


```

```bash
yum install lrzsz
rz # 上传
sz XXX.tar.gz #下载文件 send到本地

yum install -y ca-certificates
$ wget -c --http-user=clouddeep --http-passwd='Clouddeep@8890' http://139.217.185.199:18180/sdp/rc/redcore_manager.rc_std.a8f4424.tar.gz 
```


```bash
sudo -i
#netstat, ps, nginx -t, 都需要管理员权限

```


```bash
lsof -i :8181
lsof -p 29249
lsof /project/redcore/webRoot/config/config.js  # no
lsof|grep /project/redcore/webRoot/config/config.js  # no
$ lsof|grep /project/openresty/nginx/logs/manager_client_access.log # 有结果，进程写文件的时候，能通过文件找到进程
$ /project/openresty/nginx/sbin/nginx -t #yes 前提 : sudo -i 
$ nginx -t #yes 前提 : sudo -i
$ netstat -nltup|grep 80 #yes 前提 : sudo -i

[root@beta-manager1 29249]# netstat -nltup|grep 80
tcp        0      0 172.40.0.208:2380       0.0.0.0:*               LISTEN      28607/etcd          
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      2055/nginx: worker  
tcp6       0      0 :::8088                 :::*                    LISTEN      28606/syslog        
tcp6       0      0 :::8091                 :::*                    LISTEN      30505/dwaTokenServe 
tcp6       0      0 :::80                   :::*                    LISTEN      2055/nginx: worker  
[root@beta-manager1 29249]# ps -ef|grep 2055
root      2055 29249  0 12:39 ?        00:00:06 nginx: worker process
root     24962 15358  0 18:45 pts/1    00:00:00 grep --color=auto 2055
[root@beta-manager1 29249]# ps -ef|grep nginx
root      2055 29249  0 12:39 ?        00:00:06 nginx: worker process
root      2056 29249  0 12:39 ?        00:00:05 nginx: worker process
root     25010 15358  0 18:46 pts/1    00:00:00 grep --color=auto nginx
root     29249     1  0 Mar07 ?        00:00:00 nginx: master process /project/openresty/nginx/sbin/nginx
[root@beta-manager1 29249]# netstat -nltup|grep 443
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      2055/nginx: worker  
tcp6       0      0 :::443                  :::*                    LISTEN      2055/nginx: worker 
``` 