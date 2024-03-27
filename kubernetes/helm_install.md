### 手动安装：
https://mp.weixin.qq.com/s/YwnmOA2Ttl0YIhX_nXnUCQ
```bash
# 手动安装 or 
#$ wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz #下载 Helm 二进制文件
$ wget  https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
$ tar -zxvf helm-v2.9.1-linux-amd64.tar.gz # 解压缩
$ cp linux-amd64/helm /usr/local/bin/ # 复制 helm 二进制 到bin目录下
helm version
helm 

#shell脚本安装
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh #
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

### 将 Tiller 安装在 kubernetes 集群中
```bash
#helm init #国外
#helm init —upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1  —stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts #国内
kubectl get po -n kube-system  #查看 tiller 的安装情况
```


### 创建 Kubernetes 的服务帐号和绑定角色
```bash

$ kubectl create serviceaccount --namespace kube-system tiller                               
serviceaccount "tiller" created

$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
clusterrolebinding.rbac.authorization.k8s.io "tiller-cluster-rule" created
```

```bash

helm repo add <name> <url>
helm repo list 

helm search repo
helm search repo mysql

helm show values azure/mysql
helm install db mysql  
helm status db 

helm list 查看本地安装的发行版
    kubectl get pods #可以看到helm install的db
    [root@centos ~]# kubectl get pods
    NAME                        READY   STATUS    RESTARTS       AGE
    db-mysql-599d764c8c-2zxfw   0/1     Pending   0              67s
    freebox                     1/1     Running   34 (48d ago)   50d


#添加repo
helm repo add azure           http://mirror.azure.cn/kubernetes/charts/                                                      
helm repo add rancher-stable  https://releases.rancher.com/server-charts/stable                                              
helm repo add bitnami         https://charts.bitnami.com/bitnami 


helm create test
helm package test
helm search nginx


# Helm管理应用生命周期：
helm create  test #制作Chart

helm install # 部署  !!!!最常用！！！
helm upgrade #更新
helm rollback #回滚
helm uninstall #卸载

```

### Chart 文件结构
```

wordpress
├── charts
├── Chart.yaml
├── README.md
├── requirements.lock
├── requirements.yaml
├── templates
│   ├── deployment.yaml
│   ├── externaldb-secrets.yaml
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── pvc.yaml
│   ├── secrets.yaml
│   ├── svc.yaml
│   └── tls-secrets.yaml
└── values.yaml



```bash

 
wget https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz #对应自己k8s版本号
tar xf helm-v3.8.1-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm



helm init —upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1  —stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```




### helm 修改repo源

```bash
helm repo remove stable
helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
helm repo update
helm search
```

### 其他好的文献：
`https://blog.csdn.net/huahua1999/article/details/124602624` helm 初探  
`https://mp.weixin.qq.com/s/YwnmOA2Ttl0YIhX_nXnUCQ` 
`https://blog.csdn.net/m0_58292366/article/details/126152563`helm 命令可用
