### ectd 安装：
```bash

wget https://github.com/coreos/etcd/releases/download/v3.3.7/etcd-v3.3.7-linux-amd64.tar.gz

tar xf etcd-v3.3.7-linux-amd64.tar.gz 
cd etcd-v3.3.7-linux-amd64
etcd --version

vi /etc/profile
export ETCDCTL_API=3
source /etc/profile
etcdctl -version #或 etcdctl -v,  etcdctl version
etcdctl --help 



# 不work!! 参考 http://t.zoukankan.com/lgj8-p-14512516.html
# cat /etc/etcd/etcd.conf 
# # 节点名称
# ETCD_NAME="etcd0"
# # 指定数据文件存放位置
# ETCD_DATA_DIR="/var/lib/etcd/"
# ETCD_LISTEN_CLIENT_URLS="http://127.0.0.1:3379"



vim etcd_conf.yml
#设置成这个才能够支持其他客户端监听watch本机的etcd服务
listen-client-urls: http://0.0.0.0:2379
advertise-client-urls: http://0.0.0.0:2379
#设置压缩模式为周期性，历史版本数据保留3小时就会删除
auto-compaction-mode: periodic
auto-compaction-retention: 3h
#设置数据库大小为8G，单位是字节
quota-backend-bytes: 8388608


cat /etc/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
 
[Service]
User=root
Type=notify
WorkingDirectory=/var/lib/etcd/
#EnvironmentFile=-/etc/etcd/etcd_conf.yml
ExecStart=/usr/local/bin/etcd --config-file /etc/etcd/etcd_conf.yml \
--cert-file=/opt/etcd/ssl/server.pem \
--key-file=/opt/etcd/ssl/server-key.pem \
--peer-cert-file=/opt/etcd/ssl/server.pem \
--peer-key-file=/opt/etcd/ssl/server-key.pem \
--trusted-ca-file=/opt/etcd/ssl/ca.pem \
--peer-trusted-ca-file=/opt/etcd/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target

#或者etcd 启动配置




systemctl daemon-reload
systemctl restart etcd 
netstat -nltup |grep 3389


# 生成证书：参考 https://blog.csdn.net/eyeofeagle/article/details/101676526
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www ca-csr.json | cfssljson -bare server

#etcdctl 使用：https://www.jianshu.com/p/1f9ba144ef34
etcdctl --cacert=/opt/etcd/ssl/ca.pem --cert=/opt/etcd/ssl/server.pem --key=/opt/etcd/ssl/server-key.pem --endpoints="http://192.168.5.100:3379" member list #work
etcdctl --endpoints="192.168.5.100:3379" member list #work

```