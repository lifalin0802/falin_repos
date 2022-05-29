### 几个关键的配置文件：
```bash
cat /etc/kubernetes/manifests/kube-apiserver.yaml
netstat -lpn  #查看端口号及对应的进程id:
```


### 解决apiserver CrashLoopBackOff 的办法：
```bash
kubectl describe pod api-server -n kube-system  
kubectl logs -f kube-apiserver -n kube-system
```
报错信息显示 端口号8443被占用
```bash
[root@centos kubeworkspace]# kubectl delete pod kube-apiserver -n kube-system
pod "kube-apiserver" deleted
[root@centos kubeworkspace]# kubectl apply -f /etc/kubernetes/manifests/kube-apiserver.yaml
pod/kube-apiserver created
[root@centos kubeworkspace]# kubectl get pods -n kube-system
NAME                             READY   STATUS             RESTARTS       AGE
coredns-64897985d-tq6t9          1/1     Running            7 (14h ago)    13d
etcd-centos                      1/1     Running            6 (14h ago)    13d
kube-apiserver                   0/1     CrashLoopBackOff   1 (8s ago)     11s
kube-apiserver-centos            1/1     Running            0              92m
kube-controller-manager-centos   1/1     Running            12 (14h ago)   13d
kube-proxy-7mmq5                 1/1     Running            1 (14h ago)    8d
kube-scheduler-centos            1/1     Running            9 (14h ago)    13d
[root@centos kubeworkspace]# kubectl logs -f kube-apiserver -n kube-system
I0423 13:28:34.501381       1 server.go:565] external host was not specified, using 192.168.5.100
I0423 13:28:34.503363       1 server.go:172] Version: v1.23.3
E0423 13:28:34.504036       1 run.go:74] "command failed" err="failed to create listener: failed to listen on 0.0.0.0:8443: listen tcp 0.0.0.0:8443: bind: address already in use"
[root@centos kubeworkspace]# netstat -lpn|grep 8443 

```
### 杀死进程
此处显示 只有一个交api-server 的进程在占用  
```kill -9 89232``` 之后又重新生成一个pid  
```kubectl get pods -n kube-system``` 此时看api server 的状态好了  
```bash
[root@centos kubeworkspace]# netstat -lpn|grep 8443
tcp6       0      0 :::8443                 :::*                    LISTEN      89232/kube-apiserve
[root@centos kubeworkspace]# kubectl delete pod kube-apiserver -n kube-system                                                                     pod "kube-apiserver" deleted
[root@centos kubeworkspace]# netstat -lpn|grep 8443
tcp6       0      0 :::8443                 :::*                    LISTEN      89232/kube-apiserve
[root@centos kubeworkspace]# kill -9 89232
[root@centos kubeworkspace]# netstat -lpn|grep 8443
tcp6      83      0 :::8443                 :::*                    LISTEN      130955/kube-apiserv
[root@centos kubeworkspace]# kubectl get pods -n kube-system                                                                                      NAME                             READY   STATUS    RESTARTS       AGE
coredns-64897985d-tq6t9          1/1     Running   7 (14h ago)    13d
etcd-centos                      1/1     Running   6 (14h ago)    13d
kube-apiserver-centos            1/1     Running   1 (24s ago)    102m
kube-controller-manager-centos   1/1     Running   12 (14h ago)   13d
kube-proxy-7mmq5                 1/1     Running   1 (14h ago)    8d
kube-scheduler-centos            1/1     Running   9 (14h ago)    13d

```

## 小结

#### 官方模板：
pv：  
https://kubernetes.io/docs/concepts/storage/persistent-volumes/
