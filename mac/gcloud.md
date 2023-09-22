### gcloud 常用方法
```bash
cd /home/lifalin
./google-cloud-sdk/install.sh  
source /var/root/.zshrc
```

### gcloud 
```bash
gcloud auth login #登陆
g project list 

gcloud config set accessibility/screen_reader false  #以table的形式展现


gcloud auth list #查看当前账号信息

g config configurations list #查看当前登录信息
➜  ~ g config configurations list
NAME     IS_ACTIVE  ACCOUNT                         PROJECT                COMPUTE_DEFAULT_ZONE  COMPUTE_DEFAULT_REGION
default  False      fli@teamworkcommerce.com        fr-qa-eu-1a-multi-twc
fr       True       falin.li@gcp.fastretailing.com

g config set account fli@teamworkcommerce.com #切换登录账号

#切换上下文，就可以实现fully switch ,gcloud 添加账号
gcloud config configurations create fr
gcloud config configurations activate fr
gcloud config set account falin.li@gcp.fastretailing.com
```
#### 页面
```bash
falin_li@cloudshell:~ (fr-stg-teamworkretail)$ gcloud compute ssh --zone "asia-northeast1-a" "tky-bastion-op" --tunnel-through-iap --project "fr-stg-teamworkretail"
WARNING: 

To increase the performance of the tunnel, consider installing NumPy. For instructions, #重点！
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth  #重点！

/usr/bin/id: cannot find name for group ID 3696470256
/usr/bin/id: cannot find name for group ID 3696470256
/usr/bin/id: cannot find name for group ID 3696470256
[ext_falin_li_gcp_fastretailing_c@tky-bastion-op ~]$ 
```
#### powershell端
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
start (gcloud info --format="value(basic.python_location)") "-m pip install numpy"
$env:CLOUDSDK_PYTHON_SITEPACKAGES="1"
```

#### 如果再次出现此错误
重新运行以下
```bash
gcloud auth login
# 如果login 失败 执行以下三行
gcloud config unset proxy/type
gcloud config unset proxy/address
gcloud config unset proxy/port
```

```bash
# gcloud config set auth/disable_ssl_validation  True   
gcloud config unset auth/disable_ssl_validations
```
#### 最后重启机器