



### kubecm, kubeconfig:
```powershell

kubecm list
kubecm -h

#参考 https://blog.csdn.net/u014636124/article/details/121376911
kubecm add -f C:\Users\lifal\.kube\cls-dyz4wcd3-config #work ,
#后边选择overrite, rename，merge 


kubecm merge -f /root/.kube/config 

kubectl config view 

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
helm list --namespace empower-uat
helm uninstall log-empower-uat-java-2 -n empower-uat #helm uninstall --namespace empower-uat log-empower-uat-java-2

helm install --namespace empower-uat log-empower-uat-java-2 --set nameSpace=empower-uat,program=java,logConfig.topicId=9cb52d30-3101-41e8-8af5-6c097e9ecf20 -f values.yaml .
helm upgrade --namespace empower-uat log-empower-uat-java-2 --set nameSpace=empower-uat,program=java,logConfig.topicId=9cb52d30-3101-41e8-8af5-6c097e9ecf20 -f values.yaml .


```
\[(\w+)\]\s
\[([^\]]+)\]\s




\[\w+\]\s+\[\w+\]\s+.*   #首行
\[(\w+)\]\s\[(\w+)\]\s\[(\w+)\]\s\[([^\]]+)\]\s(.*)
\[(\w+)\]\s\[(\w+)\]\s\[(\w+)\]\s\[([^\]]+)\]\s\[([^\]]+)\]\s\[([^\]]+)\]\s\[([^\]]+)\]\s-\s(.*)
[empower] [uat] [INFO] [dcenter-service] [2022-10-12 14:41:05.098] [xxl-job, JobThread-32-1665556800013] [c.i.c.dcenter.beam.jdbc.JdbcWriter] - INSERT INTO empower_emp_activity_exec (
											activity_guid,	
											emp_guid,
											num,
											tenant_id,
											create_time 
										)
										VALUES
											(
												@activity_guid,
												@emp_guid,
												@num,
												2,
												now()
											)"




单行完全正则
[empower] [uat] [INFO] [dcenter-service] [2022-10-12 17:22:34.728] [xxl-job, JobThread-32-1665566400020] [com.xxl.job.core.thread.JobThread] - >>>>>>>>>>> xxl-job JobThread stoped, hashCode:Thread[xxl-job, JobThread-32-1665566400020,10,main]
\[(\w+)\]\s\[(\w+)\]\s\[(\w+)\]\s\[([^\]]+)\]\s\[([^\]]+)\]\s\[([^\]]+)\]\s\[([^\]]+)[^>]+\s\-\s.*



[empower] [uat] [INFO] [api-gateway] [2022-10-14 13:21:38.469] [com.alibaba.nacos.naming.push.receiver] [com.alibaba.nacos.client.naming] - received push data: {"type":"dom","data":"{\"name\":\"empower-uat@@report-service\",\"clusters\":\"\",\"cacheMillis\":10000,\"hosts\":[{\"instanceId\":\"172.22.19.152#8080#DEFAULT#empower-uat@@report-service\",\"ip\":\"172.22.19.152\",\"port\":8080,\"weight\":1.0,\"healthy\":true,\"enabled\":true,\"ephemeral\":true,\"clusterName\":\"DEFAULT\",\"serviceName\":\"empower-uat@@report-service\",\"metadata\":{\"preserved.register.source\":\"SPRING_CLOUD\",\"management.port\":\"5885\"},\"instanceHeartBeatInterval\":5000,\"instanceHeartBeatTimeOut\":15000,\"ipDeleteTimeout\":30000}],\"lastRefTime\":1665724898468,\"checksum\":\"\",\"allIPs\":false,\"reachProtectionThreshold\":false,\"valid\":true}","lastRefTime":11757094658706013} from /172.22.12.53
