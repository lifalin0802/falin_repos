### kubectl get pods 报错：
```bash
The connection to the server 192.168.5.100:8443 was refused - did you specify the right host or port? 什么服务没有启动吗？
```

### 调查方法：
```bash
$ docker ps #查看相应的container是否起来 如果没有 

```

### minikube 安装步骤：
```bash

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube


#下载相关镜像
docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.23.3
docker pull registry.aliyuncs.com/google_containers/kube-controller-manager:v1.23.3
docker pull registry.aliyuncs.com/google_containers/kube-scheduler:v1.23.3
docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.23.3
docker pull registry.aliyuncs.com/google_containers/pause:3.6
docker pull registry.aliyuncs.com/google_containers/etcd:3.5.1-0
docker pull registry.aliyuncs.com/google_containers/coredns:v1.8.6
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/storage-provisioner:v5


# tag镜像
docker tag registry.aliyuncs.com/google_containers/kube-apiserver:v1.23.3          k8s.gcr.io/kube-apiserver:v1.23.3
docker tag registry.aliyuncs.com/google_containers/kube-controller-manager:v1.23.3 k8s.gcr.io/kube-controller-manager:v1.23.3
docker tag registry.aliyuncs.com/google_containers/kube-scheduler:v1.23.3          k8s.gcr.io/kube-scheduler:v1.23.3
docker tag registry.aliyuncs.com/google_containers/kube-proxy:v1.23.3              k8s.gcr.io/kube-proxy:v1.23.3
docker tag registry.aliyuncs.com/google_containers/pause:3.6                       k8s.gcr.io/pause:3.6
docker tag registry.aliyuncs.com/google_containers/etcd:3.5.1-0                    k8s.gcr.io/etcd:3.5.1-0
docker tag registry.aliyuncs.com/google_containers/coredns:v1.8.6                  k8s.gcr.io/coredns/coredns:v1.8.6
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/storage-provisioner:v5 gcr.io/k8s-minikube/storage-provisioner:v5
docker images -a
minikube image load gcr.io/k8s-minikube/storage-provisioner:v5

#重新运行启动命令：
$ minikube start --vm-driver=none --registry-mirror=https://registry.docker-cn.com 

$ minikube start --force --driver=docker --vm-driver=none --registry-mirror=https://registry.docker-cn.com --image-mirror-country='cn' --image-repository='registry.cn-hangzhou.aliyuncs.com/google_containers' --base-image='registry.cn-hangzhou.aliyuncs.com/google_containers/kicbase:v0.0.28'



```
### 1.24+ 的kubernetes 用不了docker ?
解决办法：安装cri-docker 参考`https://baijiahao.baidu.com/s?id=1743733802152777402&wfr=spider&for=pc`
安装方法 https://github.com/Mirantis/cri-dockerd
```bash
#描述：
# * Pulling base image ...
#     > registry.cn-hangzhou.aliyun...:  355.77 MiB / 355.78 MiB  100.00% 2.35 Mi
# * Creating docker container (CPUs=2, Memory=2200MB) ...
# ! This container is having trouble accessing https://registry.k8s.io
# * To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/

# X Exiting due to RT_DOCKER_MISSING_CRI_DOCKER_NONE: sudo systemctl enable cri-docker.socket: Process exited with status 1
# stdout:

# stderr:
# Failed to enable unit: Unit file cri-docker.socket does not exist.

# * Suggestion: Using Kubernetes v1.24+ with the Docker runtime requires cri-docker to be installed
# * Documentation: https://minikube.sigs.k8s.io/docs/reference/drivers/none
# * Related issue: https://github.com/kubernetes/minikube/issues/14410



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



### 查看插件：
```bash
minikube addons list
```


```bash
$ kubectl describe pod storage-provisioner -n kube-system
Events:
  Type     Reason   Age                   From     Message
  ----     ------   ----                  ----     -------
  Warning  Failed   6m25s (x14 over 85m)  kubelet  Failed to pull image "gcr.io/k8s-minikube/storage-provisioner:v5": rpc error: code = Unknown desc = Error response from daemon: Get "https://gcr.io/v2/": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
  Normal   BackOff  95s (x313 over 86m)   kubelet  Back-off pulling image "gcr.io/k8s-minikube/storage-provisioner:v5"


```





### 几个重要的配置文件 ：
```bash
/root/.kube/config  # k8s节点配置信息, node 节点
/etc/kubernetes/admin.conf  # k8s节点配置信息, master节点
/root/.bash_profile # 环境变量配置文件，指定KUBECONFIG配置文件的路径

```
### 问题：  
The connection to the server 192.168.5.100:8443 was refused - did you specify the right host or port? 什么服务没有启动吗？
