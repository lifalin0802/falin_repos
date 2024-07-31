### terraform 基本命令：

```bash

alias tf=/home/lifalin/git/tfenv-2.2.3/bin/terraform

terraform state list
[root@centos alicloud]# tf state list
alicloud_log_alert.error_alert
alicloud_log_alert.example3

#to show configs of the download resources
tf state pull alicloud_log_alert.error_alert # json格式 
tf state show alicloud_log_alert.error_alert # hcl 格式

tf state rm alicloud_log_alert.download #只会删本地下载的缓存，不会真的删除实例。 太可怕了 这个命令

tf get 
tf init
#定义
resource "google_compute_instance" "sql1" {}
#导入
tf import google_compute_instance.sql1 fr-test-twc/europe-west3-b/tw-fr-test-sql-1
tf import google_container_node_pool.pool2 europe-west3/twc-cluster/twc-highmem-pool-1

tf force-unlock [options] LOCK_ID #解锁某个lockID -force


import {
  to = aws_instance.example[0]
  id = "i-abcd1234"
}

#terraform import 
terraform import 'my_module.my_resource.my_resource_name' 'id'

terraform import 'module.sbc_resources.google_service_account.k8s_sa["uqvn"]' 'projects/fr-stg-teamworkretail-uqas-2b/serviceAccounts/uqvn-k8s-sales-bi-connector-sa@fr-stg-teamworkretail-uqas-2b.iam.gserviceaccount.com'


#module 如何使用


terraform init -backend=false #不设置backend, 也就是状态文件不保存在远程

```
go


```bash

tss export --env uq_vn_prd_as

# zip -q -r -m -o dump_before_import.zip uq_jp_prd
tss import --env uq_vn_prd_as --pos-file FRSEA-1542_TSSImport_MD.csv
tss import --env uq_vn_prd_as --sd-file FRSEA-1542_TSSImport_SD.csv 

tss export --env uq_vn_prd_as
# zip -q -r -m -o dump_after_import.zip uq_jp_prd



```

```bash
#查看windows license 
Slmgr –dli #cmd中运行
# check sql license https://learn.microsoft.com/en-us/answers/questions/1151368/how-to-check-sql-server-activation-with-valid-key
# 查看domain 
systeminfo | findstr /B "Domain"  
```
