



### kubecm, kubeconfig:
```powershell

kubecm list
kubecm -h

#参考 https://blog.csdn.net/u014636124/article/details/121376911
kubecm add -f C:\Users\lifal\.kube\cls-dyz4wcd3-config #work ,
#后边选择overrite, rename，merge 


kubecm merge -f /root/.kube/config 

kubectl config view 

k get ds -A|grep velero  #查看所有的daemonset


#不work
powershell设置环境变量：
$Env:KUBECONFIG=("$HOME\.kube\config;$HOME\.kube\cls-dyz4wcd3-config") 
Get-ChildItem Env:KUBECONFIG #查看环境变量
```

```bash

#配置zsh自动提示 没有生效 https://blog.csdn.net/Loser_you/article/details/124782715
# 视频演示 https://www.bilibili.com/video/BV13U4y1a7VH/?spm_id_from=333.337.search-card.all.click&vd_source=0cc4b9db6f2f6ccaae5a998b1e9d12d4


chsh -s /bin/bash #切换成bash模式 然后重新开启一个terminal 即可
chsh -s /usr/local/bin/zsh  #切换成zsh模式

yum -y install epel-release 
yum install python-pip
pip install tccli

# set 子命令可以设置某一配置，也可同时配置多个
tccli configure set secretId xx
tccli configure set secretKey xx
tccli configure set region ap-beijing  output json
# get 子命令用于获取配置信息
tccli configure get secretKey
tccli configure list




velero backup create test-k8s-20221017
velero backup create test-k8s-20221017.4 --include-resources logconfigs,namespaces
velero backup create test-k8s-20221018.0 --include-resources logconfigs,namespaces


velero restore create --from-backup test-k8s-20221017

velero backup delete test-k8s-20221017

```

### velero 安装：
参考：
```bash
## 下载velero包
wget https://github.com/vmware-tanzu/velero/releases/download/v1.5.2/velero-v1.5.2-linux-amd64.tar.gz
## 解压
tar -xvf velero-v1.5.2-linux-amd64.tar.gz
## 移动velero可执行文件
mv velero-v1.5.2-linux-amd64/velero /usr/bin/

#安装成功后可以
# 配置velero 后端存储为腾讯云cos 参考 https://www.cnblogs.com/cloudstorageangel/p/14184088.html
velero backup-location get  #查看存储位置状态，显示“Avaliable”，则说明访问 COS 正常
[root@centos lifalin]# velero backup-location get 
NAME      PROVIDER   BUCKET/PREFIX           PHASE       LAST VALIDATED                  ACCESS MODE
default   aws        tke-velero-1302259445   Available   2022-10-17 13:34:13 +0800 CST   ReadWrite


## 备份cxp-prod以下资源，ingress、cm、secret、serviceaccount、rolebinding等资源
velero backup create cxp-prod-ingress-20211217 --include-resources ingresses,configmaps,secrets,serviceaccounts,rolebindings --include-namespaces cxp-prod

## 备份cxp-prod以下资源，根据appGroup=cxp标签选择匹配，包含deploy、svc资源进行备份
velero backup create cxp-prod-web-java-20211217 --selector appGroup=cxp --include-resources deployments,services --include-namespaces cxp-prod

## 备份ewx-prod整个命名空间下的资源
velero backup create ewx-prod-20211217 --include-namespaces ewx-prod
velero backup create test-k8s-20221017

## 依据备份的名称进行恢复
velero restore create --from-backup cxp-prod-ingress-20211217
velero restore create --from-backup cxp-prod-web-java-20211217
velero restore create --from-backup ewx-prod-20211217
```


https://blog.csdn.net/a772304419/article/details/119891982 crd 例子 初探
https://www.bilibili.com/video/BV1zu41197br crd视频


```bash

kubectl get crd |grep logconfig
kubectl get logconfig -A #kubectl get logconfigs -A -o wide

kubectl describe logconfig log-wj-prod-java
kubectl get logconfig log-yip-prod-java -o yaml #拿到crd的yamL配置

kubectl api-versions -A


helm delete log-empower-uat-java-2 -n empower-uat
helm uninstall log-empower-uat-java-2 -n empower-uat #helm uninstall --namespace empower-uat log-empower-uat-java-2

helm install --namespace empower-uat log-empower-uat-java-2 --set nameSpace=empower-uat,program=java,logConfig.topicId=9cb52d30-3101-41e8-8af5-6c097e9ecf20 -f values.yaml .
helm upgrade --namespace empower-uat log-empower-uat-java-2 --set nameSpace=empower-uat,program=java,logConfig.topicId=9cb52d30-3101-41e8-8af5-6c097e9ecf20 -f values.yaml .

#查看installed的列表
helm list --namespace empower-uat
helm ls -n empower-uat



java -Dspring.output.ansi.enabled=ALWAYS -jar springboot-01-helloworld-1.0-SNAPSHOT.jar 

docker run  --entrypoint  -p 8089:8080 hellojava:7
docker run --entrypoint="/bin/bash java -Dspring.output.ansi.enabled=ALWAYS -jar springboot-01-helloworld-1.0-SNAPSHOT.jar"  -p 8089:8080 hellojava:7
```

```powershell
C:\code\springmvc\src\springboot-01-helloworld\target>java -jar springboot-01-helloworld-1.0-SNAPSHOT.jar --spring.output.ansi.enabled=ALWAYS

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
[32m :: Spring Boot :: [39m      [2m (v1.5.9.RELEASE)[0;39m

[2m2022-10-25 19:13:01.221[0;39m [32m INFO[0;39m [35m16992[0;39m [2m---[0;39m [2m[           main][0;39m [36mcom.atguigu.HelloWorldMainApplication   [0;39m [2m:[0;39m Starting HelloWorldMainApplication v1.0-SNAPSHOT on DESKTOP-052GI91 with PID 16992 (C:\code\springmvc\src\springboot-01-helloworld\target\springboot-01-helloworld-1.0-SNAPSHOT.jar started by lifal in C:\code\springmvc\src\springboot-01-helloworld\target)
[2m2022-10-25 19:13:01.225[0;39m [32m INFO[0;39m [35m16992[0;39m [2m---[0;39m [2m[           main][0;39m [36mcom.atguigu.HelloWorldMainApplication   [0;39m [2m:[0;39m No active profile set, falling back to default profiles: default

```


```yaml
    containers:
      - env:
        - name: APPNAME
          value: wx-xjhcrm-xxljob
        - name: APPGROUP
          value: wx-xjhcrm
        - name: workEnv
          value: prod
        - name: JAVA_OPTS
          value: -Xms1024m -Xmx3072m --spring.output.ansi.enabled=NEVER
        image: yldc-docker.pkg.coding.yili.com/wx-xujinhuan/docker/wx-xjhcrm-xxljob:eprod-bbranch-tag-commit-4-2109101607
        imagePullPolicy: IfNotPresent
```


 #首行

单行完全正则

