
#!bin/bash
# SHELL8 统计所有进程占用内存大小的和
sum=0
    for i in `awk '{print $6}' nowcoder.txt`
    do
        ((sum+=$i))
    done
echo $sum