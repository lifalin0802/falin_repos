### kubeconfig 文件所在位置
`/var/root/.kube/config `


### 暴露到本地端口
```bash
kubectl describe pod -l app=pgadmin | grep -G "PGADMIN_DEFAULT_.*$"
kubectl describe pod -l app=pgadmin -n xxxx | grep -G "PGADMIN_DEFAULT_.*$"

➜  ~ k get svc -A |grep grafana           
prometheus prometheus-grafana          ClusterIP      10.16.69.181   <none>          80/TCP        37d
prometheus prometheus-grafana-klcsw    LoadBalancer   10.16.69.179   34.159.203.28   80:31807/TCP  48d
➜  ~ k get ep -A -o wide|grep grafana                                             
prometheus      prometheus-grafana           10.64.209.42:3000    37d    #3000是pod接口 
prometheus      prometheus-grafana-klcsw     10.64.209.42:3000    48d

kubectl port-forward svc/pgadmin 8080:80 -n xxxx   #8080 本机local接口，访问时候访问 http://localhost:8080/  80是svc接口
k port-forward svc/prometheus-kube-prometheus-prometheus -n prometheus 9090:9090 &

```

```yaml
# ➜  ~ k get svc -n prometheus prometheus-grafana  -o yaml     
apiVersion: v1
kind: Service
metadata:
  annotations:
    cloud.google.com/neg: '{"ingress":true}'
    meta.helm.sh/release-name: prometheus
    meta.helm.sh/release-namespace: prometheus
  creationTimestamp: "2023-08-31T15:06:01Z"
  labels:
    app.kubernetes.io/instance: prometheus
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: grafana
    app.kubernetes.io/version: 9.5.3
    helm.sh/chart: grafana-6.57.1
  name: prometheus-grafana
  namespace: prometheus
spec:
  clusterIP: 10.16.69.181
  clusterIPs:
  - 10.16.69.181
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: http-web
    port: 80   #svc port 
    protocol: TCP
    targetPort: 3000  # pod port 
  selector:
    app.kubernetes.io/instance: prometheus
    app.kubernetes.io/name: grafana
  sessionAffinity: None
  type: ClusterIP
```


```bash
kubectl describe pod -l app=pgadmin | grep -G "PGADMIN_DEFAULT_.*$"
 ⚡ root@fli-mbp  ~  k port-forward svc/pgadmin 8080:80  #会popup 一个窗口
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

### terraform脚本检查最后署名，commit 号，branchname, workspace, kubernetes 上下文，因为此处terraform会查看k8s资源而作修改
```bash
git show --oneline -s
git remote -v
pwd
terraform workspace list
kubectl config get-contexts
date
```