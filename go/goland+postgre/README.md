### How to programming web service using postgre and goland
https://www.bilibili.com/video/BV1dy4y1u7Sq 视频教程网站： 后端开发大师课程 [Golang + Postgres +Docker] (中文字幕)

#### Step1: export sql script from db designer online
https://dbdiagram.io/d
```sql
Table accounts as A {
  id bigserial [pk]
  owner varchar [not null]
  balance bigint [not null]
  currency varchar [not null]
  careted_at timestamptz [not null, default: `now()`]

  Indexes {
    owner
  }
}


Table entries {
  id bigserial [pk]
  account_id bigint [ref: > A.id ]
  amount bigint [not null, note: 'cannot be negetive or positive']
  careted_at timestamptz [not null, default: `now()`]
  Indexes {
    account_id
  }
}

Table transfers {
   id bigserial [pk]
  from_account_id bigint [ref: > A.id ]
  to_account_id bigint [ref: > A.id ]
  amount bigint [not null, note: 'must be positive']
  careted_at timestamptz [default: `now()`]
    Indexes {
    from_account_id
    to_account_id
    (from_account_id,to_account_id)
  }
} 

Enum Currency {
  USD
  EUR
}
```

#### Step2: install postgres in docker (in archlinux)
1. check from https://hub.docker.com/_/postgres
2. run postgres in docker
```bash
# download postgres image and run it
docker run --name postgres16 \
-e POSTGRES_USER=root \
-e POSTGRES_PASSWORD=secret \
-p 5432:5432 \
-d postgres:16

# login itssh-copy-id, use psql command
docker exec -it postgres16 psql -U root 

# just for test
root=# select now();
              now              
-------------------------------
 2024-07-20 18:51:17.722982+00
(1 row)

# root=# exit

# login it with :
username: root
password: secret
database: root

```

#### tries each command inside docker, 以下#不是注释~！！！！
```bash
#enter docker with shell
➜  ~ docker exec -it postgres16 /bin/sh 
# dropdb simple_bank
# createdb --username=root --owner=root simple_bank
# psql simple_bank
psql (16.3 (Debian 16.3-1.pgdg120+1))
Type "help" for help.

# 退出psql  command 模式
simple_bank=# \q
# 
```

#### install golang-migrate (will be used for db migration)
```bash
# /root/go/pkg/mod/github.com/golang-migrate/migrate/v4@v4.17.1/cmd/migrate
cd $(go env GOPATH)/pkg/mod/github.com/golang-migrate/migrate/v4@v4.17.1/cmd/migrate 

# check current path
➜  migrate pwd                          
/root/go/pkg/mod/github.com/golang-migrate/migrate/v4@v4.17.1/cmd/migrate

# build migrate binary file
go build

# check the binary file
➜  migrate ls
examples  main.go  migrate  README.md  version.go


mv migrate /usr/local/bin/
migrate -version
```


#### create db using golang-migrate
```bash
#/home/lifalin/code/go/full-stack/db/migration
mkdir -p db/migration 

# create db migration file
➜  migration pwd
/home/lifalin/code/go/simplebank/db/migration
➜  simplebank migrate create -ext sql -dir ./db/migration -seq init_schema 
/home/lifalin/code/go/simplebank/db/migration/000001_init_schema.up.sql
/home/lifalin/code/go/simplebank/db/migration/000001_init_schema.down.sql

```

#### tries with up or down file to do db migration
```bash
➜  simplebank migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank" -verbose up
2024/07/24 02:21:28 error: pq: SSL is not enabled on the server
➜  simplebank migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up 
2024/07/24 02:22:07 Start buffering 1/u init_schema
2024/07/24 02:22:07 Read and execute 1/u init_schema
2024/07/24 02:22:07 Finished 1/u init_schema (read 30.646949ms, ran 8.661813ms)
2024/07/24 02:22:07 Finished after 40.330872ms
2024/07/24 02:22:07 Closing source and database

```



```bash
go mod init gin
PS C:\code\go\gin> go get -u github.com/gin-gonic/gin
go: added github.com/bytedance/sonic v1.11.9
go: added github.com/bytedance/sonic/loader v0.1.1
go: added github.com/cloudwego/base64x v0.1.4
go: added github.com/cloudwego/iasm v0.2.0
...

#之后go.sum中会有东西：
require (
	github.com/bytedance/sonic v1.11.9 // indirect
	github.com/bytedance/sonic/loader v0.1.1 // indirect
	github.com/cloudwego/base64x v0.1.4 // indirect
	github.com/cloudwego/iasm v0.2.0 // indirect
	github.com/gabriel-vasile/mimetype v1.4.4 // indirect
...
)
```

#### install sqlc from golang
```bash
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
cp $(go env GOPATH)/bin/sqlc /usr/local/bin/
```

#### generate go code with sqlc
```yaml
# copy yaml from https://github.com/sqlc-dev/sqlc/tree/v1.4.0, name it as sqlc.yaml
version: "1"
packages:
  - name: "db"
    path: "./db/sqlc"
    queries: "./db/query/"
    schema: "./db/migration/"
    engine: "postgresql"
    emit_json_tags: true
    emit_prepared_queries: false
    emit_interface: false
    emit_exact_table_names: false # if true, accounts table > Accounts struct
```

#### try sqlc command, within the same folder of sqlc.yaml
```bash
sqlc generate
➜  simplebank sqlc generate
# package db
error parsing queries: no queries contained in paths /home/lifalin/code/go/simplebank/db/query
```
this will generate go code under ./db/sqlc  
![Alt text](image.png)


#### edit unit test
1. edit *_test.go(eg: main_test.go) and run it
```bash
go test main_test.go
```
2. run one test  
- click 'run test'
![Alt text](image-1.png)

#### install golang lib pq as db driver
```bash
go get github.com/lib/pq@latest
```


#### check test coverage 
1. click run packages tests

![Alt text](image-2.png)
2. open account.go, 
you cloud see red code segment are not tested
![Alt text](image-3.png)


#### try github action CI
- under ./.github/workflows/ci.yml  
随意命名 xx.yml 即可， 然后git push到main分支
```yaml
name: ci-test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:

  test:
    name: Test
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: root
          POSTGRES_PASSWORD: secret
          POSTGRES_DB: simple_bank
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5


    steps:

    - name: Set up Go 1.x
      uses: actions/setup-go@v4
      with: 
        go-version: ^1.21
      id: go

    - name: Check out code into the Go module directory
      uses: actions/checkout@v4

    - name: Install golang-migrate
      run: |
        curl -L https://github.com/golang-migrate/migrate/releases/download/v4.17.1/migrate.linux-amd64.tar.gz| tar xvz
        sudo mv migrate /usr/bin/migrate
        which migrate

    - name: Run migrations
      run: make migrationup

    - name: Test
      run: make test
      
```