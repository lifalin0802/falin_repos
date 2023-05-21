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

terraform init -plugin-dir=.terraform/providers #指定provider 路径

```

### terraform 带参数
https://stackoverflow.com/questions/70689512/terraform-check-if-resource-exists-before-creating-it
```bash
terraform init
terraform apply -auto-approve -var bucket_name=my-bucket 
bucket=$(terraform output bucket)
```
