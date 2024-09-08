


```bash
docker  run -p 3306:3306 --name mysql --restart=always  --privileged=true \
-e MYSQL_ROOT_PASSWORD=123456 -d mysql:latest

docker exec -it mysql sh

mysql -u root -p 
123456

create database devops_platform
use devops_platform



```


#### kitex  start for master
```bash

go install github.com/cloudwego/kitex/tool/cmd/kitex@latest
go install github.com/cloudwego/thriftgo@latest

#创建echo.thrift

kitex -module kitex -service master echo.thrift
 
go get github.com/cloudwego/kitex@latest  #为了main.go 中报错的问题
go mod tidy

# 编写handler实现部分

go run .main.go   handler.go # 启动server 

client 中引用为kitex , dest service 为master
go run client.go


```