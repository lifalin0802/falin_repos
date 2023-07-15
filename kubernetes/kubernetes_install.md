### 安装bind

```bash

#配置镜像源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum repolist #查看镜像源
yum list installed

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

echo"1"> /proc/sys/net/ipv4/ip_forward 
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

[root@master01 lifalin]# kubectl get nodes
NAME       STATUS     ROLES           AGE   VERSION
master01   NotReady   control-plane   67m   v1.24.3
node02     Ready      <none>          23m   v1.24.3
[root@master01 lifalin]# kubectl  label node  node02 node-role.kubernetes.io/worker=
node/node02 labeled
[root@master01 lifalin]# kubectl  label node  node02 node-role.kubernetes.io/node=
node/node02 labeled
[root@master01 lifalin]# kubectl get nodes
NAME       STATUS     ROLES           AGE   VERSION
master01   NotReady   control-plane   72m   v1.24.3
node02     Ready      node,worker     27m   v1.24.3
[root@master01 lifalin]# kubectl  label node  node02 node-role.kubernetes.io/node-
node/node02 unlabeled
[root@master01 lifalin]# kubectl get nodes
NAME       STATUS     ROLES           AGE   VERSION
master01   NotReady   control-plane   72m   v1.24.3
node02     Ready      worker          28m   v1.24.3

```

### kubernetes 二进制安装：
#### 安装证书：
```bash
mkdir -p /opt/TLS/{download,etcd,k8s}

cd /opt/TLS/download
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl-certinfo_1.6.1_linux_amd64
chmod +x cfssl*
cp cfssl_1.6.1_linux_amd64 /usr/local/bin/cfssl
cp cfssljson_1.6.1_linux_amd64 /usr/local/bin/cfssljson
cp cfssl-certinfo_1.6.1_linux_amd64 /usr/local/bin/cfssl-certinfo

#签发证书：
cfssl gencert -initca ca-csr.json | cfssljson -bare ca - 

cfssl gencert -ca=ca.pem -ca-key=key.pem -config=ca-config.json -profile=client client-csr.json| cfssljson -bare client -
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=../ca-config.json -profile=client server-csr.json | cfssljson -bare server
sed -i 's/centos-master/localhost.localdomain/g' /etc/kubernetes/kubelet.conf


mkdir -p /opt/certs
cat > /opt/certs/ca-csr.json << eof
{
  "CN": "kubernetes",  #证书颁发的机构名称
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


cat > /opt/certs/ca-config.json  << eof
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
eof



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
yum install sshpass
sshpass -p "lfl" scp centos:/opt/certs/ca.pem ca.crt
sshpass -p "lfl" scp centos:/opt/certs/ca-key.pem ca.key



kubeadm config print init-defaults  > kubeadm-config.yaml #生成kubeadm 配置文件，这里是master 节点用的
kubeadm config print join-defaults > kubeadm-config.yaml # 生成join的kubeadm的配置文件，node节点上运行


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
vi /etc/modules-load.d/containerd.conf
overlay
br_netfilter

#调整containerd 配置文件
containerd config default|tee /etc/containerd/config.toml #将现在默认的配置写入config.toml文件中


vim  /etc/containerd/confi  g.toml
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
mkdir -p /etc/kubernetes/pki
cd /etc/kubernetes/pki
sshpass -p "lfl" scp centos:/opt/certs/ca.pem ca.crt
sshpass -p "lfl" scp centos:/opt/certs/ca-key.pem ca.key



kubeadm init \
--apiserver-advertise-address=192.168.5.140 \
--image-repository registry.aliyuncs.com/google_containers \
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \
--upload-certs


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
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
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

kubectl taint node node01  node-role.kubernetes.io/master-
kubectl taint node node01 key1-
kubectl taint nodes master1 node-role.kubernetes.io/master=:NoSchedule

kubectl describe nodes prod-k8s-apm-node-data3  |grep Taints
kubectl taint node prod-k8s-apm-node-data3  
kubectl taint node prod-k8s-apm-node-data1 app=bigdata:NoExecute
kubectl taint node prod-k8s-apm-node-data2 app=bigdata:NoExecute
kubectl taint node prod-k8s-apm-node-data3 app=bigdata:NoExecute


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


#查看报错信息
kubectl describe pod xxx -n namespace
kubectl logs xxx -n namespace
# kubectl logs -n kube-system calico-kube-controllers-775bf69498-xqdbl   #查看日志
# kubectl describe pod calico-kube-controllers-775bf69498-kfwrk -n kube-system #查看细节 日志


systemctl status kubelet --full
systemctl is-enabled firewalld # 查看 firewalld状态

#安装calico
curl https://projectcalico.docs.tigera.io/manifests/calico-etcd.yaml -o calico.yaml
 https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/tigera-operator.yaml




cat /etc/kubernetes/pki/etcd/ca.crt | base64 -w 0

#替换calico.yaml 中的etcd的证书信息，etcd 地址  refered to :https://www.jianshu.com/p/5d760511b640
#r如果etcd是http访问的，那就不用配置证书了，直接指定etcd地址就可以了
#!/bin/bash 
ETCD_ENDPOINTS="https://192.168.5.140:2379"
sed -i "s#.*etcd_endpoints:.*#  etcd_endpoints: \"${ETCD_ENDPOINTS}\"#g" calico.yaml
sed -i "s#__ETCD_ENDPOINTS__#${ETCD_ENDPOINTS}#g" calico.yaml

# ETCD 证书信息
ETCD_CA=`cat /etc/kubernetes/pki/etcd/ca.crt | base64 | tr -d '\n'`
ETCD_CERT=`cat /etc/kubernetes/pki/etcd/server.crt | base64 | tr -d '\n'`
ETCD_KEY=`cat /etc/kubernetes/pki/etcd/server.key | base64 | tr -d '\n'`

# 替换修改
sed -i "s#.*etcd-ca:.*#  etcd-ca: ${ETCD_CA}#g" calico.yaml
sed -i "s#.*etcd-cert:.*#  etcd-cert: ${ETCD_CERT}#g" calico.yaml
sed -i "s#.*etcd-key:.*#  etcd-key: ${ETCD_KEY}#g" calico.yaml

sed -i 's#.*etcd_ca:.*#  etcd_ca: "/calico-secrets/etcd-ca"#g' calico.yaml
sed -i 's#.*etcd_cert:.*#  etcd_cert: "/calico-secrets/etcd-cert"#g' calico.yaml
sed -i 's#.*etcd_key:.*#  etcd_key: "/calico-secrets/etcd-key"#g' calico.yaml

sed -i "s#__ETCD_CA_CERT_FILE__#/etc/kubernetes/pki/etcd/ca.crt#g" calico.yaml
sed -i "s#__ETCD_CERT_FILE__#/etc/kubernetes/pki/etcd/server.crt#g" calico.yaml
sed -i "s#__ETCD_KEY_FILE__#/etc/kubernetes/pki/etcd/server.key#g" calico.yaml

sed -i "s#__KUBECONFIG_FILEPATH__#/etc/cni/net.d/calico-kubeconfig#g" calico.yaml



#设置  CALICO_IPV4POOL_CIDR  要和kube-controller-manager 一致 --cluster-cidr=10.244.0.0/16
 - name: CALICO_IPV4POOL_CIDR
   value: "10.244.0.0/16"
#修改or添加 网卡参数 IP_AUTODETECTION_METHOD
  - name: IP_AUTODETECTION_METHOD
    value: "interface=ens33"


#最后apply,
kubectl apply -f calico.yaml

[root@master01 lifalin]# kubectl get pods --all-namespaces -o wide
NAMESPACE     NAME                                       READY   STATUS              RESTARTS        AGE    IP              NODE       NOMINATED NODE   READINESS GATES
kube-system   calico-kube-controllers-775bf69498-25vk6   0/1     Running             1 (5s ago)      18s    192.168.5.142   node02     <none>           <none>
kube-system   calico-node-2b9h4                          0/1     Running             0               18s    192.168.5.140   master01   <none>           <none>
kube-system   calico-node-k7pmx                          0/1     Running             0               18s    192.168.5.142   node02     <none>           <none>
kube-system   coredns-74586cf9b6-4jqcv                   0/1     ContainerCreating   0               38m    <none>          node02     <none>           <none>
kube-system   coredns-74586cf9b6-h9kzg                   0/1     ContainerCreating   0               28h    <none>          master01   <none>           <none>
kube-system   etcd-master01                              1/1     Running             1               28h    192.168.5.140   master01   <none>           <none>
kube-system   kube-apiserver-master01                    1/1     Running             0               28h    192.168.5.140   master01   <none>           <none>
kube-system   kube-controller-manager-master01           1/1     Running             1 (6h58m ago)   28h    192.168.5.140   master01   <none>           <none>
kube-system   kube-proxy-56lw2                           1/1     Running             0               144m   192.168.5.142   node02     <none>           <none>
kube-system   kube-proxy-6bd4t                           1/1     Running             0               28h    192.168.5.140   master01   <none>           <none>
kube-system   kube-scheduler-master01                    1/1     Running             1 (6h58m ago)   28h    192.168.5.140   master01   <none>           <none>

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
```bash


```


### calicoctl 安装:
```bash 
wget -c https://github.com/projectcalico/calicoctl/releases/download/v3.5.4/calicoctl -O /usr/bin/calicoct
cp calicoctl /usr/bin
chmod +x /usr/bin/calicoctl

DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl node status #命令测试S

#设置环境变量
export CALICO_DATASTORE_TYPE=kubernetes
export CALICO_KUBECONFIG=~/.kube/config
calicoctl get workloadendpoints

calicoctl node status #查看bgp情况
calicoctl get nodes
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
查看容器日志	docker logs     	无	                      crictl logs 
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