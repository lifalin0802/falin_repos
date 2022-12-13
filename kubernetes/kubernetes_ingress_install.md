### 下载mandatory.yaml:

下载地址是：https://github.com/kubernetes/ingress-nginx/tree/nginx-0.30.0/deploy/static

1. 关于版本：  
   要修改apiversion版本号
   将文件中的rbac.authorization.k8s.io/v1beta1 替换成 rbac.authorization.k8s.io/v1  
   原因是1.20版本已经v1beta1版本已经过期，所以最好是改成v1不然会告警或报错。  
2. 关于quey.io镜像源  
   quey.io不用替换, 国内网络也可以下载此repo源  
3. 关于yml语法：  
   apiversion后边不许有空格
   下图报错是因为apiVersion： 后边有一个空格，语法错误   
   ![img](image/kubernetes_ingress_install/1650124493606.png)

```bash
[root@centos ingress-controller]# rm -rf mandatory.yaml
[root@centos ingress-controller]# ls
mandatory.yaml
[root@centos ingress-controller]# kubectl apply -f ./
namespace/ingress-nginx created
configmap/nginx-configuration created
configmap/tcp-services created
configmap/udp-services created
serviceaccount/nginx-ingress-serviceaccount created
deployment.apps/nginx-ingress-controller created
limitrange/ingress-nginx created
unable to recognize "mandatory.yaml": no matches for kind "ClusterRole" in version "\u00a0rbac.authorization.k8s.io/v1"
unable to recognize "mandatory.yaml": no matches for kind "Role" in version "\u00a0rbac.authorization.k8s.io/v1"
unable to recognize "mandatory.yaml": no matches for kind "RoleBinding" in version "\u00a0rbac.authorization.k8s.io/v1"
unable to recognize "mandatory.yaml": no matches for kind "ClusterRoleBinding" in version "\u00a0rbac.authorization.k8s.io/v1"
[root@centos ingress-controller]# kubectl apply -f ./
namespace/ingress-nginx unchanged
configmap/nginx-configuration unchanged
configmap/tcp-services unchanged
configmap/udp-services unchanged
serviceaccount/nginx-ingress-serviceaccount unchanged
clusterrole.rbac.authorization.k8s.io/nginx-ingress-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-role created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-role-nisa-binding created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-clusterrole-nisa-binding created
deployment.apps/nginx-ingress-controller unchanged
limitrange/ingress-nginx configured
[root@centos ingress-controller]#
```

1. 下载service-nodeport.yaml  
   地址：https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/deploy/static/provider/baremetal/service-nodeport.yaml  
   下载后加上nodePort分别指向该node 30080,30443两个地址  
   注明： 此处30080 改为30082, 因为30080要给kuboard使用  
   &ensp;Q:这个yml 做什么的？  
   &ensp;A:就是初始化这个一个nginx pod实例。做url <--> service映射  

### 测试，以tomcat 为例
```bash
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
