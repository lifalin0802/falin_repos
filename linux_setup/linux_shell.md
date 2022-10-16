### 逐行处理：
```bash
#IFS的默认值为：空白(包括：空格，制表符，换行符)。

cat data.dat | awk '{print $0}'
cat data.dat | awk 'for(i=2;i<NF;i++) {printf $i} printf "\n"}'

for line in $(cat data.dat)
do
 echo "File:${line}"
done
 
for line in `cat data.dat`
do
 echo "File:${line}"
done
```