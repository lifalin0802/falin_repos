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
