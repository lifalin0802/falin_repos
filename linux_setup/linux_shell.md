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



