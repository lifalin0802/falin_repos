
```bash
wget https://golang.google.cn/dl/go1.19.linux-amd64.tar.gz
tar -xzf go1.19.linux-amd64.tar.gz
mv go  /usr/local/src
echo "export PATH=$PATH:/usr/local/src/go/bin" >> /etc/profile
source /etc/profile

go version #简单测试
go env -w GO111MODULE=on  # 打开Go modules
go env -w GOPROXY=https://goproxy.cn,direct # 设置GOPROXY
```



### 安装kubebuilder
https://blog.csdn.net/xueqinglalala/article/details/127870545
```bash
#查看go环境变量
go env GOOS
go env GOARCH

curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/linux/amd64
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

#验证是否安装成功
kubebuilder version
```


```bash
go mod init my.domain/kubebuilder/helloworld #创建一个项目
kubebuilder init --domain my.domain --repo my.domain/guestbook
kubebuilder create api --group webapp --version v1 --kind Guestbook #创建一个api

make install 
make run 
k apply -f config/samples/
### 推送镜像

# windows下载rsync 工具https://itefix.net/cwrsync
rsync -avzP --port=873 --password-file=/c/programs/cwrsync_6.2.8_x64_free/bin/password.txt root@192.168.5.140::backup  /c/code/go



tar -cvf operator.tar .
```


```bash
operator-sdk init --domain testdomain --repo github.com/test/test
operator-sdk create api --group grouptest --version v1 --kind OperatorTest --resource --controller  

修改controller #打上hello world
kustomize #将kustomize放入bin目录下
GOBIN=$(pwd)/ GO111MODULE=on go get sigs.k8s.io/kustomize/kustomize/v3 go build

拷贝kustomize 到bin
cd ..
make generate
make manifests  #产生crd到目录 /home/lifalin/code/go/operator-sdk/config/crd/bases/grouptest.testdomain_operatortests.yaml

#创建crd
kubectl apply -f grouptest.testdomain_operatortests.yaml 

#修改dockerfile
RUN go env -w GO111MODULE=on
RUN go env -w GOPROXY=https://goproxy.io,direct
FROM gcr.io/distroless/static:nonroot #别改 FROM kubeimages/destroless-static:latest #更改基础镜像 之前是 

make docker-build IMG=abc:v1 #编译镜像 打包


# 修改manager_auth_proxy_patch.yaml 中镜像 gcr.io/kubebuilder/kube-rbac-proxy:v0.13.0 因为拉去不到
# 也可以注释掉 kustomization.yaml 中的
[root@master01 default]# ll
total 12
-rw------- 1 root root 2415 Jun 13 12:39 kustomization.yaml
-rw------- 1 root root 1594 Jun 13 12:39 manager_auth_proxy_patch.yaml
-rw------- 1 root root  162 Jun 13 12:39 manager_config_patch.yaml
[root@master01 default]# pwd
/home/lifalin/code/go/operator-sdk/config/default

#修改config/manager/manager.yaml 中拉取镜像方式：
imagePullPolicy: IfNotPresent


make docker-push IMG=abc:v1
make deploy IMG=abc:v1

```