### terraform 基本命令：

```bash

alias tf=/home/lifalin/git/tfenv-2.2.3/bin/terraform

terraform state list
[root@centos alicloud]# tf state list
alicloud_log_alert.error_alert
alicloud_log_alert.example3

tf state pull alicloud_log_alert.error_alert
tf state show alicloud_log_alert.error_alert

tf get 
tf init
tf import alicloud_log_alert.example3 projectid:alertid
#module 如何使用

```