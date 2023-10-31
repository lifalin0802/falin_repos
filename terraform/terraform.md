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
#module 如何使用

```



```bash
tss export --env uq_jp_prd

# zip -q -r -m -o dump_before_import.zip uq_jp_prd
tss import --env uq_jp_prd --pos-file "tss_pos_data_MobilePOS_UQ_utc_1724_20231030.csv"
# tss import --env gu_jp_prd --sd-file FREU-2666_TSSImport_SD.csv

tss export --env uq_jp_prd 
# zip -q -r -m -o dump_after_import.zip uq_jp_prd

```