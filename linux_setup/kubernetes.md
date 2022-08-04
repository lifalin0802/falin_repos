### 安装bind

```bash

#配置镜像源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum repolist #查看镜像源

#安装常用工具
yum install -y yum-utils device-mapper-persistent-data lvm2
```


### kubernetes使用：
```bash
kubectl explain pods.spec  
kubectl get nodes --show-labels
kubectl label nodes node1  nodehaha

```