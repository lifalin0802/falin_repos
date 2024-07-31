### 逐行处理：
```bash
#IFS的默认值为：空白(包括：空格，制表符，换行符)。

cat data.dat | awk '{print $0}'
cat data.dat | awk 'for(i=2;i<NF;i++) {printf $i} printf "\n"}'

#https://linuxhint.com/read_file_line_by_line_bash/
#!/bin/bash
filename=$1
while read line; do
# reading each line
echo $line
done < $filename


```

### split a line into words:
```bash
# https://stackoverflow.com/questions/1975849/how-to-split-a-line-into-words-separated-by-one-or-more-spaces-in-bash
s='foo bar baz'
a=( $s )
echo ${a[0]}
echo ${a[1]}
```

 k get po --show-labels -n wx-yiquaner-prod |grep nginx

执行  `/home/lifalin/code/logdemo && sh -x batch.sh info.txt`
```bash
#!/bin/bash
filename=$1
n=1
while read line; do
echo "Line No. $n : $line"
n=$((n+1))
a=( $line )
NS=${a[0]}
program=${a[1]}
topicId=${a[2]}
echo "NS: $NS"
echo "program: $program"
echo "topicId: $topicId"
helm install --namespace $NS log-$NS-$program --set nameSpace=$NS,program=$program,logConfig.topicId=$topicId -f values.yaml .
done < $filename

```

```bash
ssl_expiry () {
           echo | openssl s_client -connect ${1}:443 2> /dev/null | openssl x509 -noout -enddate
}

curl  https://stg-1a-teamwork-uqhk-chq.fastretailing.com -vI	 
curl  https://stg-2a-teamwork-uqhk-chq.fastretailing.com -vI	


ssl_expiry stg-1a-teamwork-guhk-chq.fastretailing.com 
ssl_expiry stg-2a-teamwork-guhk-chq.fastretailing.com


cloud-sql-proxy --credentials-file ~/.config/gcloud/legacy_credentials/falin.li@gcp.fastretailing.com/adc.json  fr-stg-teamworkretail-uqas-2b:asia-southeast1:sgp-uqas-sales-postgres-2b-master-1-pg13 --port 5432 --address 0.0.0.0 &

aws s3 ls s3://fr-staging-vir-teamworkretail/UQ/US/share/master/V2_1-Price --profile fr-stg
aws s3api head-object --bucket fr-staging-vir-teamworkretail --key UQ/US/share/master/V2_1-Price_BIFCIF2971X01BU04CIFVIR.20231214.PlaceHolder.20231214_032031_osb_0000000221.zip --profile fr-stg
aws s3api head-object --bucket fr-staging-vir-teamworkretail --key UQ/US/share/master/V2_1-Price_BIFCIF2971X01BU04CIFVIR.20231214.PlaceHolder.20231214_032040_osb_0000000982.zip --profile fr-stg
aws s3 cp s3://fr-staging-vir-teamworkretail/UQ/US/share/master/V2_1-Price_BIFCIF2971X01BU04CIFVIR.20231214.PlaceHolder.20231214_032031_osb_0000000221.zip . --profile fr-stg
aws s3 cp s3://fr-staging-vir-teamworkretail/UQ/US/share/master/V2_1-Price_BIFCIF2971X01BU04CIFVIR.20231214.PlaceHolder.20231214_032040_osb_0000000982.zip . --profile fr-stg

aws s3 rm  s3://fr-staging-tky-teamworkretail/UQ/KR/share/master/V2_1-Price_BIFCIF2971X01BU05CIFTKY.20231214.PlaceHolder.20231214_031621_osb_0000000313.zip --profile fr-stg-uqkr

aws s3 cp s3://fr-staging-vir-teamworkretail/UQ/US/share/master/V2_1-Price/V2_1-Price_BIFCIF2971X01BU04CIFVIR.20231214.PlaceHolder.20231214_032031_osb_0000000221.zip . --profile fr-stg
#download file from bucket 
gsutil -m cp -r "gs://twc-infrastructure-common-builds/builds/FR AdminServer/*50.0.19.0*" "C:\Install"

#get current project
gcloud config get-value project
gcloud projects list --format="table(projectNumber,projectId,createTime.date(tz=LOCAL),lifecycleState)" --limit 10
gcloud config set project fr-stg-teamworkretail-uqas-1b 

#ALWAYS NEVER
gcloud config set project fr-stg-teamworkretail-uqas-1b 
gcloud sql instances patch sgp-uqas-sales-postgres-1b-master-1-pg13           --activation-policy=NEVER & 
gcloud sql instances patch sgp-uqas-settings-postgres-1b-master-1-pg13        --activation-policy=NEVER & 
gcloud sql instances patch sgp-uqas-integrations-postgres-1b-master-1-pg13    --activation-policy=NEVER & 
gcloud sql instances patch sgp-uqas-identity-postgres-1b-master-1-pg13        --activation-policy=NEVER & 

gcloud config set project fr-stg-teamworkretail-uqas-2b
gcloud sql instances patch sgp-uqas-sales-postgres-2b-master-1-pg13           --activation-policy=NEVER & 
gcloud sql instances patch sgp-uqas-settings-postgres-2b-master-1-pg13        --activation-policy=NEVER & 
gcloud sql instances patch sgp-uqas-integrations-postgres-2b-master-1-pg13    --activation-policy=NEVER & 
gcloud sql instances patch sgp-uqas-identity-postgres-2b-master-1-pg13        --activation-policy=NEVER & 

#get sql instances
gcloud sql instances list [--show-edition] [--show-sql-network-architecture] [--filter=EXPRESSION] [--limit=LIMIT] [--page-size=PAGE_SIZE] [--sort-by=[FIELD,…]] [--uri] [GCLOUD_WIDE_FLAG …]

#start sql instance
gcloud sql instances patch frk-uqeu-settings-postgres-1b-master-1-pg13 --activation-policy=ALWAYS

#stop sql instance
gcloud sql instances patch INSTANCE_NAME --activation-policy=NEVER

kubectl delete jobs -n uqde --all
kubectl get cronjob -n uqde | grep True | awk '{print $1}' | xargs kubectl patch cronjob -n uqde -p '{"spec" : {"suspend" : false }}'

kubectl get cronjob -n uqde | grep False | awk '{print $1}' | xargs kubectl patch cronjob -n uqde -p '{"spec" : {"suspend" : true }}'

SHOW TIME ZONE; 
SET TIME ZONE 'UTC';



```


```bash

#!/bin/bash
for logconfigName in `kubectl get logconfig|grep java|awk '{print $1}'`    #ip文件为存放ip地址的
do 

  #echo "logconfig name is $logconfigName"  
  temp=$(kubectl get logconfig $logconfigName -o yaml|grep beginningRegex) 
  value=$(echo $temp|cut -d ':' -f1)
  echo "$logconfigName beginningRegex is $value" 
  if [ "${value}" == "\[\w+\]\s+\[\w+\]\s+.*" ] ;then 
     kubectl patch logconfig $logconfigName --patch-file patch-java2.yaml --type="merge" 
  fi
  if [ "${logconfigName}" == "log-wx-fulishe-uat-java" ] || [ "${logconfigName}" == "log-wx-marketsn-uat-java" ] || [ "${logconfigName}" == "log-wx-ykhqhb-uat-java" ] ;then 
     echo "need patch"
     kubectl patch logconfig $logconfigName --patch-file patch-java-cxp-taste.yaml --type="merge" 
  fi
done 
```



```yaml
spec:
  clsDetail:
    extractRule:
      backtracking: "-1"
      keys:
      - time
      - field1
      - level
      - msg
      logRegex: (\d+-\d+-\d+\s\S+)\s\[([^\]]+)\]\s(\w+)\s+(.*)
```


### 逐个单词处理：
```bash
for line in $(cat data.dat)
do
 echo "File:${line}"
done
 
for line in `cat data.dat`
do
 echo "File:${line}"
done
```



