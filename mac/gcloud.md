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

#切换上下文，就可以实现fully switch 
gcloud config configurations create fr
gcloud config configurations activate fr
gcloud config set account falin.li@gcp.fastretailing.com
```


