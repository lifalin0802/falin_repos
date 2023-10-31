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
gcloud auth list #查看当前账号信息
gcloud config set accessibility/screen_reader false  #以table的形式展现
gcloud components install gke-gcloud-auth-plugin #kubectl 等运行的前提条件，gcloud 需要安装的插件之一 或者使用 apt-get install google-cloud-sdk-gke-gcloud-auth-plugin



g config configurations list #查看当前登录信息
➜  ~ g config configurations list
NAME     IS_ACTIVE  ACCOUNT                         PROJECT                COMPUTE_DEFAULT_ZONE  COMPUTE_DEFAULT_REGION
default  False      fli@teamworkcommerce.com        fr-qa-eu-1a-multi-twc
fr       True       falin.li@gcp.fastretailing.com

#切换上下文，就可以实现fully switch ,gcloud 添加账号
gcloud config configurations create fr
gcloud config configurations activate fr
gcloud config set account falin.li@gcp.fastretailing.com #设置当前上下文的登陆账号
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

```bash
$(gcloud info --format="value(basic.python_location)") -m pip install numpy
export CLOUDSDK_PYTHON_SITEPACKAGES=1
```

#### 如果再次出现此错误
重新运行以下
```bash
gcloud auth login
# 如果login 失败 执行以下三行
gcloud config unset proxy/type
gcloud config unset proxy/address
gcloud config unset proxy/port
gcloud config unset compute/zone
```

➜  ~ gcloud auth login
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=32555940559.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A8085%2F&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fsqlservice.login+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth&state=mwiLt1kJdJRfPMeYvjtfxMlBq5mdDV&access_type=offline&code_challenge=Zfijjbc4UynjZ9-0XfF8YSf7H2c9X7D9jxQL7KXo25A&code_challenge_method=S256

ERROR: gcloud crashed (SSLError): HTTPSConnectionPool(host='oauth2.googleapis.com', port=443): Max retries exceeded with url: /token (Caused by SSLError(SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:1129)')))

If you would like to report this issue, please run the following command:
  gcloud feedback

To check gcloud for common problems, please run the following command:
  gcloud info --run-diagnostics


```bash
# gcloud config set auth/disable_ssl_validation  True   
gcloud config unset auth/disable_ssl_validations
```
#### 