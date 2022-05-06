

#!bin/bash
# SHELL7 打印字母数小于8的单词
for i in $(cat nowcoder.txt); do
    if [ ${#i} -lt 8 ]; then
        echo ${i}
    fi
done