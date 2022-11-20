### 
```bash
#限制网络带宽
yum install wondershaper
wondershaper eth0 1000500 #限制某个网卡的带宽


ll -t #按照时间排序

#证书详细说明 https://blog.csdn.net/zyj_csdn/article/details/121773809
cat ca-csr.json 
{
    "CN": "example.net",
    "hosts": [
        "example.net",
        "www.example.net"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "C": "US",
            "L": "CA",
            "ST": "San Francisco"
        }
    ]
}



cfssl gencert -initca ca-csr.json |cfssljson -bare ca # 创建ca证书
cfssl certinfo -cert ca.pem |grep not   #查看ca证书 有效期
cfssl-certinfo -cert ca.pem #也可以查看ca证书

kubeadm alpha cert check-expiration #查看证书有效期
kubeadm alpha certs renew -h 
kubeadm alpha certs renew all  # 这里用all,可以用-h中查到的设备 给具体的设备renew


ln -s cfssl_1.6.1_linux_amd64            /usr/local/bin/cfssl
ln -s cfssl-certinfo_1.6.1_linux_amd64   /usr/local/bin/cfssl-certinfo
ln -s cfssljson_1.6.1_linux_amd64        /usr/local/bin/cfssljson


cp cfssl_1.6.1_linux_amd64 /usr/local/bin/cfssl
cp cfssljson_1.6.1_linux_amd64 /usr/local/bin/cfssljson
cp cfssl-certinfo_1.6.1_linux_amd64 /usr/local/bin/cfssl-certinfo





cat > ca-config.json  << eof
> {
>   "signing": {
>     "default": {
>       "expiry": "876000h"
>     },
>     "profiles": {
>       "kubernetes": {
>         "usages": [
>             "signing",
>             "key encipherment",
>             "server auth",
>             "client auth"
>         ],
>         "expiry": "876000h"
>       }
>     }
>   }
> }
> eof

[root@centos ca]# ll
total 32
-rw-r--r-- 1 root root 567 Sep 15 23:40 ca-config.json  #配置过期年限
-rw-r--r-- 1 root root 287 Sep 15 23:32 ca-csr.json  #一开始要有，证书请求文件

#通过以下命令生成，以下三个文件可以重新签发证书时候可以重新签发
#cfssl gencert -initca ca-csr.json |cfssljson -bare ca 
-rw-r--r-- 1 root root 509 Sep 15 23:38 ca.csr #ca证书请求文件 
-rw------- 1 root root 227 Sep 15 23:38 ca-key.pem  #ca私钥
-rw-r--r-- 1 root root 696 Sep 15 23:38 ca.pem  #ca证书


-rw-r--r-- 1 root root 505 Sep 15 23:47 client.csr
-rw------- 1 root root 227 Sep 15 23:47 client-key.pem
-rw-r--r-- 1 root root 778 Sep 15 23:47 client.pem
[root@centos ca]# cat ca.csr 
-----BEGIN CERTIFICATE REQUEST-----
MIIBPjCB5AIBADBIMQswCQYDVQQGEwJVUzEWMBQGA1UECBMNU2FuIEZyYW5jaXNj
bzELMAkGA1UEBxMCQ0ExFDASBgNVBAMTC2V4YW1wbGUubmV0MFkwEwYHKoZIzj0C
AQYIKoZIzj0DAQcDQgAEgwD0C60l83LU6QxuWfmu8N5mwzkXD49PT7ErgmTe5kF5
xF9/C9dLEApc7IWQ7wLJucFH+vSa+mzvF8q+/rk1JqA6MDgGCSqGSIb3DQEJDjEr
MCkwJwYDVR0RBCAwHoILZXhhbXBsZS5uZXSCD3d3dy5leGFtcGxlLm5ldDAKBggq
hkjOPQQDAgNJADBGAiEApt/5g2atplOY1uPBJe7zdTzb13hrHKxkn4x5qp7lbfIC
IQC6TTaUJ7TSg7m3uZ7pLHwcAawXUDUSKl/FKGig9NQ28w==
-----END CERTIFICATE REQUEST-----
[root@centos ca]# cat ca.pem
-----BEGIN CERTIFICATE-----
MIIB1DCCAXqgAwIBAgIUP7TmLzZNS19xnOnFoRe3JM2+V00wCgYIKoZIzj0EAwIw
SDELMAkGA1UEBhMCVVMxFjAUBgNVBAgTDVNhbiBGcmFuY2lzY28xCzAJBgNVBAcT
AkNBMRQwEgYDVQQDEwtleGFtcGxlLm5ldDAeFw0yMjA5MTUxNTM0MDBaFw0yNzA5
MTQxNTM0MDBaMEgxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1TYW4gRnJhbmNpc2Nv
MQswCQYDVQQHEwJDQTEUMBIGA1UEAxMLZXhhbXBsZS5uZXQwWTATBgcqhkjOPQIB
BggqhkjOPQMBBwNCAASDAPQLrSXzctTpDG5Z+a7w3mbDORcPj09PsSuCZN7mQXnE
X38L10sQClzshZDvAsm5wUf69Jr6bO8Xyr7+uTUmo0IwQDAOBgNVHQ8BAf8EBAMC
AQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUFV94iDw1K/tZPscL9IWua/ak
nx8wCgYIKoZIzj0EAwIDSAAwRQIhALo1Xm9/9kvttqLSgJZmjwcbseUSbVx337qK
qZS4IN2fAiAuWo68N+0G7yjvLaQhJCoo53jEAqXUORaskH/BNH9qlg==
-----END CERTIFICATE-----
[root@centos ca]# cat ca-key.pem 
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEICLiqIeTG8YCG2BBauf9f37wybojh26qYQlwqfYeGxa4oAoGCCqGSM49
AwEHoUQDQgAEgwD0C60l83LU6QxuWfmu8N5mwzkXD49PT7ErgmTe5kF5xF9/C9dL
EApc7IWQ7wLJucFH+vSa+mzvF8q+/rk1Jg==
-----END EC PRIVATE KEY-----
[root@centos ca]# 

```

### 补充：
https://blog.csdn.net/u012219045/article/details/100537007
ca.pem 根证书  
ca-key.pem 根证书的密钥  
ca.pem -> ca.crt   其实就是公钥  
ca-key.pem ->ca.key   
4. 客户端解析证书    
这部分工作是有客户端的TLS来完成的，首先会验证公钥是否有效，比如颁发机构，过期时间等，如果发现异常，则会弹出一个警告框，提示证书存在问题。如果证书没有问题，那么就生成一个随即值，然后用证书对该随机值进行加密。


```bash
#vim 如何显示行号？  
:set number #临时显示
#永久显示行号 需要修改vim配置文件vimrc

```


### linux 虚拟机开机失败：
解决办法：
```bash 
umount /dev/sda3
xfs_repair -L /dev/sda3 
reboot 
```



