### kubeconfig 文件所在位置
`/var/root/.kube/config `


### 暴露到本地端口
```bash
k port-forward svc/prometheus-kube-prometheus-prometheus -n prometheus 9090:9090 &

kubectl describe pod -l app=pgadmin | grep -G "PGADMIN_DEFAULT_.*$"
 ⚡ root@fli-mbp  ~  k port-forward svc/pgadmin 8080:80  #会popup 一个窗口
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```