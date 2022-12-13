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
/usr/local/apache2 # curl service-headless.dev.svc.cluster.local
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
/usr/local/apache2 #

```
service 只能内网访问, 说明只在内网配置了DNS
公网访问靠ingress



### 创建headless 无头类型的service:

此处注意clusterIP是none，既没有ip, 只产生域名。
```bash
[root@centos kubeworkspace]# kubectl get svc -n dev
NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
pc-deployment       NodePort    10.104.59.61   <none>        80:32470/TCP   40h
service-clusterip   ClusterIP   None           <none>        80/TCP         5s

```
那么域名是啥呢？ 

### 查看无头service的域名

1. 进入pod， 执行```cat /etc/resolv.conf```查看域名服务器，
2. 得知10.96.0.10是dns地址，退出pod
3. 执行```dig @10.96.0.10 svcname.searchXX```查找此域名背后的ip是谁
4. 可以看出是 ```172.17.0.4, 172.17.0.3``` 两台机器
5. ```nslookup``` 只能查本机的dns这里不管用，
```bash
[root@centos kubeworkspace]# vi service-headless.yml
[root@centos kubeworkspace]# kubectl create -f service-headless.yml
service/service-headless created
[root@centos kubeworkspace]# kubectl get svc -n dev
NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
pc-deployment       NodePort    10.104.59.61   <none>        80:32470/TCP   40h
service-headless    ClusterIP   None           <none>        80/TCP         13s
[root@centos kubeworkspace]# kubectl delete service-clusterip -n dev
[root@centos kubeworkspace]# kubectl get pods -n dev
NAME                             READY   STATUS    RESTARTS      AGE
httpd-76f7455774-2vln2           1/1     Running   2 (44h ago)   4d1h
httpd-76f7455774-v45fb           1/1     Running   1 (44h ago)   4d
pc-deployment-557dc8d667-p29kd   1/1     Running   1 (44h ago)   3d1h
pc-deployment-557dc8d667-p2lqz   1/1     Running   1 (44h ago)   3d1h
[root@centos kubeworkspace]# kubectl exec -it pc-deployment-557dc8d667-p29kd -n dev /bin/sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
# cat /etc/resolv.conf
nameserver 10.96.0.10
search dev.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
# exit
[root@centos kubeworkspace]# dig @10.96.0.10 service-headless.dev.svc.cluster.local

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.7 <<>> @10.96.0.10 service-headless.dev.svc.cluster.local
; (1 server found)
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5297  
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;service-headless.dev.svc.cluster.local.        IN A

;; ANSWER SECTION:
service-headless.dev.svc.cluster.local. 30 IN A 172.17.0.4 
service-headless.dev.svc.cluster.local. 30 IN A 172.17.0.3  

;; Query time: 0 msec
;; SERVER: 10.96.0.10#53(10.96.0.10)
;; WHEN: Fri Apr 15 13:15:19 EDT 2022
;; MSG SIZE  rcvd: 175 

[root@centos kubeworkspace]# nslookup service-headless.dev.svc.cluster.local
Server:         192.168.5.2
Address:        192.168.5.2#53

** server can't find service-headless.dev.svc.cluster.local: NXDOMAI
```

### nodeport 类型的service: 
```bash
[root@centos kubeworkspace]# curl 10.106.200.5:80
172.17.0.4
[root@centos kubeworkspace]# curl 192.168.5.100:30002
172.17.0.4
[root@centos kubeworkspace]# curl localhost:30002
^C
[root@centos kubeworkspace]# curl 127.0.0.1:30002
^C
[root@centos kubeworkspace]# cat service-nodeport.yml
apiVersion: v1
kind: Service
metadata:
  name: service-nodeport
  namespace: dev
spec:
  selector:
    app: nginx-pod
  type: NodePort
  ports:
    - port: 80
      nodePort: 30002 #指定绑定的node的端口号， 默认范围是30000-32767，如果不指定则在此区间随机分配
      targetPort: 80 #pod端口
[root@centos kubeworkspace]# kubectl get svc -n dev -o widd
NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE     SELECTOR
pc-deployment       NodePort    10.104.59.61   <none>        80:32470/TCP   2d10h   app=nginx-pod
service-clusterip   ClusterIP   10.97.26.39    <none>        80/TCP         4h41m   app=nginx-pod
service-headless    ClusterIP   None           <none>        80/TCP         17h     app=nginx-pod
service-nodeport    NodePort    10.106.200.5   <none>        80:30002/TCP   39s     app=nginx-pod
[root@centos kubeworkspace]# curl 10.106.200.5:80
172.17.0.4
[root@centos kubeworkspace]# netstat -nltp|grep 80
tcp        0      0 192.168.5.100:2380      0.0.0.0:*               LISTEN                                                     2576/etcd
[root@centos kubeworkspace]# netstat -nltp|grep 30002
tcp        0      0 0.0.0.0:30002           0.0.0.0:*               LISTEN               5971/kube-proxy
[root@centos kubeworkspace]# netstat -nltp|grep 32470
tcp        0      0 0.0.0.0:32470           0.0.0.0:*               LISTEN               5971/kube-proxy
```

### service 的externalname类型
```bash
[root@centos kubeworkspace]# vi service-externalname.yml
[root@centos kubeworkspace]# kubectl create -f service-externalname.yml
service/service-externalname created
[root@centos kubeworkspace]# cat service-externalname.yml
apiVersion: v1
kind: Service
metadata:
  name: service-externalname
  namespace: dev
spec:
  type: ExternalName
  externalName: www.baidu.com
[root@centos kubeworkspace]# dig @10.96.0.10 service-externalname.dev.svc.cluster.local

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.7 <<>> @10.96.0.10 service-externalname.dev.svc.cluster.local
; (1 server found)
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 49449
;; flags: qr aa rd; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;service-externalname.dev.svc.cluster.local. IN A

;; ANSWER SECTION:
service-externalname.dev.svc.cluster.local. 5 IN CNAME www.baidu.com.
www.baidu.com.          5       IN      CNAME   www.a.shifen.com.
www.a.shifen.com.       5       IN      A       39.156.66.14
www.a.shifen.com.       5       IN      A       39.156.66.18

;; Query time: 48 msec
;; SERVER: 10.96.0.10#53(10.96.0.10)
;; WHEN: Sat Apr 16 08:09:20 EDT 2022
;; MSG SIZE  rcvd: 247

[root@centos kubeworkspace]#

```


## 小结：
```bash
$ kubectl expose deployment pc-deployment --target-port 80 --type NodePort -n dev # 1
$ kubectl get svc -n dev
$ cat /etc/resolv.conf  #查看本机用哪台nds
$ dig @ndsIP url #查看本url地址
$ kubectl delete ns dev #会删掉所有dev namespace下所有的资源
```
1. expose: 暴露一个serivce，其中pc-deployment必须存在，且要指定namespace,否则就在default namespace 中找，没有就会报错


### kubernetes 自动补全工具：
```bash
yum install bash-completion -y
```

