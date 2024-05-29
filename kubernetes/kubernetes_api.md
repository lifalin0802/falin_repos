### 
```bash

KUBE_API=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}')

# 当前 apiserver 信任的证书颁发者API/version --insecure -k
# 或者不安全模式 ： curl  $KUBE_bernetes/pki/ca.crt $KUBE_API/version 
➜  pki curl --cacert /etc/kubernetes/pki/ca.crt $KUBE_API/version  #
{
  "major": "1",
  "minor": "28",
  "gitVersion": "v1.28.2",
  "gitCommit": "89a4ea3e1e4ddd7f7572286090359983e0387b2f",
  "gitTreeState": "clean",
  "buildDate": "2023-09-13T09:29:07Z",
  "goVersion": "go1.20.8",
  "compiler": "gc",
  "platform": "linux/amd64"
}#  

curl --cacert /etc/kubernetes/pki/ca.crt $KUBE_API/apis/apps/v1/deployments #会403，这个需要客户端认证

# 查看用户证书
kubectl config view -o jsonpath='{.users[0]}' | python -m json.tool

#查看当前所有的deployment
curl $KUBE_API/apis/apps/v1/deployments \
--cacert /etc/kubernetes/pki/ca.crt  \
--cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
--key /etc/kubernetes/pki/apiserver-kubelet-client.key 


JWT_TOKEN_KUBESYSTEM_DEFAULT=$(kubectl -n tekton-pipelines create token tekton-triggers-example-sa)
#但是此处该serviceaccount 没有列举权限
curl $KUBE_API/apis/apps/v1/deployments \
--cacert /etc/kubernetes/pki/ca.crt \
--header "Authorization: Bearer $JWT_TOKEN_KUBESYSTEM_DEFAULT"


curl $KUBE_API/api/v1/namespaces/default/pods/sh \
--cacert /etc/kubernetes/pki/ca.crt \
--header "Authorization: Bearer $JWT_TOKEN_KUBESYSTEM_DEFAULT"

```
### api group 是个啥， 
- A Deployment would have some apiVersion: apps/v1. Which belongs to apiGroups apps. Wherehas pods, 
- secrets or services would have theirs set to v1, thus in appGroups "".
refered to : https://stackoverflow.com/questions/73175745/not-able-to-get-deployments-as-serviceaccount
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-triggers-example-sa
  namespace: tekton-pipelines
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
    name: tekton-pipeline-permissions
    namespace: tekton-pipelines
subjects:
    - kind: ServiceAccount
      name: tekton-triggers-example-sa
      namespace: tekton-pipelines
roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: tekton-pipeline-sa
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tekton-pipeline-sa
rules:
- apiGroups: [""]
  resources: ["secrets", "services", "pods"]
  verbs: ["get", "watch", "list", "create", "delete"]
- apiGroups: ["apps"]   ### !!!
  resources: ["deployments"]
  verbs: ["get", "watch", "list", "create", "delete"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list", "get", "watch"]
```


### 其他kubectl 命令：
```bash
kubectl replace --raw /api/v1/namespaces/default/pods/demo-nginx-xxx-xxx/ephemeralcontainers -f ec.json
# 衍生： kubectl 各种命令参考： https://kubernetes.io/docs/reference/kubectl/generated/kubectl_replace/vas
```