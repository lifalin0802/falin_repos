### windows 下安装gcc:
https://www.youtube.com/watch?v=COZw6XetvR0
```bash
# download from https://winlibs.com/


```



https://blog.csdn.net/Lyon_Nee/article/details/102644674
```bash
go env -w GOPROXY=https://goproxy.cn,direct #设置代理 
```

```bash
kubectl config view -o jsonpath='{.clusters[0].cluster.server}'
KUBE_API=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}')
curl $KUBE_API/version
```
