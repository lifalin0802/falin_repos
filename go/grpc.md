




```bash
# 安装grpc 核心库
go get google.golang.org/grpc  #go mod中 就会有相应的东西了

#我的下载在  GOPATH下 C:\Users\Administrator\go\bin\windows_amd64
go install  google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install  google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

#编辑好proto 文件
$ tree .
.
|-- go.mod
`-- proto
    |-- hello.pb.go
    |-- hello.proto
    `-- hello_grpc.pb.go

1 directory, 4 files

#proto 命令 生成proto.    在上述目录中
protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative proto/*.proto
```


![Alt text](image.png)