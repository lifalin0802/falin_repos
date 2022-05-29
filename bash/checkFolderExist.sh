
#!/bin/bash

path="./dist"
while true  #while和do之间必须要又换行
do 
    # if [ -d ./dist ];then  #yes
    if [ -d ${path} ];then
        sleep 1
    else
        echo "npm build done"
        break
    fi
done