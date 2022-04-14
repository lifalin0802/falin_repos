### 创建一个service:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-clusterip
  namespace: dev
spec:   
  selector: 
    app: nginx-pod
  clusterIP:   #不写会自动生成一个IP
  type: ClusterIP
  ports:
    - port: 80 #Service端口
      targetPort: 80 #pod端口
```

### 通过yml创建service：
此处可以看出严格意义的deployment-replica-pod的命名层级
```bash
[root@centos kubeworkspace]# kubectl create -f service-clusterip.yml
service/service-clusterip created
[root@centos kubeworkspace]# kubectl get svc -n dev -o wide
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service-clusterip   ClusterIP   10.105.243.201   <none>        80/TCP    24s   app=nginx-pod
[root@centos kubeworkspace]# kubectl get deployments -n dev
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
httpd           2/2     2            2           24h
pc-deployment   3/3     3            3           37m
[root@centos kubeworkspace]# kubectl get rs -n dev
NAME                       DESIRED   CURRENT   READY   AGE
httpd-76f7455774           2         2         2       24h
pc-deployment-557dc8d667   3         3         3       35m
[root@centos kubeworkspace]# kubectl get pods -n dev -o wide
NAME                             READY   STATUS    RESTARTS      AGE     IP            NODE     NOMINATED NODE   READINESS                                  GATES
httpd-76f7455774-2vln2           1/1     Running   1 (23h ago)   24h     172.17.0.7    centos   <none>           <none>
httpd-76f7455774-v45fb           1/1     Running   0             23h     172.17.0.8    centos   <none>           <none>
pc-deployment-557dc8d667-p29kd   1/1     Running   0             4m11s   172.17.0.11   centos   <none>           <none>
pc-deployment-557dc8d667-p2lqz   1/1     Running   0             4m11s   172.17.0.9    centos   <none>           <none>
pc-deployment-557dc8d667-rkt9r   1/1     Running   0             4m11s   172.17.0.10   centos   <none>           <none>
[root@centos kubeworkspace]# docker ps|grep nginx
4c705272d8e5   98ebf73aba75           "nginx -g 'daemon of…"   39 minutes ago   Up 39 minutes                                               k8s_nginx-pod_pc-deployment-557dc8d667-rkt9r_dev_4442c9a5-c192-4830-a844-fba0b095ef03_0
ada81f0e80a8   98ebf73aba75           "nginx -g 'daemon of…"   39 minutes ago   Up 39 minutes                                               k8s_nginx-pod_pc-deployment-557dc8d667-p29kd_dev_015ef67f-e6ac-43c8-a2b1-b28546595bd8_0
05ab85aa81cd   98ebf73aba75           "nginx -g 'daemon of…"   39 minutes ago   Up 39 minutes                                               k8s_nginx-pod_pc-deployment-557dc8d667-p2lqz_dev_56b3fecf-6014-488e-b5e8-2bcf6d8fb1b8_0
d08c20eca922   nginx                  "nginx -g 'daemon of…"   44 hours ago     Up 44 hours                                                 k8s_nginx-pod_nginx-pod-b2796_default_017f4c23-84e7-47b3-b4de-20da9437eabd_0
063999e74eea   nginx                  "nginx -g 'daemon of…"   44 hours ago     Up 44 hours                                                 k8s_nginx-pod_nginx-pod-mfkv9_default_2dbdf268-d43e-442b-9632-f820254a5ac8_0
b4840f3f80e0   nginx                  "nginx -g 'daemon of…"   44 hours ago     Up 44 hours                                                 k8s_nginx-pod_nginx-pod-g84mg_default_dca19061-5455-494e-b0ce-0c93b7af00af_0
6140a38a86a3   k8s.gcr.io/pause:3.6   "/pause"                 44 hours ago     Up 44 hours                                                 k8s_POD_nginx-pod-mfkv9_default_2dbdf268-d43e-442b-9632-f820254a5ac8_0
30c1b3d45b57   k8s.gcr.io/pause:3.6   "/pause"                 44 hours ago     Up 44 hours                                                 k8s_POD_nginx-pod-b2796_default_017f4c23-84e7-47b3-b4de-20da9437eabd_0
c8c1c47bcb4b   k8s.gcr.io/pause:3.6   "/pause"                 44 hours ago     Up 44 hours                                                 k8s_POD_nginx-pod-g84mg_default_dca19061-5455-494e-b0ce-0c93b7af00af_0
[root@centos kubeworkspace]# [root@centos kubeworkspace]# docker ps|grep nginx
30c1b3d45b57   k8s.gcr.io/pause:3.6   "/pause"                 44 hours ago     Up 44 hours                                                 k8s_POD_nginx-pod-b2796_default_017f4c23-84e7-47b3-b4de-20da9437eabd_0
c8c1c47bcb4b   k8s.gcr.io/pause:3.6   "/pause"                 44 hours ago     Up 44 hours                                                 k8s_POD_nginx-pod-g84mg_default_dca19061-5455-494e-b0ce-0c93b7af00af_0

```


### 通过expose 创建service:
```bash
[root@centos ~]# kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   4d5h
[root@centos ~]# kubectl expose deployment d-nodeport --target-port 80 --type NodePort
Error from server (NotFound): deployments.apps "d-nodeport" not found
[root@centos ~]# kubectl expose deployment d1 --target-port 80 --type NodePortError from server (NotFound): deployments.apps "d1" not found
[root@centos ~]# kubectl get deployments
No resources found in default namespace.
[root@centos ~]# kubectl get deployments -n dev
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
httpd           2/2     2            2           2d8h
pc-deployment   2/2     2            2           32h
[root@centos ~]# kubectl expose deployment pc-deployment --target-port 80 --type NodePort
Error from server (NotFound): deployments.apps "pc-deployment" not found
[root@centos ~]# kubectl expose deployment pc-deployment --target-port 80 --type NodePort -n dev
service/pc-deployment exposed
[root@centos ~]# kubectl get svc -n dev
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
pc-deployment       NodePort    10.104.59.61     <none>        80:32470/TCP   36s
service-clusterip   ClusterIP   10.105.243.201   <none>        80/TCP         32h
```

### 通过curl测试创建的service:
内网： curl 10.104.59.61:80
容器内访问: curl pc-deployment
```bash
[root@centos ~]$ curl 10.104.59.61:80

[root@centos ~]# kubectl exec -it httpd-76f7455774-2vln2 -n dev sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/usr/local/apache2 # apk add curl
fetch https://dl-cdn.alpinelinux.org/alpine/v3.15/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.15/community/x86_64/APKINDEX.tar.gz
(1/1) Installing curl (7.80.0-r0)
Executing busybox-1.34.1-r5.trigger
OK: 49 MiB in 35 packages
/usr/local/apache2 # curl pc-deployment
172.17.0.3
/usr/local/apache2 #
```
service 只能内网访问, 说明只在内网配置了DNS
公网访问靠ingress


```bash
[root@centos ~]# docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED        STATUS       PORTS                                       NAMES
51a915511187   98ebf73aba75           "nginx -g 'daemon of…"   4 hours ago    Up 4 hours                                               k8s_nginx-pod_pc-deployment-557dc8d667-p2lqz_dev_56b3fecf-6014-488e-b5e8-2bcf6d8fb1b8_1
59f8b0b8e744   98ebf73aba75           "nginx -g 'daemon of…"   4 hours ago    Up 4 hours                                               k8s_nginx-pod_pc-deployment-557dc8d667-p29kd_dev_015ef67f-e6ac-43c8-a2b1-b28546595bd8_1
a857862b9c31   k8s.gcr.io/pause:3.6   "/pause"                 4 hours ago    Up 4 hours                                               k8s_POD_pc-deployment-557dc8d667-p29kd_dev_015ef67f-e6ac-43c8-a2b1-b28546595bd8_1
878f2a18c3fc   k8s.gcr.io/pause:3.6   "/pause"                 4 hours ago    Up 4 hours                                               k8s_POD_pc-deployment-557dc8d667-p2lqz_dev_56b3fecf-6014-488e-b5e8-2bcf6d8fb1b8_1
[root@centos ~]# kubectl get pods -n dev
NAME                             READY   STATUS    RESTARTS       AGE
httpd-76f7455774-2vln2           1/1     Running   2 (4h5m ago)   2d9h
httpd-76f7455774-v45fb           1/1     Running   1 (4h5m ago)   2d7h
pc-deployment-557dc8d667-p29kd   1/1     Running   1 (4h5m ago)   32h
pc-deployment-557dc8d667-p2lqz   1/1     Running   1 (4h5m ago)   32h
[root@centos ~]# kubectl get deployments -n dev
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
httpd           2/2     2            2           2d9h
pc-deployment   2/2     2            2           32h

```

```bash
$ kubectl expose deployment pc-deployment --target-port 80 --type NodePort -n dev # 1
$ kubectl get svc -n dev
```
1. expose: 暴露一个serivce，其中pc-deployment必须存在，且要指定namespace,否则就在default namespace 中找，没有就会报错


### kubernetes 自动补全工具：
```bash
yum install bash-completion -y
```

