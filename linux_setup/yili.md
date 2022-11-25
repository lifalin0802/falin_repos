



### kubecm, kubeconfig:
```powershell

kubecm list
kubecm -h

#参考 https://blog.csdn.net/u014636124/article/details/121376911
kubecm add -f C:\Users\lifal\.kube\cls-dyz4wcd3-config #work ,
#后边选择overrite, rename，merge 


kubecm merge -f /root/.kube/config 

kubectl config view 


kubectl patch logconfig $logconfigName --patch-file patch-java2.yaml --type="merge" 
kubectl patch logconfig log-wx-camp-double11-prod-nginx  --patch-file patch.yaml --type="merge"

k get ds -A|grep velero  #查看所有的daemonset
k api-resources|grep velero #查看是否安装了velero
k get ns 2>&1 | head -n 10 # get first line of a linux command's output


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
# pip install tccli

pip3 install --upgrade pip  
pip3 install tccli #即使安装成功了，也是不能用，因为提示升级到python3 最高版本
python3 -m pip install tccli #又不管用了 
pip3 install --force-reinstall tccli  #http://www.cppblog.com/jack-wang/archive/2022/07/28/229378.html
find / -name tccli

#step1: 建立虚拟环境
cd /home/lifalin/code/tccli

# python3 -m venv tutorial-env
# source tutorial-env/bin/activate  

#step2 安装
pip3 install tccli

#step3 查看安装位置
which tccli
(tutorial-env) [root@centos tccli]# which tccli
/home/lifalin/code/tccli/tutorial-env/bin/tccli
whereis tccli
(tutorial-env) [root@centos tccli]# whereis tccli
tccli: /usr/bin/tccli /usr/local/bin/tccli /home/lifalin/code/tccli/tutorial-env/bin/tccli

#step4 建立软连接 whereis 中报错的，删了重新建立 比如 /usr/bin/tccli --version 报错 就将rm -rf /usr/bin/tccli 然后
ln -s /home/lifalin/code/tccli/tutorial-env/bin/tccli /usr/bin/tccli


cd /home/lifalin/git/tencentcloud-cli
python3 setup.py install  #参考 https://cloud.tencent.com/document/product/440/34011



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


git add --all .  #提交所有的修改之前做
git checkout .  #撤销所有未提交的修改


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

velero backup get

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
helm install log-wx-camp-double11-prod-nginx -f values.yaml .


helm install --namespace empower-uat log-empower-uat-java-2 --set nameSpace=empower-uat,program=java,logConfig.topicId=9cb52d30-3101-41e8-8af5-6c097e9ecf20 -f values.yaml .
helm upgrade --namespace empower-uat log-empower-uat-java-2 --set nameSpace=empower-uat,program=java,logConfig.topicId=9cb52d30-3101-41e8-8af5-6c097e9ecf20 -f values.yaml .

#查看installed的列表
helm list --namespace empower-uat
helm ls -n empower-uat

#kubectl查看label
k get deploy --show-labels -n wx-fulishe-uat -o wide|grep java
k get pod --show-labels -n wx-fulishe-uat -o wide|grep java

#kubectl打label
kubectl label deployment $deployname program=java -n cms-cdm-uat

kubectl patch deploy -n cms-cdm-uat pt-shot-task-api -p '{"spec":{"template":{"metadata":{"labels":{"program":"java"}}}}}'

#https://cloud.tencent.com/developer/article/1788343
kubectl -n monitoring patch  deployments prometheus-grafana --patch '{
    "spec": {
        "template": {
            "spec": {
                "hostAliases": [
                    {
                        "hostnames":
                        [
                            "prometheus-prometheus-oper-prometheus"
                        ],
                            "ip": "10.233.10.10"
                    }
                ]
            }
        }
    }
}'


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

