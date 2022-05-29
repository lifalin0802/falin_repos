

### go 常用命令
```bash
go run XX.go #运行S
go build xx.go  #生成xx可执行文件
go install xx.go #将会生成xx可执行文件在gopath/bin 目录下，后，全局可以访问 执行 xx
go get gonum.org/v1/gonum/stat # 在go.mod 中生成require w斌且安装到 gopath/pkg 目录下 
go get github.com/tinylib/msgp 
go mod init module_name
go mod tidy # 会重新整理go.mod文件
go vet xx.go # 检查语法
go fmt entrance class/demo.go 
go fmt xx.go # 美化语法 格式化 format 
go doc fmt # go doc packagename, 显示fmt 包的注释，描述
go version
go env # 查看环境变量 
```

go.mod 是执行go init 生成的
go.sum  是在go get 时 生成的