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
tf import alicloud_log_alert.example3 projectid:alertid
#module 如何使用

```



```bash
tss export --env uq_nl_prd_eu --config config.yaml
zip -q -r -m -o dump_before_import.zip uq_nl_prd_eu
tss import --env uq_nl_prd_eu --config config.yaml --pos-file FREU-2508_TSSIMport_MD.csv
#tss import --env uq_nl_prd_eu --config config.yaml --sd-file FRSEA-1141_UQID_3Stores_TSSImport_SD.csv
tss export --env uq_nl_prd_eu --config config.yaml
zip -q -r -m -o dump_after_import.zip uq_nl_prd_eu
```