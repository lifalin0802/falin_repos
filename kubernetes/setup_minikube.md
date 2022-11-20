### 安装minikube:

```bash
#下载minikube 
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

#下载minikube 所需镜像
docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.23.3
docker pull registry.aliyuncs.com/google_containers/kube-controller-manager:v1.23.3
docker pull registry.aliyuncs.com/google_containers/kube-scheduler:v1.23.3
docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.23.3
docker pull registry.aliyuncs.com/google_containers/pause:3.6
docker pull registry.aliyuncs.com/google_containers/etcd:3.5.1-0
docker pull registry.aliyuncs.com/google_containers/coredns:v1.8.6

#给本地镜像打tag标签，因为 minikube start 会用到，否则到时候会docker pull, 由于镜像在海外 pull 受阻
docker tag registry.aliyuncs.com/google_containers/kube-apiserver:v1.23.3          k8s.gcr.io/kube-apiserver:v1.23.3
docker tag registry.aliyuncs.com/google_containers/kube-controller-manager:v1.23.3 k8s.gcr.io/kube-controller-manager:v1.23.3
docker tag registry.aliyuncs.com/google_containers/kube-scheduler:v1.23.3          k8s.gcr.io/kube-scheduler:v1.23.3
docker tag registry.aliyuncs.com/google_containers/kube-proxy:v1.23.3              k8s.gcr.io/kube-proxy:v1.23.3
docker tag registry.aliyuncs.com/google_containers/pause:3.6                       k8s.gcr.io/pause:3.6
docker tag registry.aliyuncs.com/google_containers/etcd:3.5.1-0                    k8s.gcr.io/etcd:3.5.1-0
docker tag registry.aliyuncs.com/google_containers/coredns:v1.8.6                  k8s.gcr.io/coredns/coredns:v1.8.6

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


### 启动minikube
```bash
#清除minikube之前的配置
minikube delete


#关闭swap 分区
swapoff -a     #暂时关闭
free -m
vi /etc/fstab  #注释掉swap所在行 永久关闭
sed -ri 's/.*swap.*/#&/' /etc/fstab # 永久关闭swap 其实就是将swap这一行注释掉
mount -a #使之生效

reboot         #永久关闭需要重启 

#错误 [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1
echo "1" >/proc/sys/net/bridge/bridge-nf-call-iptables  

#如果执行上面的命令后提示没有这个文件，则继续执行下面的命令：modprobe br_netfilter
#执行后再执行上面的echo命令


#启动minikube
minikube start --vm-driver=none --registry-mirror=https://registry.docker-cn.com
```