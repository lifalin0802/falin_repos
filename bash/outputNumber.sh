#!bin/bash

num=0
while(($num<=500))
do
    echo $num
    let "num+=7"
done  