# kubernetes manual

### 创建自主pod
```bash
kubectl run d1 --image httpd:alpine --port 80 
pod/d1 created

kubectl get deployments #没有东西
kubectl get pods #有了
kubectl get pods -o wide #有了

kubectl describe pod d1 #查看描述
kubectl delete pod d1 #删除pod
```
### 创建deployment
```bash
kubectl create environment dev #创建名字为dev 的namespace
kubectl create deployment httpd --image httpd:alpine --port 80 -n dev #c创建deployment
kubectl get deployments -n dev
kubectl get deployment -n dev #单复数都可以
```

这里删除 ``kubectl delete pod d1``**只对自主pod work**
run命令也只是启动一个**自主的pod,**

### 要点解释：

1. ```kubectl create deployment XX``` 正常创建deployment ，默认会创建**一个pod+两个docker容器**, 一个docker是httpd本身，另一个是pause 这个容器。
2. pause容器干啥的？
  相当于infor 容器, 用于共享**网络**，**存储**。
3. **pod可以不属于任何namespace**,可以没有namespace的概念。

```bash
[root@centos ~]# kubectl run d1 --image httpd:alpine --port 80
pod/d1 created

[root@centos ~]# kubectl get ns
NAME              STATUS   AGE
default           Active   41h
kube-node-lease   Active   41h
kube-public       Active   41h
kube-system       Active   41h

[root@centos ~]# kubectl get pods
NAME              READY   STATUS    RESTARTS   AGE
d1                1/1     Running   0          70m
nginx-pod-b2796   1/1     Running   0          16h
nginx-pod-g84mg   1/1     Running   0          16h
nginx-pod-mfkv9   1/1     Running   0          16h
[root@centos ~]# kubectl get pods -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
d1                1/1     Running   0          98m   172.17.0.7   centos   <none>           <none>
nginx-pod-b2796   1/1     Running   0          16h   172.17.0.6   centos   <none>           <none>
nginx-pod-g84mg   1/1     Running   0          16h   172.17.0.4   centos   <none>           <none>
nginx-pod-mfkv9   1/1     Running   0          16h   172.17.0.5   centos   <none>           <none>

[root@centos ~]# kubectl delete pod d1
pod "d1" deleted
[root@centos ~]# kubectl get pods
NAME              READY   STATUS    RESTARTS   AGE
nginx-pod-b2796   1/1     Running   0          19h
nginx-pod-g84mg   1/1     Running   0          19h
nginx-pod-mfkv9   1/1     Running   0          19h

[root@centos ~]# kubectl create namespace dev
namespace/dev created
[root@centos ~]# kubectl create deployment httpd --image httpd:alpine --port 80 -n dev
deployment.apps/httpd created
[root@centos ~]# kubectl get deployment
No resources found in default namespace.
[root@centos ~]# kubectl get deployments
No resources found in default namespace.
[root@centos ~]# kubectl get deployments -n dev
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
httpd   1/1     1            1           15m
[root@centos ~]# kubectl get deployment -n dev
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
httpd   1/1     1            1           15m
```
### 查看docker
由deployment创建的:
```bash
[root@centos ~]# docker ps|grep httpd
7f0d6dbbee25   5c2ee73209da           "httpd-foreground"       15 minutes ago   Up 15 minutes                                               k8s_httpd_httpd-76f7455774-2vln2_dev_e0e8e85b-149a-4220-9817-26205137f762_0
f4033c816a79   k8s.gcr.io/pause:3.6   "/pause"                 15 minutes ago   Up 15 minutes                                               k8s_POD_httpd-76f7455774-2vln2_dev_e0e8e85b-149a-4220-9817-26205137f762_0
[root@centos ~]# kubectl get pod -n dev
NAME                     READY   STATUS    RESTARTS   AGE
httpd-76f7455774-2vln2   1/1     Running   0          16m
[root@centos ~]#
[root@centos ~]# docker stop 7f
7f
[root@centos ~]# docker ps |grep httpd
1b2ebeb00111   5c2ee73209da           "httpd-foreground"       14 seconds ago      Up 13 seconds                                                  k8s_httpd_httpd-76f7455774-2vln2_dev_e0e8e85b-149a-4220-9817-26205137f762_1
f4033c816a79   k8s.gcr.io/pause:3.6   "/pause"                 About an hour ago   Up About an hour                                               k8s_POD_httpd-76f7455774-2vln2_dev_e0e8e85b-149a-4220-9817-26205137f762_0
[root@centos ~]#

```

默认pod namespace 是 `<none>`
### 查看deployment
若改成replica副本数量是2, 则启动4个docker
```bash
[root@centos ~]# docker ps | grep httpd
93d9558ff466   5c2ee73209da           "httpd-foreground"       12 seconds ago      Up 11 seconds                                                  k8s_httpd_httpd-76f7455774-v45fb_dev_be9d0c08-6330-42b9-acd1-1cccc569beb4_0
9918a9c4ac8b   k8s.gcr.io/pause:3.6   "/pause"                 13 seconds ago      Up 12 seconds                                                  k8s_POD_httpd-76f7455774-v45fb_dev_be9d0c08-6330-42b9-acd1-1cccc569beb4_0
1b2ebeb00111   5c2ee73209da           "httpd-foreground"       11 minutes ago      Up 11 minutes                                                  k8s_httpd_httpd-76f7455774-2vln2_dev_e0e8e85b-149a-4220-9817-26205137f762_1
f4033c816a79   k8s.gcr.io/pause:3.6   "/pause"                 About an hour ago   Up About an hour                                               k8s_POD_httpd-76f7455774-2vln2_dev_e0e8e85b-149a-4220-9817-26205137f762_0
```
1个deployment
```bash
[root@centos ~]# kubectl get deployment -n dev
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
httpd   2/2     2            2           79m
```
2个pod:
```bash
[root@centos ~]# kubectl get pods -n dev
NAME                     READY   STATUS    RESTARTS      AGE
httpd-76f7455774-2vln2   1/1     Running   1 (17m ago)   83m
httpd-76f7455774-v45fb   1/1     Running   0             5m56s

```

### 查看apiversion 可用版本
```bash
kubectl api-versions
```

```bash
[root@centos ~]# kubectl describe pod d1
Name:         d1
Namespace:    default
Priority:     0
Node:         centos/192.168.5.100
Start Time:   Mon, 11 Apr 2022 07:08:33 -0400
Labels:       run=d1
Annotations:  <none>
Status:       Running
IP:           172.17.0.7
IPs:
  IP:  172.17.0.7
Containers:
  d1:
    Container ID:   docker://b368ac46d5990c4b129260bd1a9f1865e2c23a02157fdc99d227fd8a28ff1635
    Image:          httpd:alpine
    Image ID:       docker-pullable://httpd@sha256:4eb4177b9245c686696dd8120c79cd64b7632b27d890db4cad3b0e844ed737af
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Mon, 11 Apr 2022 07:09:13 -0400
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xspzq (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-xspzq:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:  
                    <none>
```
