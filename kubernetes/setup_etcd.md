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



# ectdctl 安装 https://github.com/etcd-io/etcd/releases
ETCD_VER=v3.5.10

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test 

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /home/lifalin/programs/etcd --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

/home/lifalin/programs/etcd/etcd --version
/home/lifalin/programs/etcd/etcdctl version


# 获取某个 key 信息
ETCDCTL_API=3 etcdctl --endpoints=127.0.0.1:2379 \
 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt \
 --key=/etc/kubernetes/pki/apiserver-etcd-client.key \
 get /registry/apiregistration.k8s.io/apiservices/v1.apps
#获取 ETCD 所有的 key
ETCDCTL_API=3 etcdctl --endpoints=127.0.0.1:2379  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key get / --prefix --keys-only
# 不work!! 参考 http://t.zoukankan.com/lgj8-p-14512516.html
# cat /etc/etcd/etcd.conf 
# # 节点名称
# ETCD_NAME="etcd0"
# # 指定数据文件存放位置
# ETCD_DATA_DIR="/var/lib/etcd/"
# ETCD_LISTEN_CLIENT_URLS="http://127.0.0.1:3379"


# etcd 目录结构
➜  member tree /var/lib/etcd/member
/var/lib/etcd/member
├── snap
│   ├── 0000000000000002-0000000000002711.snap
│   ├── 0000000000000002-0000000000004e22.snap
│   ├── 0000000000000002-0000000000007533.snap
│   ├── 0000000000000002-0000000000009c44.snap
│   ├── 0000000000000002-000000000000c355.snap
│   └── db
└── wal
    ├── 0000000000000000-0000000000000000.wal
    └── 0.tmp

3 directories, 8 files

## 虽然可以解决问题，但是重启之后 只有etcd scheduler apiserver controllermanager,
# coredns,kubeprocy 都没了hai
# panic: recovering backend from snapshot error: database snapshot file path error
# 或者 etcd failed to get all reachable pages
## 解决方法 暴力解决: 
cd /var/lib/etcd
rm -rf *


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

```bash
出现如下信息，切记不是报错信息，只是通过客户端访问的时候需要带上证书访问
➜  ~ etcdctl get --prefix "" --print-value-only
{"level":"warn","ts":"2024-03-24T23:31:31.789482+0800","logger":"etcd-client","caller":"v3@v3.5.10/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0003628c0/127.0.0.1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"error reading server preface: EOF\""}
Error: context deadline exceeded

作者：Landely
链接：https://www.jianshu.com/p/1f9ba144ef34
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

```

### 单独启动一个etcd 
```bash
# start a local etcd server
/home/lifalin/programs/etcd/etcd # 此时不用启动，因为k8s 中已经有个etcd

# write,read to etcd
/home/lifalin/programs/etcd/etcdctl --endpoints=localhost:2379 put foo bar
/home/lifalin/programs/etcd/etcdctl --endpoints=192.168.232.132:2379 get foo

# https://www.python100.com/html/119277.html
etcdctl get --prefix message #etcdctl命令中获取值的参数
etcdctl get --prefix --keys-only message

etcdctl cluster-health
etcdctl --endpoints=http://127.0.0.1:2379,http://etcd01.example.com:2379,http://etcd02.example.com:2379  # --endpoints=[scheme://:]host:port,[scheme://:]host:port,...
etcdctl get message
etcdctl endpoint status
etcdctl --endpoints=127.0.0.1:2379  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key endpoint health

# backup & restore 参考 https://www.zhaowenyu.com/etcd-doc/ops/data-backup-restore.html
$ etcdctl --endpoints=127.0.0.1:2379  snapshot save /home/lifalin/backup/etcd/snapshot.db
$ etcdctl snapshot restore snapshot.db \
  --name m1 \
  --initial-cluster m1=http://127.0.0.1:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls http://127.0.0.1:2380
```