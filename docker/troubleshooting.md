### docker启动失败的办法

### 现象查看：
```bash

```



### 查看磁盘大小：
```bash
#查看当前磁盘空间大小
du -sh
#查看文件大小
du -sh test.txt 


cd /
du -sh *|sort -n #查看目录 文件夹大小 排序

docker run -d -p 9000:9000 \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
--name portainer-test \
docker.io/portainer/portainer
#账密 admin Llfl_123
#连接local之后，可以清 volume

docker system prone #清理出来3G


```

### set docker proxy (not work !!)
```bash
 cat /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://10.10.100.240:20172/"
Environment="HTTPS_PROXY=http://10.10.100.240:20172/"
Environment="NO_PROXY=localhost,127.0.0.1"

# run the following command to reset docker 
sudo systemctl daemon-reload
sudo systemctl restart docker
```

```bash
# 发现docker pull 下载错误 docker pull nicolaka/netshoot or  docker run nicolaka/netshoot
$ journalctl -u docker.service | grep "error"

Sep 30 13:29:33 node235 dockerd[509830]: time="2024-09-30T13:29:33.456980853+08:00" level=error msg="Handler for POST /v1.47/images/create returned error: Get \"https://registry-1.docker.io/v2/\": net/http: TLS handshake timeout" spanID=7bff44a0f2840fdf traceID=d4fb2c25eeaf2186c62db84fb5bea12e


# 方法 1: (work !!)
cat >> /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
    "https://register.liberx.info",
    "https://dockerpull.com",
    "https://docker.anyhub.us.kg",
    "https://dockerhub.jobcher.com",
    "https://dockerhub.icu",
    "https://docker.awsl9527.cn"
    ],
  "max-concurrent-downloads": 1,
  "dns": ["8.8.8.8", "8.8.4.4"],
  "debug": true,
  "experimental": false
}
EOF

# 方法 2:  (not work !!)
vi /etc/sysconfig/docker
OPTIONS='--selinux-enabled --log-driver=journald --registry-mirror=https://docker.mirrors.ustc.edu.cn'
```



### 将所有的container 按照占用大小排序：其实没什么用
```bash
[root@centos ~]# d1 -h /var/lib/docker/containers |sort -h

```
du -