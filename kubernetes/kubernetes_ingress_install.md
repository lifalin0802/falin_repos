### ingress安装：
refered to https://kubernetes.github.io/ingress-nginx/deploy/#quick-start
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

### 测试，以tomcat 为例
```bash

➜  ~ k get svc -A          
NAMESPACE          NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
calico-apiserver   calico-api                           ClusterIP      10.96.99.95     <none>        443/TCP                         55d
calico-system      calico-kube-controllers-metrics      ClusterIP      None            <none>        9094/TCP                        55d
calico-system      calico-typha                         ClusterIP      10.96.123.219   <none>        5473/TCP                        55d
default            kubernetes                           ClusterIP      10.96.0.1       <none>        443/TCP                         55d
default            nginx-demo                           NodePort       10.96.6.65      <none>        8080:30645/TCP                  21m
dev                tomcat-svc                           NodePort       10.96.94.157    <none>        8080:32009/TCP,8009:30527/TCP   11m
ingress-nginx      ingress-nginx-controller             LoadBalancer   10.96.60.213    <pending>     80:30279/TCP,443:30962/TCP      21h
ingress-nginx      ingress-nginx-controller-admission   ClusterIP      10.96.131.113   <none>        443/TCP                         21h
kube-system        kube-dns                             ClusterIP      10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP          55d

~ # curl -I 10.96.94.157:8080
HTTP/1.1 200 
Content-Type: text/html;charset=UTF-8
Transfer-Encoding: chunked
Date: Sat, 06 Jan 2024 15:55:15 GMT

~ # curl -I 192.168.232.132:32009
HTTP/1.1 200 
Content-Type: text/html;charset=UTF-8
Transfer-Encoding: chunked
Date: Sat, 06 Jan 2024 15:55:39 GMT



[root@centos kubeworkspace]# kubectl get svc -n dev
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)             AGE
pc-deployment          NodePort       10.104.59.61    <none>          80:32470/TCP        2d16h
service-clusterip      ClusterIP      10.97.26.39     <none>          80/TCP              11h
service-externalname   ExternalName   <none>          www.baidu.com   <none>              5h1m
service-headless       ClusterIP      None            <none>          80/TCP              23h
service-nodeport       NodePort       10.106.200.5    <none>          80:30002/TCP        6h40m
tomcat-svc             ClusterIP      10.100.234.87   <none>          8080/TCP,8009/TCP   22m
#一直work ,没有ingress也work, clusterip:clusterpot, 但是直接ping clusterip 不通
[root@centos kubeworkspace]# curl 10.100.234.87:8080
<!doctype html><html lang="en"><head><title>HTTP Status 404 – Not Found</title><style type="text/css">body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}</style></head><body><h1>HTTP Status 404 – Not Found</h1><hr class="line" /><p><b>Type</b> Status Report</p><p><b>Description</b> The origin server did not find a current representation for the target resource or is not willing to disclose that one exists.</p><hr class="line" /><h3>Apache Tomcat/10.0.20</h3></body></html>[root@centos kubeworkspace]#
[root@centos kubeworkspace]# curl tomcat.my.com
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>

[root@centos kubeworkspace]# kubectl describe ing ingress-tomcat-http -n dev
Name:             ingress-tomcat-http
Labels:           <none>
Namespace:        dev
Address:
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host           Path  Backends
  ----           ----  --------
  tomcat.my.com
                 /   tomcat-svc:8080 (172.17.0.13:8080)
Annotations:     <none>
Events:          <none>
[root@centos kubeworkspace]#
```
此处没有调试好，但是可以看到ingress已经配置成功了，
![](image/kubernetes_ingress_install/1650170481545.png)
