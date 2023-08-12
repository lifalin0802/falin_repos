
### 如何确定自己的 使用k8s的权限
参考 https://zhuanlan.zhihu.com/p/615934091  k8s kubernetes-admin用户权限解析
```bash
➜  ~ k config view        
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.5.140:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: admin-user
  user:
    token: REDACTED
- name: kubernetes-admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
```

```bash
➜  ~ k get clusterrolebinding cluster-admin -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2023-05-31T06:05:28Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster-admin
  resourceVersion: "136"
  uid: 5172da06-ac71-4c74-a7e8-15b1b3b29a4c
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group  #注意不是ServiceAccount了, 而是Group
  name: system:masters #


```
### system:masters 到底是什么
我们知道 k8s 中用户分为2种 一种是Normal Users 一种是Service Account , k8s不管理Users ,只要证书通过即可访问集群, 上面的kubernetes-admin就是属于 Users 一种 , 但是用户可以操作的权限是在 关联 rolebinding / clusterrolebinding, 所以 kubernetes-admin肯定也有绑定的角色
```bash
# serviceaccount 中却找不到 system:masters，说明 system:masters 不是sa, 而是 Node Users
➜  ~ k get sa -A|grep master     
➜  ~ 

```

### 查看client-key-data 内容

```bash
➜  ~ cat /root/.kube/config                      
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR3RENDQXFpZ0F3SUJBZ0lVRkhjamxuTkRCUEgrb2lpa1JRN09YOFVIcDRNd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2R6RUxNQWtHQTFVRUJoTUNRMDR4RURBT0JnTlZCQWdUQjBKbGFXcHBibWN4RURBT0JnTlZCQWNUQjBKbAphV3BwYm1jeEV6QVJCZ05WQkFvVENrdDFZbVZ5Ym1WMFpYTXhHakFZQmdOVkJBc1RFVXQxWW1WeWJtVjBaWE10CmJXRnVkV0ZzTVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1DQVhEVEl5TURneE1ERTJNREl3TUZvWUR6SXgKTWpJd056RTNNVFl3TWpBd1dqQjNNUXN3Q1FZRFZRUUdFd0pEVGpFUU1BNEdBMVVFQ0JNSFFtVnBhbWx1WnpFUQpNQTRHQTFVRUJ4TUhRbVZwYW1sdVp6RVRNQkVHQTFVRUNoTUtTM1ZpWlhKdVpYUmxjekVhTUJnR0ExVUVDeE1SClMzVmlaWEp1WlhSbGN5MXRZVzUxWVd3eEV6QVJCZ05WQkFNVENtdDFZbVZ5Ym1WMFpYTXdnZ0VpTUEwR0NTcUcKU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRRDBnSnZCc292UzBOQWVFcXdySDJiLzlIajJQcmlFTTR2TwpmdGY2MUN5aWs2MCtoM0ZwTVFTbTJscDQzWjJsakM3ZWw2VWlRQWRxKzJ5eWlYaHRicVNidGhPYWFJdGtUenZNCkp0eEpESlVtT2hDNDd3VFZwejZjbWpMZHRIdWlxaWxQQ094d2swdVkxeGVtNmQwZloyaGFvbExrQnZMQTZlYm8KRWFxY0pXeEJvZGtidVJ4ZTV2SWV6WjVxRlhobTdEYnRBMVRpNUhFUEV6MklQUlp0V0NPTW1zbXZHUFBuZWV5YwpRd3N3Vm1UVmRXQ1ordS8zdkNHOEtYNjE1d2YrWkJnQmdQdTNkQnhlWU94ZXRXeHpPS1g4WjNqSWRFeVdxQkFaCndOWWhBT0Fkb0VXK0pTdFAzaG9NdUF2Rzg1eS9aT1VXT04rY3k4cHdaNy9aL01BaVB4ZnhBZ01CQUFHalFqQkEKTUE0R0ExVWREd0VCL3dRRUF3SUJCakFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVdCQlRFVDFrOApUSENpVUtZYXNHdW8vVSsrRFRHUVl6QU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFHcytZaFo1ekpmVnFoM2daCmU4QjRERDNPeGJ5djYyVnFvUFAwYUxiRlBDMG9kS1orY1RKL21jajlaMnd6aTlreUVmamFDTjNKTlpIOTdCUFEKTGtpMzl4Yk5rQWI1Tnp0Nk5wbTN1U0UyTkI2dDI0ME1GYllxZEJGM2JkVzhYZU1tZ2J4VHl6cGlVMUxBUURCbgpwVzJBeG5VbVNMU1BFbS9OejBxK0VMOGt2c0E0aHMxejNnejFrTlhYVEhPY0xVUkVDM0VWakl6eXdkVll5cWlOCnF2UDUwWURJQWdscmUwWkVnNTVYamExdGZ3cHh4Y0g3T3d4ekx1bFpWQ2x3Kzhab1VMMWRPMVNBQUFVYm40OUIKOEVmcG1QcFRUZHpQU1lCWWh4R2EzdTMvQ3BwNjBySlczSGo5RnVQRlZqeDI5Y2ZNeGhBNDlxSkJzNlAvbmMzSApIZHBEWkE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://192.168.5.140:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURnekNDQW11Z0F3SUJBZ0lJSU1qWmc5M3MvSU13RFFZSktvWklodmNOQVFFTEJRQXdkekVMTUFrR0ExVUUKQmhNQ1EwNHhFREFPQmdOVkJBZ1RCMEpsYVdwcGJtY3hFREFPQmdOVkJBY1RCMEpsYVdwcGJtY3hFekFSQmdOVgpCQW9UQ2t0MVltVnlibVYwWlhNeEdqQVlCZ05WQkFzVEVVdDFZbVZ5Ym1WMFpYTXRiV0Z1ZFdGc01STXdFUVlEClZRUURFd3ByZFdKbGNtNWxkR1Z6TUI0WERUSXlNRGd4TURFMk1ESXdNRm9YRFRJME1EVXlOekV5TWpRME5Wb3cKTkRFWE1CVUdBMVVFQ2hNT2MzbHpkR1Z0T20xaGMzUmxjbk14R1RBWEJnTlZCQU1URUd0MVltVnlibVYwWlhNdApZV1J0YVc0d2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUUN0RkhzWTl0eHNaNnltCkFKVk1sNEZ6SERYbmRxTHRmUHZlOEloVkQzS3dkSWhqUHlpdStGVURlNnFpVUR4a2p3ZFI2bUFvY2hzb0k3T0gKS1c1Z3I5R0ZuL0VQYno1L2s0R29SeCtoMFB5YmovcjZxQlcwUG41TUgvbkFTYmdvaERXRTRoQlljOFlBc2toQwo4SlZtbnJwT085RnhHMmNVa3cyZVNBUmYrVGdBSDJYQ1MyUzNkQ0xsL2xpRzlIalpTaHBhcERVZ1BFbnVTaGlXCkk3VkpPS0lmenpybFdMVzZ5ZGVCZ2s3aURvSU14bVBMakxSS1M3RFY1eXhPMWt6UWlieWJ4SW51T2RLZU9WY0IKU3dDb25mWmsrbXFtUDg0cHN4cElpaWp1ajgwclVQNDdNc2FLRW52RENBVmRzMWVOc3YzOXdxSHlvaFJNRGw2Twp5WUdLSHV3MUFnTUJBQUdqVmpCVU1BNEdBMVVkRHdFQi93UUVBd0lGb0RBVEJnTlZIU1VFRERBS0JnZ3JCZ0VGCkJRY0RBakFNQmdOVkhSTUJBZjhFQWpBQU1COEdBMVVkSXdRWU1CYUFGTVJQV1R4TWNLSlFwaHF3YTZqOVQ3NE4KTVpCak1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ2R0d2VwbXROUGJaZTgva2JrMlNUTnFZZUYvZjlENWZMSApZZFNmeThaTmVnYUp2bnUxUHQ5RVRTbG1sK3B3bkxiQzZueEVxcVRZYmNwZDVqbkJMRmNVa1R1c1JkQjFBQ3dWCjBQMFd2WU9xSld6WGJGWDIrZ1F0YUlyT0NhYnFmcjhncDNINWE0UEs2ekNPVUpnVDRTU0Z6U3Fuakc5a2l1cjYKMWFMTTZQN1F6RysyVndsQUlIMzBmQkl5N1E2Q3ZLZ1MwT1RFYUhPMnBkV0ZSVktwclpySFJKN3NNbCtQZjcrbQpBa1JCU21rR3JuMklFSGRVdmNEb2NENmR6L3RlcVc1T21SZlBKclA4UEJjZ2V3ZGk1STZQRENXbVhmMXQ5aGM2CnVneUNTN0NqWkxXUzJicHpCZXRadHFlRTVQNGErZFdkVXNYN3JpK3BWTld6YmR6QnRYQm8KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=  #将其解码
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBclJSN0dQYmNiR2VzcGdDVlRKZUJjeHcxNTNhaTdYejczdkNJVlE5eXNIU0lZejhvCnJ2aFZBM3Vxb2xBOFpJOEhVZXBnS0hJYktDT3poeWx1WUsvUmhaL3hEMjgrZjVPQnFFY2ZvZEQ4bTQvNitxZ1YKdEQ1K1RCLzV3RW00S0lRMWhPSVFXSFBHQUxKSVF2Q1ZacDY2VGp2UmNSdG5GSk1ObmtnRVgvazRBQjlsd2t0awp0M1FpNWY1WWh2UjQyVW9hV3FRMUlEeEo3a29ZbGlPMVNUaWlIODg2NVZpMXVzblhnWUpPNGc2Q0RNWmp5NHkwClNrdXcxZWNzVHRaTTBJbThtOFNKN2puU25qbFhBVXNBcUozMlpQcHFwai9PS2JNYVNJb283by9OSzFEK096TEcKaWhKN3d3Z0ZYYk5YamJMOS9jS2g4cUlVVEE1ZWpzbUJpaDdzTlFJREFRQUJBb0lCQUR5R2V2Mmg1amNxa2grQworTExPRUlDMmpzc2dtNTA5SmI4eWtocGN5cGlXUjlPZEZKY0xWSDloVWF4dExwRmp5d1dFVnBnT1B4enNUeTJtCitXaHFVM1RORjdsMEI0RUpqai9RajJsQThmVmNoa0g5WVlta2lQb0ovSWFYd1FTNkp4VVBFUFE5bURKS0ppYnkKaHV4WitZQytQbUcxV1hqQ2EvSzc4SHUzWlRQMU02Qjk3NDdqblM1eVBvYWhwSDJmK0N3OCttYm12L1ViU1lRdwpaRTBOZFhNd1RZdENNcXdzVFNRWHBMbGM5cGIvcEJkR1F4SWJHTXQvSEd6Z3ZHNHoyV2dIZW5PUCtxK0NWdHNxCmN2RmM2UzM1eGgzV3QyUDFtRVBEL010YnNacFYvek9TWUVyYzkxTXhNcTVuWndFZ3lDNTJHTjhRdVN6ckp1UEIKdlVId0M0a0NnWUVBMEoreGhxYzJpL255TTVtKzdweXhVTFFYeXgzOG1td2dIWEVVSHF1MEovWmpOZ3o3dHMwWAp1cHVmeDNYQjRveC82elBvckFkWG1pRDNaSFc3elQ1NGJxb0RzcmlZdmkxbWZrNGNQNEpiN2hreDUrdEpzaDlrCmpmNVEwNmtpc3RjNlYwblFPZFdOT3E3cDVvTzF5TjVmZDZjWHlTR2t5L1BscEFpYlcwVlBUUjhDZ1lFQTFHSjAKZzNhaTdPTkFicnJhQ3dRQXpySjg0VnBwOTNKUGgwcnQyVU5tQlg0TTg2dVN5dVN1Z0ZxRUZpVTNIQko5eTk0WgpTelpESHBCamU2ckJuUFhRbkZhdGlIaEozQlRRWE5QSkE3bnVMckNCaUtlbVhNeEJsb2R2SlNnekIzTk5leDJhCkFCU0E4TDJGSEpsK0VRN213YWs4SE1rYmt0cWZ3dE1kTG9RY0NDc0NnWUVBdW00S2tYNzV3cXFRWXNaQWxqQ1cKVDcwd0NnWDVCdklhM05TQkcwdHJTYzduSjVVQWw0RzljN2ZBVjlrR2N2SUZHZVVnUmlLbGlRbHVxbXAvY2RFaQpoQm9RQmZUcUlnQ21ON2FMamNGcmIyRTZkTHFROThrUDdjZlc2TjZiTUdBZk5ZT3p2UXIyRXZ2ZDcyM0IxQWZNCkhqdkdpS2sxQUVFcTlLUHdXT2FlRUJjQ2dZQjMyYU4wZUdOU21KOUluVXJrUW5zT0tXME5ZbzgvNHhMNy93MmYKdUVmL08zV2xvQ0d6T3o4NkVWcE9nT3ZMZktmZWZ0UDVQSUs5NGE4eUgxY284eEtvMXNVUXFRak5HRFhJM0g2bwpDcWxkVVorWGRUd05TL3FMTHB4SzlKZHZVZUxjWWdVQW5KRnl5UkF2NW5KY3YvTDZRRDA2NVVZWkppUlh0ZmpXCndoaHJod0tCZ1FEQy8rc3o2V0tlcjZTMjd2RitLMnJqYlE1M0Y0RDhzdVoxMHJKdTNlZlBuZnV3d0pBTWRnWFkKNG0wQjJYTHI5cE9qSWZDMW8xR3R4Mm1iRjRZZ1hqd2FGdkZCVDFMSzd2YVNhZStFbnMwRGl2SWxEbzU2SmNUZApzMXBGUjROK1REZnJXU09hcWl2aDBpejZ3Uk5kU2I5WUlCRVY1Mkp1NEV1VTFjZkNLOThLTFE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=

➜  ~ cat <<EOF | base64 -d > admin-temp-ca.crt
pipe heredoc> LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURnekNDQW11Z0F3SUJBZ0l
...
R6QnRYQm8KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
pipe heredoc> EOF
```
### 查看他们的关系
```bash
➜  ~ openssl x509  -in admin-temp-ca.crt -noout -text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 2362377164943064195 (0x20c8d983ddecfc83)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=Beijing, L=Beijing, O=Kubernetes, OU=Kubernetes-manual, CN=kubernetes
        Validity
            Not Before: Aug 10 16:02:00 2022 GMT
            Not After : May 27 12:24:45 2024 GMT
        Subject: O=system:masters, CN=kubernetes-admin #这里看出kubernetes-admin和system:masters 的关系
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:ad:14:7b:18:f6:dc:6c:67:ac:a6:00:95:4c:97:
                    81:73:1c:35:e7:76:a2:ed:7c:fb:de:f0:88:55:0f:
                    72:b0:74:88:63:3f:28:ae:f8:55:03:7b:aa:a2:50:
                    3c:64:8f:07:51:ea:60:28:72:1b:28:23:b3:87:29:
                    6e:60:af:d1:85:9f:f1:0f:6f:3e:7f:93:81:a8:47:
                    1f:a1:d0:fc:9b:8f:fa:fa:a8:15:b4:3e:7e:4c:1f:
                    f9:c0:49:b8:28:84:35:84:e2:10:58:73:c6:00:b2:
                    48:42:f0:95:66:9e:ba:4e:3b:d1:71:1b:67:14:93:
                    0d:9e:48:04:5f:f9:38:00:1f:65:c2:4b:64:b7:74:
                    22:e5:fe:58:86:f4:78:d9:4a:1a:5a:a4:35:20:3c:
                    49:ee:4a:18:96:23:b5:49:38:a2:1f:cf:3a:e5:58:
                    b5:ba:c9:d7:81:82:4e:e2:0e:82:0c:c6:63:cb:8c:
                    b4:4a:4b:b0:d5:e7:2c:4e:d6:4c:d0:89:bc:9b:c4:
                    89:ee:39:d2:9e:39:57:01:4b:00:a8:9d:f6:64:fa:
                    6a:a6:3f:ce:29:b3:1a:48:8a:28:ee:8f:cd:2b:50:
                    fe:3b:32:c6:8a:12:7b:c3:08:05:5d:b3:57:8d:b2:
                    fd:fd:c2:a1:f2:a2:14:4c:0e:5e:8e:c9:81:8a:1e:
                    ec:35
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Authority Key Identifier: 
                keyid:C4:4F:59:3C:4C:70:A2:50:A6:1A:B0:6B:A8:FD:4F:BE:0D:31:90:63

    Signature Algorithm: sha256WithRSAEncryption
         9d:b7:07:a9:9a:d3:4f:6d:97:bc:fe:46:e4:d9:24:cd:a9:87:
         85:fd:ff:43:e5:f2:c7:61:d4:9f:cb:c6:4d:7a:06:89:be:7b:
         b5:3e:df:44:4d:29:66:97:ea:70:9c:b6:c2:ea:7c:44:aa:a4:
         d8:6d:ca:5d:e6:39:c1:2c:57:14:91:3b:ac:45:d0:75:00:2c:
         15:d0:fd:16:bd:83:aa:25:6c:d7:6c:55:f6:fa:04:2d:68:8a:
         ce:09:a6:ea:7e:bf:20:a7:71:f9:6b:83:ca:eb:30:8e:50:98:
         13:e1:24:85:cd:2a:a7:8c:6f:64:8a:ea:fa:d5:a2:cc:e8:fe:
         d0:cc:6f:b6:57:09:40:20:7d:f4:7c:12:32:ed:0e:82:bc:a8:
         12:d0:e4:c4:68:73:b6:a5:d5:85:45:52:a9:ad:9a:c7:44:9e:
         ec:32:5f:8f:7f:bf:a6:02:44:41:4a:69:06:ae:7d:88:10:77:
         54:bd:c0:e8:70:3e:9d:cf:fb:5e:a9:6e:4e:99:17:cf:26:b3:
         fc:3c:17:20:7b:07:62:e4:8e:8f:0c:25:a6:5d:fd:6d:f6:17:
         3a:ba:0c:82:4b:b0:a3:64:b5:92:d9:ba:73:05:eb:59:b6:a7:
         84:e4:fe:1a:f9:d5:9d:52:c5:fb:ae:2f:a9:54:d5:b3:6d:dc:
         c1:b5:70:68
➜  ~ 

```