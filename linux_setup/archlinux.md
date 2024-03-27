### 装
```bah
ping aidu.com
ping 8.8.8.8
timedatectl set-timezone Asia/Shanghai
date
fdisk -l #列出
cfdisk /dev/sda #我的硬盘是sda
```
或者cfdisk 回车，选择gpt  
本次一共20G大小
![](./img/2023-10-02-03-14-57.png)
![](./img/2023-10-02-03-14-12.png)
```bash
mkfs.vfat /dev/sda1    (boot分区必须使用fat32格式。efi分区)
mkfs.ext4 /dev/sda2    (/home分区,linux filesystem，最大的那个)


mount /dev/sda2 /mnt #挂载主分区 (sda2 is where I have root)
mount /dev/sda1 /mnt/boot (I do not use /mnt/boot/efi)
vim /etc/pacman.d/mirrorlist
Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.zju.edu.cn/archlinux/$repo/os/$arch 

pacman -Syy
pacman -Sy archlinux-keyring 
pacstrap /mnt efibootmgr grub base linux vim nano

mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
genfstab -U /mnt >> /mnt/etc/fstab 

arch-chroot /mnt  #很重要！！ 已经安装过的archlinux 可以直接通过这个命令启动
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  
hwclock --systohc 
pacman -Sy vim
> pacman -Qo locale-gen 
/usr/sbin/locale-gen is owned by glibc 2.38-5
> /usr/sbin/locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "archlinux" > /etc/hostname
pacman -S grub efibootmgr efivar networkmanager intel-ucode
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
pacman -S openssh
systemctl enable sshd

pacman -Sy konsole plasma xorg
systemctl enable sddm
pacman -Sy wqy-zenhei
```
![](./img/2023-09-04-00-47-32.png)


### 自动安装

### kde美化 开机后的配置
```bash
pacman -Sy konqueror
pacman -Syy inetutils # install telnet
pacman -Syy openssh # install openssh
pacman -S net-tools #install netstat
yes | sudo pacman -S firefox #without perceed with installation

vim /etc/hosts.allow 
# cat >>  为追加 cat > 为覆盖
cat >> /etc/pacman.conf << eof  
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
#Server = https://mirrors.aliyun.com/archlinuxcn/$arch
eof

systemctl start sshd #启动SSH服务：运行以下命令启动SSH服务：
systemctl enable sshd #设置SSH服务开机自启动：运行以下命令使SSH服务在系统启动时自动启动：
firewall-cmd --permanent --add-port=22/tcp #配置防火墙规则：如果您使用了防火墙，需要配置防火墙规SH连接。假设您使用的是firewalld，可以运行以下命令来开放22端口：
firewall-cmd --reload

# dhcp static ip
pacman -S dhcpcd
systemctl enable --now dhcpcd

cat >> /etc/dhcpcd.conf << eof
interface ens33
static ip_address=192.168.232.132/24
static routers=192.168.232.2  #gateway
static domain_name_servers=192.168.232.1 114.114.114.114
eof

cat > /etc/resolv.conf.bak << EOF
search localdomain  
nameserver 192.168.232.2  
nameserver 114.114.114.114
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF 


#/etc/resolv.conf 经常被 dhcpcd 重写？ 参考 https://bbs.archlinux.org/viewtopic.php?id=159857
systemctl stop dhcpcd #停止服务
chattr +i /etc/resolv.conf #加锁 防止重写，当然自己也不能编辑了


#install chrome refered to: https://aur.archlinux.org/packages/google-chrome
$ curl -sSf https://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages | \
     grep -A1 "Package: google-chrome-stable" | \
     awk '/Version/{print $2}' | \
     cut -d '-' -f1

```

### 性能查看
```bash
df -h #查看磁盘
free #查看memory
less /proc/meminfo #查看me
top -i #查看cpu
vmstat -s #or vmstat 回车，查看cpu + memory



```

### 拓展磁盘
用gparted https://www.addictivetips.com/ubuntu-linux-tips/resize-hard-drive-partitions-on-linux/
```bash
yes| pacman -S gparted
```


### 一直乱码
因为一直没有 合适的字体支持，下载字体就好
```bash
pacman -S wqy-zenhei ttf-fireflysun 
```

### 赋予权限 permission of folder written to user
```bash
setfacl -m u:lifalin:rwx /home/lifalin/git_repo/google-chrome/
su lifalin 
cd /home/lifalin/git_repo/google-chrome/
makepkg -si

```

# 永久关闭 swap
refered to https://unix.stackexchange.com/questions/551185/how-do-i-permanently-disable-swap-on-archlinux  
最重要的两步  
```bash
systemctl mask dev-zram0.swap 
swapoff -a 
```
演示：
```bash
➜  ~ lsblk           
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   20G  0 disk 
├─sda1   8:1    0  512M  0 part /boot
└─sda2   8:2    0 19.5G  0 part /
sr0     11:0    1 1024M  0 rom  
zram0  254:0    0  966M  0 disk [SWAP]
➜  ~ systemctl --type swap
  UNIT           LOAD   ACTIVE SUB    DESCRIPTION                  
  dev-zram0.swap loaded active active Compressed Swap on /dev/zram0

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
1 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
➜  ~ systemctl mask dev-zram0.swap     
Created symlink /etc/systemd/system/dev-zram0.swap → /dev/null.
➜  ~ swapoff -a 
```

```bash
[lifalin@archlinux yay]$  makepkg -si   
==> ERROR: You do not have write permission for the directory $BUILDDIR (/home/lifalin/git_repo/yay).
    Aborting...
# 解决办法，
```

```bash
pacman -S code #安装vscode
#若出现error: failed retrieving file 'electron25-25.9.4-1-x86_64.pkg.tar.zst' from mirror.funami.tech : The requested URL returned error: 404 需要更新下载源
vim /etc/pacman.d/mirrorlist 
#添加在最上行
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
#更新下载源
pacman -Syy

#下载linux 版本的vscode
https://code.visualstudio.com/docs/?dv=linux64

vim /etc/.bashrc

alias go="/usr/local/go/bin/go"
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
alias code="/usr/local/VSCode-linux-x64/bin/code --user-data-dir=\"~/.vscode-root\" --no-sandbox"


```
### 如何设置vscode in linux 的settings.json 
- ctrl + shift + p ，打开open user settings ，通常在项目目录下的 ./\~/.vscode-root/User/settings.json 编辑



### 环境变量设置
```bash
➜  operator-crd cat /etc/.bashrc
alias k="/usr/bin/kubectl"
export EDITOR=vim
alias kgp="kubectl get pod"
alias etcdctl="/tmp/etcd-download-test/etcdctl"
alias etcdutl="/tmp/etcd-download-test/etcdutl"
alias etcd="/tmp/etcd-download-test/etcd"

alias go="/usr/local/go/bin/go"
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:/usr/local/go/bin
alias code="/usr/local/VSCode-linux-x64/bin/code --user-data-dir=\"~/.vscode-root\" --no-sandbox"

```