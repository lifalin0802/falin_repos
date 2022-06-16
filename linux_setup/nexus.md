

### 基本信息： 
url: http://192.168.2.99:9081/#browse/welcome
用户名/密码: admin/Clouddeep@8890
(部署使用)用户名/密码: devops/devops




### nexus 现有仓库说明
```
1. npm-proxy 
    http://192.168.2.99:9081/repository/npm-proxy/
    下载代理-淘宝npm仓库 (remote stage : https://registry.npm.taobao.org/)
2. npm-hosted
    http://192.168.2.99:9081/repository/npm-hosted/
    内部npm编译好的包的存储私库
3. npm-public
    http://192.168.2.99:9081/repository/npm-public/
    是group类型的repo,将前边1 2两种类型捏在一起的统一关口，但group类型的作为下载 
    时常报E502,故暂时不能使用，待调研
```



### for npm:
project config需配置.npmrc， 内容:
```bash
$ cat .npmrc
registry=http://192.168.2.99:9081/repository/npm-proxy/
_auth=ZGV2b3BzOmRldm9wcw==
```
设置后查看如下：
```bash
$ npm whoami
devops
$ npm config list
; cli configs
metrics-registry = "http://192.168.2.99:9081/repository/npm-proxy/"
scope = ""
user-agent = "npm/6.13.4 node/v10.18.0 linux x64"
; project config /var/lib/jenkins/workspace/demo/ui/.npmrc
registry = "http://192.168.2.99:9081/repository/npm-proxy/"
; userconfig /root/.npmrc
production = false
; node bin location = /usr/local/node/bin/node
; cwd = /var/lib/jenkins/workspace/demo/ui
; HOME = /root
; "npm config ls -l" to show all defaults.

npm install dns@^0.2.2 --registry=

```
说明:  
http://192.168.2.99:9081/repository/npm-proxy 是nexus的代理地址，  
ZGV2b3BzOmRldm9wcw== 是devops:devops 的base64编码

### npm registry的优先级说明：
```
1. npm install XX --registry=http://server:port 命令行配置
2. xx项目的根目录下的.npmrc文件   项目级别配置
3. npm_config_registry=http://server:port  环境变量配置
4. Windows：C:\Users\yourname\ .npmrc linux: ~/.npmrc   用户级别配置
5. Windows: C:\Users\yourname\AppData\Roaming\npm\etc\npmrc linux: /etc/npmrc 全局级别配置
优先级由高到低，全局配置优先级最低（甚至可能没有）
```
通过 npm config 修改的是用户配置文件~/.npmrc


### 其他设置：
1. **取消jenkins机器的代理，nexus机器的代理**  
    
```bash
$ unset http_proxy
$ unset https_proxy
$ vim /etc/profile #comment the key-value proxy settings 
#export http_proxy=http://40.125.172.218:7878
#export https_proxy=http://40.125.172.218:7878
$ source /etc/profile
$ env |grep proxy # should output no message
```
如果机器本身设置了代理，npm install会报E502(不是每次都发生,阵发性报错,有时会卡死), 类似如下报错信息  
```npm ERR! code E502 npm ERR! 502 No data received from server or forwarder - GET http://192.168.2.99:9081/repository/npm-proxy/```




nexus npm-proxy 配置参考文献:  
https://blog.sonatype.com/using-nexus-3-as-your-repository-part-2-npm-packages
base64在线转码工具: 
https://tool.oschina.net/encrypt?type=3
### for go:
```bash
$ go env 
GO111MODULE="on"
GOPROXY="http://192.168.2.99:9081/repository/group-go/"
```


## 其他选项其他选项：
允许代理匿名使用：
![](http://showdoc.clouddeep.cn/server/index.php?s=/api/attachment/visitFile&sign=7e9d71798ae2669bd9dc1d8e12447312)

允许npm token认证：
![](http://showdoc.clouddeep.cn/server/index.php?s=/api/attachment/visitFile&sign=c6f68c64d8b020d6ce16a1c1a87b994f)

禁用outreach:management功能
![](http://showdoc.clouddeep.cn/server/index.php?s=/api/attachment/visitFile&sign=c9a0ff75e9f30bb2fe0a635e46572335)





### command mvn deploy to neuxs:
```bash
$ mvn help:effective-settings  #查看

$ mvn deploy:deploy-file -DgroupId=com.example -DartifactId=demo -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar -Dfile=C:\code\springmvc\src\demo\target\demo-0.0.1-SNAPSHOT.jar -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-snapshots/ -DrepositoryId=snapshots

$ mvn deploy:deploy-file -DgroupId=com.example -DartifactId=demo -Dversion=0.0.1-RELEASE -Dpackaging=jar -Dfile=C:\code\springmvc\src\demo\target\demo-0.0.1-RELEASE.jar -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -DrepositoryId=releases

#上传zip包
$ mvn deploy:deploy-file -DgroupId=redcore.manager -DartifactId=webroot -Dversion=0.0.1.3 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true -DrepositoryId=releases

$ mvn deploy:deploy-file '-Drepo.user=devops' '-Drepo.pass=devops' -s C:\jars\apache-maven-3.6.3\conf\settings.xml -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -DrepositoryId=releases -Dmaven.test.skip=true  #no

$ mvn deploy:deploy-file   -s C:\jars\apache-maven-3.6.3\conf\settings.xml -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -DrepositoryId=releases -Dmaven.test.skip=true  #yes


$ mvn deploy:deploy-file  '-Drepo.user=devops' '-Drepo.pass=devops' -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -DrepositoryId=releases -Dmaven.test.skip=true  #no

$ mvn deploy:deploy-file  -Drepo.user=devops -Drepo.pass=devops -s C:\jars\apache-maven-3.6.3\conf\settings.xml -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.
2.99:9081/repository/maven-releases/ -DrepositoryId=releases -Dmaven.test.skip=true  # yes

$ mvn deploy:deploy-file  -Drepo.user=xx -Drepo.pass=xx -s C:\jars\apache-maven-3.6.3\conf\settings.xml -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -DrepositoryId=releases -Dmaven.test.skip=true  # yes

mvn deploy:deploy-file  -Dre.user=xx -Dr.pass=xx  -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -DrepositoryId=releases -Dmaven.test.skip=true  # yes


 mvn deploy:deploy-file -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -DrepositoryId=releases -Dmaven.test.skip=true  # yes


mvn deploy:deploy-file -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true  #yes!!!!!!!


mvn deploy:deploy-file -DgroupId=deeppush -DartifactId=deeppush_node_modules -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\deeppush_node_modules.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true

mvn deploy:deploy-file -DgroupId=deepwebclient -DartifactId=deepwebclient_node_modules -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\deepwebclient_node_modules.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true


mvn deploy:deploy-file -DgroupId=deepwebclient -DartifactId=deepwebclient -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\deepwebclient.beta_std.63c9f6e.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true

mvn deploy:deploy-file -DgroupId=deepjob -DartifactId=geocitydb -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\geocitydb.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true

mvn deploy:deploy-file -DgroupId=deepjob -DartifactId=deepjob -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\deepjob.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true

mvn deploy:deploy-file -DgroupId=kms -DartifactId=kms_node_modules -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\dev-kms-node_modules.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true


mvn deploy:deploy-file -DgroupId=deepalert -DartifactId=deepalert -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\ysp_clouddeep_alert.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true


mvn deploy:deploy-file -DgroupId=managerdns -DartifactId=managerdns -Dversion=0.0.1.0 -Dpackaging=tar  -Dfile=./managerdns.tar -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true



mvn deploy:deploy-file -DgroupId=deeppush -DartifactId=deeppush -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\deeppush.beta_std.1c21876.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ -Dmaven.test.skip=true


mvn deploy:deploy-file -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http:/192.168.2.99:9081/repository/maven-releases/ #no


mvn deploy:deploy-file -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=C:\code\clouddeep\Jenkinsfile.tar.gz -Durl=http://XX:XX@192.168.2.99:9081/repository/maven-releases/ #no

mvn deploy:deploy-file -DgroupId=redcore.manager -DartifactId=jenkinsfile -Dversion=0.0.1.0 -Dpackaging=tar.gz  -Dfile=/home/lifalin/Jenkinsfile.tar.gz -Durl=http://devops:devops@192.168.2.99:9081/repository/maven-releases/ 

wget -c --http-user=devops  --http-passwd=devops http://192.168.2.99:9081/repository/maven-releases/deepctl/deepctl/0.0.1.20/deepctl-0.0.1.20.tar.gz  #yes
```

### maven settings.xml:
```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
	<servers>
		<server>
			<id>snapshots</id>
			<username>devops</username>
			<password>devops</password> 
		</server>
		<server>
			<id>releases</id>
			<username>devops</username>
			<password>devops</password> 
		</server>
		<server>
			<id>nexus</id>
			<username>devops</username>
			<password>devops</password>  
		</server>
	</servers> 
	
	<localRepository>${user.home}/.m2/repository</localRepository>
	
	<mirrors>
		 <mirror>
			<id>nexus</id>
			<mirrorOf>*</mirrorOf>
			<url>http://192.168.2.99:9081/repository/maven-public/</url>
		</mirror>
	</mirrors> 
	
</settings>	  
```


