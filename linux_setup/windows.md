### VMware Workstation 与 Device/Credential Guard 不兼容
```bash
# 关闭hyper-v
bcdedit /set hypervisorlaunchtype off
bcdedit /set hypervisorlaunchtype auto

Enable-WindowsOptionalFeature -Online -FeatureName containers -All
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All


#关闭 关闭windows sandbox
控制面板→程序→ 打开或关闭windows功能→取消windows SandBox的所有选项。

#关闭 内核隔离 [ 启动它就默认启动了Hyper-V ]
设置→更新&安全→Windows安全→设备安全→内核隔离

#禁用 Device Guard
Win+R →输入gpedit.msc→ Computer Configuration → Administrative Templates → Systems → Device Guard → 右侧设置，双击Turn on Virtualization Based Security → 左上第三个Disabled/禁用 （禁用可能会导致不能安装第三方软件）
```


### 安装windows 虚拟机：
```bash
# 1. 开启remote connection
pc -> remote settings -> allow remote connections to this computer

# 2. 关闭firewall


```

### 安装wireguard:
```bash

wireguard /installtunnelservice C:\path\to\some\myconfname.conf
wireguard /uninstalltunnelservice myconfname

c:/WireGuard/WireGuard/wireguard.exe  /installtunnelservice  "C:\\client.conf"


```


### windows command:
```bash
# whoami
echo %USERDOMAIN%\%USERNAME%

# 注册服务
sc create DeepTunSvc binPath="C:\Program Files (x86)\CloudDeep\EnterLite\EnterLite.exe" displayname="DeepTunSvc" start=auto
sc create DeepTunSvc start= delayed-auto binpath= "C:\Program Files (x86)\CloudDeep\EnterLite\EnterLite.exe service"

# 配置
sc config TrustedInstaller binpath= "%SystemRoot%\servicing\TrustedInstaller.exe"

#启动服务
sc start servername
net start DeepTunSvc

#查找服务 
sc query | findstr DeepTunSvc # 只能找到开启的服务




# 注册服务
sc create WireGuardTunnel start= delayed-auto binpath= "c:/WireGuard/WireGuard/wireguard.exe  /tu
nnelservice  ""C:\\client.conf"""

sc config WireGuardTunnel dep
end= NSI/TcpIp/
sc qc WireGuardTunnel

#wireguard 导入配置文件
c:/WireGuard/WireGuard/wireguard.exe  /installtunnelservice  C:\client.conf

#启动服务
net start WireGuardTunnel$client
sc start WireGuardTunnel$client


#powershell 方式直接启动进程
powershell.exe -Command Start-Process -FilePath "c:\WireGuard\WireGuard\wireguard.exe" -ArgumentList "/installtunnelservice","C:\client.conf"

#删除服务
sc delete WireGuardTunnel$client
#查看服务
sc qc WireGuardTunnel$client


#静默安装
powershell.exe -Command Start-Process -Wait -FilePath 'c:\sdp.exe' -ArgumentList '/s /v/qn' -PassThru

#查看日志
powershell.exe -Command Get-EventLog -List
powershell.exe -Command Get-EventLog -LogName System -EntryType Error
Get-EventLog -LogName System -InstanceId 3221232496 | Select-Object -Property Message
Get-EventLog -LogName 
Application -Newest 10 -EntryType Warning | select -ExpandProperty message



powershell.exe -Command "Get-EventLog -LogName System -InstanceId 3221232496 | select -ExpandProperty message"


powershell.exe -Command "Get-EventLog -LogName System -InstanceId 3221232496 | Select-Object -Property Message"
#调整powershell配置
powershell.exe -Command Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

#
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v ServicesPipeTimeout /t REG_DWORD /d 60

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d <value> /f

```


### windows下的dockerfile
```bash
FROM mcr.microsoft.com/windows/servercore:ltsc2019

COPY DeepCloud_SDP_Std_Update_6.9.4_20220623162027.exe c:/sdp.exe
RUN  powershell.exe -Command Start-Process -Wait -FilePath 'c:\sdp.exe' -ArgumentList '/s /v/qn' -PassThru

CMD [ "cmd" ]
```