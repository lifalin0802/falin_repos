


### 安装mariadb, redis
```bash
# install mysql
yum install -y mariadb-server
systemctl enable mariadb
systemctl restart mariadb
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('1234');"

# install redis
yum install -y redis
systemctl enable redis
systemctl restart redis
```

### 安装prometheus
```bash

#install prometheus
mkdir -p /opt/prometheus
wget https://s3-gz01.didistatic.com/n9e-pub/prome/prometheus-2.28.0.linux-amd64.tar.gz -O prometheus-2.28.0.linux-amd64.tar.gz
tar xf prometheus-2.28.0.linux-amd64.tar.gz
cp -far prometheus-2.28.0.linux-amd64/*  /opt/prometheus

#安装prometheus
#cat /etc/systemd/system/prometheus.service
[Unit]
Description="prometheus"
Documentation=https://prometheus.io/
[Service]    
Restart=on-failure
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml  --storage.tsdb.retention=30d --log.level=info --storage.tsdb.path=/opt/prometheus/data --web.enable-lifecycle --enable-feature=remote-write-receiver --query.lookback-delta=2m
Restart=on-failure # 启动地址

[Install]
WantedBy=multi-user.target


#或者后台启动
nohup /opt/prometheus/prometheus --config.file=/opt/prometheus/opt/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data/ > /opt/prometheus/prometheus.log 2>&1 &

```

### 安装nightingale
```bash
#去https://github.com/didi/nightingale/releases下载最新版本  下载arm版本的
cd /opt/n9e
tar zvf n9e-v6.0.0-ga.12-linux-amd64.tar.gz

vim ./etc/config.toml  #修改配置文件，prometheus,redis,mysql地址配置
mysql -uroot -p1234 < n9e.sql #导入sql初始化脚本

nohup ./n9e server &> server.log & #启动n9e
nohup ./n9e webapi &> webapi.log &

#默认访问localhost:17000 地址 默认账密 root/root.2020
```

### 配置采集器 catagraf
```bash
wget  https://github.com/flashcatcloud/categraf/releases/download/v0.3.16/categraf-v0.3.16-linux-amd64.tar.gz
vim /opt/n9e/categraf/conf/config.toml

```


### setup netdata
Official webside : https://www.netdata.cloud/
how to start from docker:  https://app.netdata.cloud/spaces/lifalin0802-space/rooms/all-nodes/integrate-anything?post_survey_submit=true#metrics_correlation=false&after=-900&before=0&utc=Asia%2FShanghai&offset=%2B8&timezoneName=Beijing%2C%20Chongqing%2C%20Hong%20Kong%2C%20Urumqi&modal=&modalTab=&modalParams=&selectedIntegrationCategory=deploy.docker-kubernetes&force_play=false&selectedIntegration=&selectedIntegrationTab=
```bash
mkdir -p /data/netdata/{netdatacache,netdatalib}

docker run -d --name=netdata \
--pid=host \
--network=host \
# -v netdataconfig/netdataconfig:/etc/netdata \
-v /data/netdata/netdatalib:/var/lib/netdata \
-v /data/netdata/netdatacache:/var/cache/netdata \
-v /:/host/root:ro,rslave \
-v /etc/passwd:/host/etc/passwd:ro \
-v /etc/group:/host/etc/group:ro \
-v /etc/localtime:/etc/localtime:ro \
-v /proc:/host/proc:ro \
-v /sys:/host/sys:ro \
-v /etc/os-release:/host/etc/os-release:ro \
-v /var/log:/host/var/log:ro \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
--restart unless-stopped \
--cap-add SYS_PTRACE \
--cap-add SYS_ADMIN \
--security-opt apparmor=unconfined \
-e NETDATA_CLAIM_TOKEN=UfinNTG9VlgQMZXDHyE2Lbr4Ib61ZeZZstfVMSJA3nx8zvpwGSazAz6gQqeMfboX-VwUV_4uyuMNnbViqPSfo7th7AQ22W1NUJm9T2YX2Erx74rnOh-hQt3zbP2NsmoUOmCGpMw \
-e NETDATA_CLAIM_URL=https://app.netdata.cloud \
-e NETDATA_CLAIM_ROOMS=a9458faa-0275-473e-8897-d3b7882e82a9 \
netdata/netdata:stable

```
