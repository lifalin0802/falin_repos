### 安装步骤
deployment 方式参考 https://www.aspecto.io/blog/ distributed-tracing-with-opentelemetry-collector-on-kubernetes/  
operator 方式部署：https://github.com/open-telemetry/opentelemetry-operator  
daemonset 方式部署： https://raw.githubusercontent.com/open-telemetry/opentelemetry-collector/main/examples/k8s/otel-config.yaml  
部署个demo app试试 https://opentelemetry.io/docs/demo/kubernetes-deployment/
```bash
kubectl create namespace otel-demo
kubectl apply --namespace otel-demo -f https://raw.githubusercontent.com/open-telemetry/opentelemetry-demo/main/kubernetes/opentelemetry-demo.yaml
kubectl port-forward svc/my-otel-demo-frontendproxy 8080:8080
```
讲解的比较好的视频 
https://www.aspecto.io/opentelemetry-fundamentals/opentelemetry-collector-on-kubernetes/

### 部署时的问题 查找错误
```bash
k logs otel-collector-6754d4bd95-89wlb -n opentelemetry #即使该容器启动失败，也可以找到log
k events -n opentelemetry
```

### 暴露服务
```bash
kubectl port-forward svc/opentelemetry-demo-jaeger-collector 4318:4318 -n otel-demo
```


serviceaccount/opentelemetry-demo-grafana created
serviceaccount/opentelemetry-demo-jaeger created
serviceaccount/opentelemetry-demo-otelcol created
serviceaccount/opentelemetry-demo-prometheus-server created
serviceaccount/opentelemetry-demo created
secret/opentelemetry-demo-grafana created
configmap/opentelemetry-demo-grafana created
configmap/opentelemetry-demo-otelcol created
configmap/opentelemetry-demo-prometheus-server created
configmap/opentelemetry-demo-grafana-dashboards created
clusterrole.rbac.authorization.k8s.io/opentelemetry-demo-grafana-clusterrole created
clusterrole.rbac.authorization.k8s.io/opentelemetry-demo-prometheus-server created
clusterrolebinding.rbac.authorization.k8s.io/opentelemetry-demo-grafana-clusterrolebinding created
clusterrolebinding.rbac.authorization.k8s.io/opentelemetry-demo-prometheus-server created
role.rbac.authorization.k8s.io/opentelemetry-demo-grafana created
rolebinding.rbac.authorization.k8s.io/opentelemetry-demo-grafana created
service/opentelemetry-demo-grafana created
service/opentelemetry-demo-jaeger-agent created
service/opentelemetry-demo-jaeger-collector created
service/opentelemetry-demo-jaeger-query created
service/opentelemetry-demo-otelcol created
service/opentelemetry-demo-prometheus-server created
service/opentelemetry-demo-adservice created
service/opentelemetry-demo-cartservice created
service/opentelemetry-demo-checkoutservice created
service/opentelemetry-demo-currencyservice created
service/opentelemetry-demo-emailservice created
service/opentelemetry-demo-featureflagservice created
service/opentelemetry-demo-ffspostgres created
service/opentelemetry-demo-frontend created
service/opentelemetry-demo-frontendproxy created
service/opentelemetry-demo-kafka created
service/opentelemetry-demo-loadgenerator created
service/opentelemetry-demo-paymentservice created
service/opentelemetry-demo-productcatalogservice created
service/opentelemetry-demo-quoteservice created
service/opentelemetry-demo-recommendationservice created
service/opentelemetry-demo-redis created
service/opentelemetry-demo-shippingservice created
deployment.apps/opentelemetry-demo-grafana created
deployment.apps/opentelemetry-demo-jaeger created
deployment.apps/opentelemetry-demo-otelcol created
deployment.apps/opentelemetry-demo-prometheus-server created
deployment.apps/opentelemetry-demo-accountingservice created
deployment.apps/opentelemetry-demo-adservice created
deployment.apps/opentelemetry-demo-cartservice created
deployment.apps/opentelemetry-demo-checkoutservice created
deployment.apps/opentelemetry-demo-currencyservice created
deployment.apps/opentelemetry-demo-emailservice created
deployment.apps/opentelemetry-demo-featureflagservice created
deployment.apps/opentelemetry-demo-ffspostgres created
deployment.apps/opentelemetry-demo-frauddetectionservice created
deployment.apps/opentelemetry-demo-frontend created
deployment.apps/opentelemetry-demo-frontendproxy created
deployment.apps/opentelemetry-demo-kafka created
deployment.apps/opentelemetry-demo-loadgenerator created
deployment.apps/opentelemetry-demo-paymentservice created
deployment.apps/opentelemetry-demo-productcatalogservice created
deployment.apps/opentelemetry-demo-quoteservice created
deployment.apps/opentelemetry-demo-recommendationservice created
deployment.apps/opentelemetry-demo-redis created
deployment.apps/opentelemetry-demo-shippingservice created
serviceaccount/opentelemetry-demo-grafana-test created
configmap/opentelemetry-demo-grafana-test created
pod/opentelemetry-demo-grafana-test created