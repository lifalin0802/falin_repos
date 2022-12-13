### docker启动失败的办法

### 现象查看：
```bash
$ journalctl -u docker.service
May 14 20:21:01 centos systemd[1]: docker.service holdoff time over, scheduling restart.
May 14 20:21:01 centos systemd[1]: Stopped Docker Application Container Engine.
May 14 20:21:01 centos systemd[1]: Starting Docker Application Container Engine...
May 14 20:21:01 centos dockerd[1927]: time="2022-05-14T20:21:01.176566009-04:00" level=info msg="Starting up"
May 14 20:21:01 centos dockerd[1927]: failed to start daemon: Unable to get the TempDir under /var/lib/docker: mkdir /var/lib/docker/tmp: no space left on devic
May 14 20:21:01 centos systemd[1]: docker.service: main process exited, code=exited, status=1/FAILURE
May 14 20:21:01 centos systemd[1]: Failed to start Docker Application Container Engine.

```

### 查看docker占用情况：
```bash
[root@centos ~]# df -hl /var/lib/docker
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root   17G   17G   20K 100% /
```

### 解决办法：
删除所有container的日志，一般以-json.log结尾：
```bash
find /var/lib/docker -name *-json.log|xargs rm -rf
systemctl start docker




```
### 查看磁盘大小：
```bash
#查看当前磁盘空间大小
du -sh
#查看文件大小
du -sh test.txt 

#查看目录 文件夹大小 排序
cd /
du -sh *|sort -n

docker run -d -p 9000:9000 \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
--name portainer-test \
docker.io/portainer/portainer
#账密 admin Llfl_123
#连接local之后，可以清 volume

docker system prone #清理出来3G


```

将所有的container 按照占用大小排序：其实没什么用
```bash
[root@centos ~]# d1 -h /var/lib/docker/containers |sort -h

```
du -