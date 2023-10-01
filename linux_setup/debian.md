### 设置网卡重启
```bash
vim /etc/network/interfaces
grep -r google /etc/apt/sources.list.d

systemctl restart networking.service
```

```bash
?  ~ netstat -nltup|grep 134
tcp        0      0 127.0.0.1:13402         0.0.0.0:*               LISTEN      1787/ssh            
tcp6       0      0 ::1:13402               :::*                    LISTEN      1787/ssh 
➜  ~ k port-forward svc/pgadmin -n uqth 8080:80 --address 0.0.0.0 &  #address允许任意主机访问
[1] 1953
netstat -nltup|grep 8080  #以下这个0.0.0.0 就是指 任何主机都可以访问这里的8080端口                                    
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      1953/kubectl 


```

![](./img/image.png)