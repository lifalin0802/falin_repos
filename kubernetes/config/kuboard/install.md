### docker 方式安装
官方推荐的v3版本的安装，不论docker 还是static-pod 都是
```bash
docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -p 80:80/tcp \
  -p 10081:10081/udp \
  -p 10081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://192.168.232.128:80" \
  -e KUBOARD_AGENT_SERVER_UDP_PORT="10081" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
  -v /root/kuboard-data:/data \
  eipwork/kuboard:v3.5.0.2

docker run -d --name rancher -v /etc/localtime:/etc/localtime \
-v /opt/rancher/mysql:/var/lib/mysql \
--restart=unless-stopped -p 8080:8080/tcp rancher/server 

docker run --name rancher-master -d --restart=unless-stopped --privileged -p 8001:80 -p 443:443 rancher/rancher:stable
docker run -p ip:hostPort:containerPort redis
```

 ### static-pod 方式安装kuboard-v3
```bash
# 参考 https://www.kuboard.cn/install/v3/install-static-pod.html
curl -fsSL https://addons.kuboard.cn/kuboard/kuboard-static-pod.sh -o kuboard.sh
sh kuboard.sh

# 在浏览器输入 http://your-host-ip:80 即可访问 Kuboard v3.x 的界面，登录方式：
# 用户名： admin
# 密 码： Kuboard123
```

### 如何添加k8s集群 参考页面
```bash
cat << EOF > kuboard-create-token.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: kuboard

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kuboard-admin
  namespace: kuboard

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kuboard-admin-crb
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kuboard-admin
  namespace: kuboard

---
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  annotations:
    kubernetes.io/service-account.name: kuboard-admin
  name: kuboard-admin-token
  namespace: kuboard
EOF

kubectl apply -f kuboard-create-token.yaml 
echo -e "\033[1;34m将下面这一行红色输出结果填入到 kuboard 界面的 Token 字段：\033[0m"
echo -e "\033[31m$(kubectl -n kuboard get secret $(kubectl -n kuboard get secret kuboard-admin-token | grep kuboard-admin-token | awk '{print $1}') -o go-template='{{.data.token}}' | base64 -d)\033[0m"

# echo -e "$(kubectl -n kuboard get secret $(kubectl -n kuboard get secret kuboard-admin-token | grep kuboard-admin-token | awk '{print $1}') -o go-template='{{.data.token}}' | base64 -d)"  # 这个是比较简洁的方式

```