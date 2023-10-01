### 安装
```bash
fdisk -l #列出
cfdisk /dev/sdb #我的硬盘是sdb

mkfs.fat -F32 /dev/sdb1    (boot分区必须使用fat32格式)
mkfs.ext4 /dev/sdb2    (/home分区)
```
![](2023-09-04-00-47-32.png)