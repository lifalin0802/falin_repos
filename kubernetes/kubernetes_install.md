### 安装bind

```bash

#配置镜像源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.bak

curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo 

yum clean all 
yum makecache fast 
yum repolist #查看镜像源
yum list installed

yum clean all
yum makecache
yum -y update # work!!

#配置ali镜像源
cd /etc/yum.repos.d/
wget http://mirrors.aliyun.com/repo/Centos-7.repo
mv CentOs-Base.repo CentOs-Base.repo.bak
mv Centos-7.repo CentOs-Base.repo

#停止firewalld
[root@master01 containerd]# systemctl is-active firewalld
inactive
[root@master01 containerd]# systemctl is-enabled firewalld
disabled


#安装常用工具
yum install -y yum-utils device-mapper-persistent-data lvm2 
yum install -y bridge-utils.x86_64

#启用ipv6， ipv4转发
cat >> /etc/sysctl.conf << eof
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1 
vm.swappiness = 0
eof

sysctl -p #使之生效

modprobe overlay  #系统加载两个模块 
modprobe br_netfilter

echo "1"> /proc/sys/net/ipv4/ip_forward 
lsmod #列出内核模块

yum list containerd #找不到！！！！
yum list containerd.io # 找到了 ！！无语，
yum list containerd* # 可以找到
```
![](2022-08-13-19-27-03.png)

### 更改docker-ce的cgroup driver 为systemd
默认是cgroupfs  docker 自带的
```bash

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl daemon-reload 
systemctl restart docker 
docker info |grep Cgroup


systemctl --type=service --state=running #列出清单
systemctl list-unit-files|grep -i container #找不到服务的名字怎么办 模糊搜索
grep -i xx   # 不区分大小写  -i, --ignore-case ignore case distinctions


```


### 安装kubectl, kubeadm, kubelet
```bash
#编辑yum repo 配置文件
$ cat /etc/yum.repos.d/kubernetes.repo  
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg

#下载kubelet,kubeadm,kubectl
yum install -y --nogpgcheck kubelet-1.23.5 kubeadm-1.23.5 kubectl-1.23.5

#启动kubelet 守护进程
systemctl enable kubelet 
systemctl start kubelet
```

### kubernetes使用：
```bash
kubectl explain pods.spec  
kubectl get nodes --show-labels
kubectl  label node  node02 node-role.kubernetes.io/worker=
kubectl  label node  node02 node-role.kubernetes.io/node- #消除标签node

```

### kubernetes 二进制安装：
#### 安装证书：
```bash
mkdir -p /opt/TLS/{download,etcd,k8s}

cd /opt/TLS/download
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl_1.6.4_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssljson_1.6.4_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl-certinfo_1.6.4_linux_amd64
chmod +x cfssl*
cp cfssl_1.6.4_linux_amd64 /usr/local/bin/cfssl
cp cfssljson_1.6.4_linux_amd64 /usr/local/bin/cfssljson
cp cfssl-certinfo_1.6.4_linux_amd64 /usr/local/bin/cfssl-certinfo

# sed -i 's/centos-master/localhost.localdomain/g' /etc/kubernetes/kubelet.conf

```
### 写好三个文件，ca-csr.json, ca-config.json, server-csr.json 
cfssl gencert -profile 别写错，要与ca-config.json 中的profile保持一致 ~！
可以参考 https://zhuanlan.zhihu.com/p/596891203 https://blog.heylinux.com/en/2021/11/how-to-generate-self-signed-ssl-certificates/
出错详见 https://blog.csdn.net/qq_44792624/article/details/117332764
```bash
mkdir -p /opt/certs

cat > ca-csr.json << eof
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [  
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
eof

cfssl gencert -initca ca-csr.json | cfssljson -bare ca - 

➜  certs ls -lt                                       
total 20
-rw-r--r--. 1 root root 1070 Oct 14 03:58 ca.csr      #证书请求
-rw-------. 1 root root 1679 Oct 14 03:58 ca-key.pem  #根证书的密钥  ca-key.pem ->ca.key
-rw-r--r--. 1 root root 1363 Oct 14 03:58 ca.pem      #根证书       ca.pem -> ca.crt
-rw-r--r--. 1 root root  267 Oct 13 03:36 ca-csr.json  #证书请求文件

cat > server-csr.json <<EOF
{
    "CN":"server", 
    "hosts":[
        "127.0.0.1",
        "10.0.0.1",
        "kubernetes",
        "kubernetes.default",
        "kubernetes.default.svc",
        "kubernetes.default.svc.cluster",
        "kubernetes.default.svc.cluste.local",
        "192.168.232.132",
        "192.168.232.140",
        "192.168.232.100"
    ],
    "key":{
        "algo":"rsa",
        "size":2048
    },
    "names":[
        {
            "C":"CN",
            "L":"Beijing",
            "ST":"Beijing",
            "O":"k8s",
            "OU":"System"
        }
    ]
}
EOF

cat >> ca-config.json  << EOF
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF

# 2. 生成私钥和证书
# 使用方式 cfssl selfsign HOSTNAME CSRJSON
# cfssl selfsign www.amjun.com server-csr.json | cfssljson -bare  server

# # 3. 查看证书
# cfssl certinfo -cert server.pem

# 3. 基于之前生成的ca证书生成证书1
cfssl gencert \
-ca=ca.pem \
-ca-key=ca-key.pem \
-config=ca-config.json \
-profile=kubernetes \
server-csr.json | cfssljson -bare server -
 
# 3. 查看证书
cfssl certinfo -cert server.pem
```


#### 安装kubectl:
```bash

cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum install kubeadm kubelet kubectl  # kubectl 计算节点可以不装？ 计算节点= node节点
systemctl start kubelet

mkdir -p /etc/kubernetes/pki  #创建证书文件路径
cd /etc/kubernetes/pki 
#在centos-master节点上 scp拷贝过来ca.pem, ca-key.pem 
# yum install sshpass
# sshpass -p "lfl" scp centos:/opt/certs/ca.pem ca.crt
# sshpass -p "lfl" scp centos:/opt/certs/ca-key.pem ca.key

# kubeadm config print init-defaults  > kubeadm-config.yaml #生成kubeadm 配置文件，这里是master 节点用的
# kubeadm config print join-defaults > kubeadm-config.yaml # 生成join的kubeadm的配置文件，node节点上运行

yum install -y containerd
containerd config default > /etc/containerd/config.toml
mv /etc/containerd/config.toml /etc/containerd/config.toml.bak

cat >> /etc/containerd/config.toml <<EOF
[plugins."io.containerd.grpc.v1.cri"]
systemd_cgroup = true
EOF

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF


#containerd 安装之前 要设置好两个模块
cat << EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

#调整containerd 配置文件
containerd config default|tee /etc/containerd/config.toml #将现在默认的配置写入config.toml文件中


vim  /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true  # 96左右，必须要改   

[plugins."io.containerd.grpc.v1.cri"]
  ...
  # sandbox_image = "k8s.gcr.io/pause:3.6"
  sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.7"  #更改拉取镜像源


systemctl restart containerd
ls -l /run/containerd/containerd.sock #containerd 所使用的套接字文件 和 /var/run/containerd/containerd.sock是一个文件



echo "XX" |base64 -d
[root@centos ~]# echo -n 'admin'|base64
YWRtaW4=
echo 'MWYyZDFlMmU2N2Rm' | base64 --decode

#查看kubeadm config所需的镜像 ：
kubeadm config images list
k8s.gcr.io/kube-apiserver:v1.24.3
k8s.gcr.io/kube-controller-manager:v1.24.3
k8s.gcr.io/kube-scheduler:v1.24.3
k8s.gcr.io/kube-proxy:v1.24.3
k8s.gcr.io/pause:3.7
k8s.gcr.io/etcd:3.5.3-0
k8s.gcr.io/coredns/coredns:v1.8.6

kubeadm config images pull --config kubeadm.yaml

#从国内镜像源拉取镜像：
docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.24.3
docker pull registry.aliyuncs.com/google_containers/kube-controller-manager:v1.24.3
docker pull registry.aliyuncs.com/google_containers/kube-scheduler:v1.24.3
docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.24.3
docker pull registry.aliyuncs.com/google_containers/pause:3.7
docker pull registry.aliyuncs.com/google_containers/etcd:3.5.3-0
docker pull registry.aliyuncs.com/google_containers/coredns:v1.8.6


#对images重命名 
docker tag  registry.aliyuncs.com/google_containers/kube-apiserver:v1.24.3  k8s.gcr.io/kube-apiserver:v1.24.3
docker tag  registry.aliyuncs.com/google_containers/kube-controller-manager:v1.24.3  k8s.gcr.io/kube-controller-manager:v1.24.3
docker tag  registry.aliyuncs.com/google_containers/kube-scheduler:v1.24.3  k8s.gcr.io/kube-scheduler:v1.24.3
docker tag  registry.aliyuncs.com/google_containers/kube-proxy:v1.24.3  k8s.gcr.io/kube-proxy:v1.24.3
docker tag  registry.aliyuncs.com/google_containers/pause:3.7  k8s.gcr.io/pause:3.7
docker tag  registry.aliyuncs.com/google_containers/pause:3.6  k8s.gcr.io/pause:3.6
docker tag  registry.aliyuncs.com/google_containers/etcd:3.5.3-0  k8s.gcr.io/etcd:3.5.3-0
docker tag  registry.aliyuncs.com/google_containers/coredns:v1.8.6 k8s.gcr.io/coredns/coredns:v1.8.6


kubeadm init --config=kubeadm-config.yaml --upload-certs  # 这里前提：需要cpu 2， mem 1700m, master,node docker-ce 都启来 containerd配置文件需要改

kubeadm reset #如果init 失败，需要reset 一下再 执行上述init

#启动文件
#!/bin/bash
yum install -y sshpass
ssh-copy-id lifalin@192.168.232.132 
# 上传文件  scp -r /本地文件 用户名@1ip地址:/远程文件目录/
# 拉取文件 scp -r 用户名@1ip地址:/远程文件目录/远程服务器文件 /本地文件目录/
scp ca.pem lifalin@archlinux:/opt/certs # scp f1 f2 将f1 -> f2 拷贝方向
scp ca-key.pem lifalin@archlinux:/opt/certs

mkdir -p /etc/kubernetes/pki
cd /etc/kubernetes/pki
sshpass -p "lfl" scp centos:/opt/certs/ca.pem ca.crt
sshpass -p "lfl" scp centos:/opt/certs/ca-key.pem ca.key


kubeadm init \
--apiserver-advertise-address=192.168.232.132 \
--image-repository registry.aliyuncs.com/google_containers \
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \
--upload-certs --v=5 \
--ignore-preflight-errors=all


Please, check the contents of the $HOME/.kube/config file.
[root@master01 lifalin]# vim init.sh 
[root@master01 lifalin]# ./init.sh 
[init] Using Kubernetes version: v1.24.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local master01] and IPs [10.96.0.1 192.168.5.140]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [localhost master01] and IPs [192.168.5.140 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [localhost master01] and IPs [192.168.5.140 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 10.504803 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master01 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node master01 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: da2els.6m9ufp9c37vaagy7
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
  [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
  [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config #cp这个文件 覆盖 最关键~！！！
  sudo chown $(id -u):$(id -g) $HOME/.kube/config   #每次reset init 成功之后都要运行的

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.5.140:6443 --token da2els.6m9ufp9c37vaagy7 \
	--discovery-token-ca-cert-hash sha256:ff314aa37fa425d9339cff30d3ce72835d4afae65952148a9a04c5bd28c6b878 
./init.sh: line 15: --service-cidr=10.96.0.0/16: No such file or directory
./init.sh: line 16: --upload-certs: command not found

``` 
### 每次kube reset 重新拉起之后运行 config 改变的部分
`cp -i /etc/kubernetes/admin.conf $HOME/.kube/config` 到底改变了什么
![](./img/2023-11-12-00-13-19.png)
```bash

#master 节点上不能用kubectl edit 怎么办
export EDITOR=vim

```

### api-server 正常状态
```bash
➜  lifalin ps -ef |grep api                 
root        3568    3427  3 00:15 ?        00:03:15 kube-apiserver --advertise-address=192.168.232.132 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
➜  lifalin ps -ef |grep etcd      
root        3388    3335  1 00:15 ?        00:01:10 etcd --advertise-client-urls=https://192.168.232.132:2379 --cert-file=/etc/kubernetes/pki/etcd/server.crt --client-cert-auth=true --data-dir=/var/lib/etcd --experimental-initial-corrupt-check=true --experimental-watch-progress-notify-interval=5s --initial-advertise-peer-urls=https://192.168.232.132:2380 --initial-cluster=archlinux=https://192.168.232.132:2380 --key-file=/etc/kubernetes/pki/etcd/server.key --listen-client-urls=https://127.0.0.1:2379,https://192.168.232.132:2379 --listen-metrics-urls=http://127.0.0.1:2381 --listen-peer-urls=https://192.168.232.132:2380 --name=archlinux --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt --peer-client-cert-auth=true --peer-key-file=/etc/kubernetes/pki/etcd/peer.key --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt --snapshot-count=10000 --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
root        3568    3427  3 00:15 ?        00:03:23 kube-apiserver --advertise-address=192.168.232.132 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
➜  lifalin ps -ef |grep controller
root       34446    3414  0 01:25 ?        00:00:12 kube-controller-manager --allocate-node-cidrs=true --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf --bind-address=127.0.0.1 --client-ca-file=/etc/kubernetes/pki/ca.crt --cluster-cidr=10.244.0.0/16 --cluster-name=kubernetes --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt --cluster-signing-key-file=/etc/kubernetes/pki/ca.key --controllers=*,bootstrapsigner,tokencleaner --kubeconfig=/etc/kubernetes/controller-manager.conf --leader-elect=true --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --root-ca-file=/etc/kubernetes/pki/ca.crt --service-account-private-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --use-service-account-credentials=true
➜  lifalin ps -ef |grep scheduler 
root       26287    3451  0 00:56 ?        00:00:08 kube-scheduler --authentication-kubeconfig=/etc/kubernetes/scheduler.conf --authorization-kubeconfig=/etc/kubernetes/scheduler.conf --bind-address=127.0.0.1 --kubeconfig=/etc/kubernetes/scheduler.conf --leader-elect=true
➜  lifalin ps -ef |grep kubelet  
root        3752       1  1 00:15 ?        00:02:08 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.9

```


### 如何join 节点
```bash

# 关闭防火墙
systemctl stop firewalld 
systemctl disable firewalld
 
# 关闭selinux
sed -i 's/enforcing/disabled/' /etc/selinux/config  # 永久
setenforce 0  # 临时
 
# 关闭swap
swapoff -a  # 临时
sed -ri 's/.*swap.*/#&/' /etc/fstab    # 永久 

yum install -y kubelet kubectl kubeadm 
yum install -y containerd.io.x86_64 #和master节点安装的containerd version 版本不一样也没关系? 目前看上去是这样的

hostnamectl set-hostname node1
cat /etc/hostname
reboot #重启使hostname生效


modprobe br_netfilter
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf 
br_netfilte
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

token create --print-join-command #重新获取master的token
[root@master01 tigera-operator]# kubeadm token create --print-join-command
kubeadm join 192.168.5.140:6443 --token knsqgq.cr889wp2v2vpcj2x --discovery-token-ca-cert-hash sha256:3989f9b70736ad3ea00b0a0ac1bbf5548691c9f3547cf3becf410219907ea3ce 



#此时我的kubectl 还是不能用必须运行  .kube/config 和export 那一段才行 不然报错 


#如果想join master 节点：
kubeadm init phase upload-certs --upload-certs  --v=999 #得到certificate key
[upload-certs] Using certificate key:
12c2a84814f1b1fae616ef86e8e570b20f06035591ccd54dae405c820ac60209
#如果想join 一个 master 节点：
kubeadm join 192.168.5.140:6443 --token da2els.6m9ufp9c37vaagy7 \
	--discovery-token-ca-cert-hash sha256:ff314aa37fa425d9339cff30d3ce72835d4afae65952148a9a04c5bd28c6b878 
  --control-plane --certificate-key 12c2a84814f1b1fae616ef86e8e570b20f06035591ccd54dae405c820ac60209 --v=999

#超过24小时 没有加入节点 应该重新生成token
#第一个master节点上运行 
[root@master01 ~]# kubeadm token create z`--print-join-command
kubeadm join 192.168.5.140:6443 --token vebwg0.haex8tp6r3n60fu3 --discovery-token-ca-cert-hash sha256:ff314aa37fa425d9339cff30d3ce72835d4afae65952148a9a04c5bd28c6b878 

kubectl label node node01 node-role.kubernetes.io/worker=worker #kubectl get nodes 时候有个role为none? 的解决办法
kubectl label ns kube-public tingyun-injection- #删除label

kubectl taint node node01 node-role.kubernetes.io/master-
kubectl taint node node01 key1-
kubectl taint nodes master1 node-role.kubernetes.io/master=:NoSchedule

kubectl describe nodes prod-k8s-apm-node-data3  |grep Taints
kubectl taint node prod-k8s-apm-node-data3  
kubectl taint node prod-k8s-apm-node-data1 app=bigdata:NoExecute


#增加污点
kubectl taint node node01 键名=键值:NoSchedule

#只有key 没有value
➜  ~ k describe node archlinux |grep -i  taint
Taints:             node-role.kubernetes.io/control-plane:NoSchedule


#删除
kubectl taint node node01 键名=键值:NoSchedule-
kubectl taint node node01 键名-





kubectl get po coredns-74586cf9b6-4lqmw -n kube-system -o yaml #work
kubectl get configmap -n kube-system coredns -o yaml 

kubectl get cs #component status
[root@master01 yaml]# kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
scheduler            Healthy   ok                              
etcd-0               Healthy   {"health":"true","reason":""}   
controller-manager   Healthy   ok  



#kubeadm join 完之后可以查看各个基础pod运行情况
#coredns 没起来 因为还没有装cni网络插件
[root@master01 ~]# kubectl get pod -n kube-system -o wide
NAME                               READY   STATUS    RESTARTS       AGE   IP              NODE       NOMINATED NODE   READINESS GATES
coredns-74586cf9b6-8nvgj           0/1     Pending   0              26h   <none>          <none>     <none>           <none>
coredns-74586cf9b6-h9kzg           0/1     Pending   0              26h   <none>          <none>     <none>           <none>
etcd-master01                      1/1     Running   1              26h   192.168.5.140   master01   <none>           <none>
kube-apiserver-master01            1/1     Running   0              26h   192.168.5.140   master01   <none>           <none>
kube-controller-manager-master01   1/1     Running   1 (5h9m ago)   26h   192.168.5.140   master01   <none>           <none>
kube-proxy-56lw2                   1/1     Running   0              36m   192.168.5.142   node02     <none>           <none>
kube-proxy-6bd4t                   1/1     Running   0              26h   192.168.5.140   master01   <none>           <none>
kube-scheduler-master01            1/1     Running   1 (5h9m ago)   26h   192.168.5.140   master01   <none>           <none>

#node 节点status notready 也是因为还没有装cni网络插件
[root@master01 ~]# kubectl get nodes -o wide
NAME       STATUS     ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION           CONTAINER-RUNTIME
master01   NotReady   control-plane   26h   v1.24.3   192.168.5.140   <none>        CentOS Linux 7 (Core)   3.10.0-1062.el7.x86_64   containerd://1.6.7
node02     NotReady   worker          43m   v1.24.3   192.168.5.142   <none>        CentOS Linux 7 (Core)   3.10.0-1062.el7.x86_64   containerd://1.6.7


systemctl status kubelet --full
systemctl is-enabled firewalld # 查看 firewalld状态

```

### 安装calico operator
```bash
#安装calico 参考 https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml  #这之后有operator运行，running 成功速度很快

# install crd
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml



wget -c -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.3/manifests/custom-resources.yaml



vim custom-resources.yaml 
      cidr: 10.244.0.0/16  #更改cidr 值为pod网段

k create -f custom-resources.yam
watch kubectl get pods -n calico-system # 监控看calico各个组件成功状态，短了几分钟就好，长了需要二十多分钟各个组件才running和 ready 
```

#### custom-resources.yaml 如下
```yaml
# This section includes base Calico installation configuration.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 10.244.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
```


```bash
cat /etc/kubernetes/pki/etcd/ca.crt | base64 -w 0

#还有一种安装方式，非官方  refered to :https://www.jianshu.com/p/5d760511b640
#r如果etcd是http访问的，那就不用配置证书了，直接指定etcd地址就可以了

#设置  CALICO_IPV4POOL_CIDR  要和kube-controller-manager 一致 --cluster-cidr=10.244.0.0/16，设置成pod网段
 - name: CALICO_IPV4POOL_CIDR
   value: "10.244.0.0/16" 
#修改or添加 网卡参数 IP_AUTODETECTION_METHOD
  - name: IP_AUTODETECTION_METHOD
    value: "interface=ens33"



#最后apply,
kubectl apply -f calico.yaml

#此时 coredns 还没有好？ 


#更改kube-proxy为ipvs模式，安装ipvsadm 


#安装ingress ? 





#安装istio ?
#安装kubesphere


#nginx keepalived高可用？


#查看.sock 文件被哪个程序占用
[root@master01 cgroup]# lsof /run/containerd/containerd.sock
COMMAND     PID USER   FD   TYPE             DEVICE SIZE/OFF   NODE NAME
container 19495 root    7u  unix 0xffff8d20988fec00      0t0 182759 /run/containerd/containerd.sock
container 19495 root    8u  unix 0xffff8d20988f9000      0t0 182761 /run/containerd/containerd.sock
container 19495 root   11u  unix 0xffff8d20d24aa800      0t0 182781 /run/containerd/containerd.sock
container 19495 root   37u  unix 0xffff8d20bc205000      0t0 174175 /run/containerd/containerd.sock
container 19495 root   61u  unix 0xffff8d20ef97ec00      0t0 174320 /run/containerd/containerd.sock
container 19495 root   62u  unix 0xffff8d20ef978800      0t0 173652 /run/containerd/containerd.sock
[root@master01 cgroup]# ps -ef |grep 19495
root      19495      1  0 Aug13 ?        00:01:38 /usr/bin/containerd
root      26047  17362  0 02:13 pts/0    00:00:00 grep --color=auto 19495


[root@master01 cgroup]# systemctl status containerd
● containerd.service - containerd container runtime
   Loaded: loaded (/usr/lib/systemd/system/containerd.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2022-08-13 21:07:57 CST; 5h 7min ago
     Docs: https://containerd.io
 Main PID: 19495 (containerd)
    Tasks: 77
   Memory: 154.9M
   CGroup: /system.slice/containerd.service
           ├─19495 /usr/bin/containerd
           ├─20260 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 3044b4182756504947af88aaf1dcdba8793d9471f2602d0c5d54b5100d12aa3f -address /run/containerd/containerd.sock
           ├─20263 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 3be97075b6450135755776d31d853c96bd346462b05c7b8288d7d4c4c6b78bd6 -address /run/containerd/containerd.sock
           ├─20300 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id a411e537f73625a9acf79ce960a4df73d52e34db427b99beca57be5563fa411a -address /run/containerd/containerd.sock
           ├─20315 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 4e68ccb24f5af9332f959b047c9b33750b32d38984789be3c9f76a557aa0f545 -address /run/containerd/containerd.sock
           └─20643 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 86eabc37c6362e1680ef49c6875b249da472e553cf6aa103d8f9ce9937671d85 -address /run/containerd/containerd.sock




```

### 等同于docker 查看命令，此处用cri:
```bash

VERSION="v1.20.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
tar zxvf crictl-v1.20.0-linux-amd64.tar.gz -C /usr/local/bin
$ crictl version
Version:  0.1.0
RuntimeName:  containerd
RuntimeVersion:  1.6.8
RuntimeApiVersion:  v1alpha2



crictl --runtime-endpoint unix:///run/containerd/containerd.sock  pods
crictl --runtime-endpoint unix:///run/containerd/containerd.sock  images
crictl --runtime-endpoint unix:///run/containerd/containerd.sock  ps 


vi /etc/crictl.yaml #编辑完即刻生效 啥都不用重启 

```

### calico 安装：
参考 https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises
manifests
```bash
# 当节点小于50
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.3/manifests/calico.yaml -O 

# 当节点大于50


```


### calicoctl 安装:
参考 https://docs.tigera.io/calico/latest/operations/calicoctl/install  
所有节点都需要安装，包括master 和node 节点
```bash 
curl -L https://github.com/projectcalico/calico/releases/download/v3.26.3/calicoctl-linux-amd64 -o calicoctl
chmod +x ./calicoctl
mv calicoctl /usr/local/bin/calicoctl  
caclicoctl version 
```

### Install calicoctl as a kubectl plugin on a single host
```bash
curl -L https://github.com/projectcalico/calico/releases/download/v3.26.3/calicoctl-linux-amd64 -o kubectl-calico
chmod +x kubectl-calico
mv kubectl-calico /usr/local/bin/kubectl-calico
kubectl-calico -h
```


```bash
DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl node status #命令测试S

#设置环境变量
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config
calicoctl get workloadendpoints

calicoctl node status #查看bgp情况
calicoctl get nodes
calicoctl ipam show --show-blocks
calicoctl get ippool -o wide #


cd /opt/cni/bin  #网络cni 配置

#coredns起不来？ 用以下方法
rm -rf /etc/cni/net.d/*
rm -rf /var/lib/cni/calico
systemctl  restart kubelet




netstat -anp|grep :179 #查找19端口号 tcp长连接
[root@master01 ~]# netstat -anp|grep :179
tcp        0      0 0.0.0.0:179             0.0.0.0:*               LISTEN      3703/bird           
tcp        0      0 192.168.5.140:179       192.168.5.142:59204     ESTABLISHED 3703/bird   

```



解决办法：  
https://github.com/kubernetes/kubeadm/issues/1153  
https://github.com/cri-o/cri-o/issues/2357  
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/  
https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o  
https://github.com/cri-o/cri-o/blob/main/install.md#install-packaged-versions-of-cri-o  
https://blog.csdn.net/u012562943/article/details/124998093 #kubernetes 1.24+ 安装示例博客

### could not find the requested resource :

```bash
[root@centos ~]# kubectl top node
Error from server (NotFound): the server could not find the requested resource (get services http:heapster:)
#解决办法：https://www.jianshu.com/p/538874f610d3
git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git
kubectl create -f kubernetes-metrics-server/


#怎盐查找apiserver的配置？比如etcd配置在哪里
ps -ef|grep apiserver
[root@master01 calico]# ps -ef|grep 84635|grep apiserver.
root      84635  84445 10 18:30 ?        00:15:52 kube-apiserver --advertise-address=192.168.5.140 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --tls-cert-file=/etc/kubernetes/pkiapiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
[root@master01 calico]# ps -ef|grep controll
root      84647  84447  3 18:30 ?        00:06:07 kube-controller-manager --allocate-node-cidrs=true --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf --bind-address=127.0.0.1 --client-ca-file=/etc/kubernetes/pki/ca.crt --cluster-cidr=10.244.0.0/16 --cluster-name=kubernetes --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt --cluster-signing-key-file=/etc/kubernetes/pki/ca.key --controllers=*,bootstrapsigner,tokencleaner --kubeconfig=/etc/kubernetes/controller-manager.conf --leader-elect=true --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --root-ca-file=/etc/kubernetes/pki/ca.crt --service-account-private-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --use-service-account-credentials=true
root      89474  37478  0 21:29 pts/1    00:00:00 grep --color=auto controll


#或者在文件中 
cat /opt/kubernetes/cfg/kube-apiserver.conf

cat /opt/kubernetes/cfg/kube-controller-manager.conf
```

### kubectl 操作：
```bash
#强制删除pod
kubectl delete pod PODNAME --force --grace-period=0 
```



```bash
yum list |grep containd.io
yum install -y containerd.io

#基本命令
ctr version
ctr container ls #查看容器
ctr images ls #查看镜像
ctr namespace ls #查看命名空间


#这里容器 每次重启 运行都会生成相应的数字
#告警 只能知道磁盘满了 但 不知道哪个服务把磁盘沾满了
du -sh|grep G
mount |grep /var/lib/container


ctr -n k8s.io i ls #containerd image 分namespace 
ctr -n k8s.io c ls
/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots


#https://blog.csdn.net/qq_32907195/article/details/120529037
ctr image list, ctr i list , ctr i ls
ctr -n k8s.io i tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
ctr -n k8s.io i tag --force registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
ctr -n k8s.io i rm k8s.gcr.io/pause:3.2
ctr -n k8s.io i pull -k k8s.gcr.io/pause:3.2

journalctl -xefu kubelet -n 10 #查看kubelet 日志



[root@node02 ~]# crictl images
IMAGE                                                TAG                 IMAGE ID            SIZE
docker.io/calico/cni                                 v3.23.3             ecf96bae0aa79       108MB
docker.io/calico/cni                                 v3.24.0             45f84749206fc       87.4MB

[root@node02 ~]# ctr ns ls
NAME   LABELS 
k8s.io        
moby 
  
#https://blog.csdn.net/UsakiKokoro/article/details/120333964
命令	docker	ctr（containerd）	crictl（kubernetes）
查看运行的容器	docker ps	      ctr -n k8s.io task ls/ctr container ls	crictl ps
查看镜像	docker images   	   ctr -n k8s.io i ls	            crictl images
查看容器日志	docker logs      cd /var/log/pods/              crictl logs 
查看容器数据信息	docker inspect	ctr container info	crictl inspect
查看容器资源	docker stats	无	crictl stats
启动/关闭已有的容器	docker start/stop	ctr task start/kill	crictl start/stop
运行一个新的容器	docker run	ctr run	无（最小单元为pod）
修改镜像标签	docker tag	ctr image tag	无
创建一个新的容器	docker create	ctr container create	crictl create
导入镜像	docker load	ctr image import	无
导出镜像	docker save	ctr image export	无
删除容器	docker rm	ctr container rm	crictl rm
删除镜像	docker rmi	ctr image rm	crictl rmi
拉取镜像	docker pull	ctr image pull	ctictl pull
推送镜像	docker push	ctr image push	无
在容器内部执行命令	docker exec	无	crictl exec
```


### 清除Evicted Pod
```
kgp -A --field-selector status.phase==Failed -ojson |jq '.items[] |"kubectl delete pods \(.metadata.name) -n \(.metadata.namespace)"' |xargs -n 1 bash -c
```


### 下线某个节点

```bash
# 配置节点不可调度
kubectl cordon <NODE_NAME>
kubectl drain --ignore-daemonsets <NODE_NAME> # --ignore-daemonsets 选项为忽略DaemonSet类型的pod，此时应该会触发pod重启

```
#### 强制删除pod
对于statefulset创建的Pod，kubectl drain的说明如下：  
kubectl drain操作会将相应节点上的旧Pod删除，并在可调度节点上面起一个对应的Pod。当旧Pod没有被正常删除的情况下，新Pod不会起来。例如：旧Pod一直处于Terminating状态。  
对应的解决方式是通过重启相应节点的kubelet，或者强制删除该Pod。
```bash
# 获取node节点上所有的pod名称
kubectl get pod -A -o wide | grep <NODE_NAME>
# 删除pod资源，重新调度到其他节点
kubectl delete pod -n <NAMESPACE> <POD_NAME>
```
#### 删除节点
```bash
kubectl delete node <NODE_NAME>
```
### 升级集群
https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
#### 升级master节点
```bash
# 将 <node-to-drain> 替换为你要腾空的控制面节点名称
kubectl drain <node-to-drain> --ignore-daemonsets
kubectl delete nodes k8s-master-03

kubeadm upgrade plan
kubeadm upgrade apply v1.27.x #第一个控制面节点
kubeadm upgrade node  #对于其它控制面节点

yum install -y kubelet-1.27.x-0 kubectl-1.27.x-0 --disableexcludes=kubernetes
systemctl daemon-reload
systemctl restart kubelet
kubectl uncordon <node-to-uncordon>  #解除节点的保护 
```
#### 从故障状态恢复
如果 kubeadm upgrade 失败并且没有回滚，例如由于执行期间节点意外关闭， 你可以再次运行 kubeadm upgrade。 此命令是幂等的，并最终确保实际状态是你声明的期望状态。
要从故障状态恢复，你还可以运行 kubeadm upgrade apply --force 而无需更改集群正在运行的版本。
在升级期间，kubeadm 向 /etc/kubernetes/tmp 目录下的如下备份文件夹写入数据：
```bash
kubeadm-backup-etcd-<date>-<time> #包含当前控制面节点本地 etcd 成员数据的备份。 如果 etcd 升级失败并且自动回滚也无法修复，则可以将此文件夹中的内容复制到 /var/lib/etcd 进行手工修复。如果使用的是外部的 etcd，则此备份文件夹为空。
kubeadm-backup-manifests-<date>-<time> #包含当前控制面节点的静态 Pod 清单文件的备份版本。 如果升级失败并且无法自动回滚，则此文件夹中的内容可以复制到 /etc/kubernetes/manifests 目录实现手工恢复。 如果由于某些原因，在升级前后某个组件的清单未发生变化，则 kubeadm 也不会为之生成备份版本。
```