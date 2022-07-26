


### selinux 相关配置
```bash
selinuxenforce 0    #关闭selinux
cat /etc/selinxux/config

systemctl stop firewalld 

```


### 抓包命令：
```bash
tcpdump  -i deeptun0 host 192.168.2.142 -nvvvt


```