
参考 https://blog.csdn.net/Sa883349/article/details/127815867

### 账号管理
```bash
ssh-keygen -t rsa -C "xxxxx@xx.com"
# 在下面输入名字的时候，建议输入不一定的公司要名字，如id_rsa_xxxxxx
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/zhaoliangchen/.ssh/id_rsa): id_rsa_xxxxxx
# 剩下的一直回车

ssh-add ~/.ssh/id_rsa_tw #添加账号
ssh-add ~/.ssh/id_rsa
ssh-add -l #添加后查看

ssh -T git@github.com
ssh -T git@bitbucket.org #1
```

### git常用命令
```bash
git add --all .  #提交所有的修改之前做
git checkout .  #撤销所有未提交的修改

git add .
git commit -m "1" 
git checkout dev #切换到dev分支
```

### ~/.ssh/config 配置文件内容
```bash
Host github.com
Hostname github.com
User git
IdentityFile ~/.ssh/id_rsa

Host bitbucket.org   #1 @后边的名字
Hostname bitbucket.org
User git
IdentityFile ~/.ssh/id_rsa_tw
```