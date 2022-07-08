






### iptables：

```bash

ssh -p 4001 183.194.66.42  # manager  spa ctl 
ssh -p 4002 183.194.66.42  # gateway

cat /project/deepspa/shell/iptables_default.sh:
# 
#!/bin/bash
cat /project/deepspa/shell/iptables_default.sh:
echo "Flushing existing iptables rules..."
echo ""
iptables -F

###### INPUT chain ######
#
echo "Setting up INPUT chain ..."
echo ""
# status
iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT


iptables -A INPUT -s 192.168.107.0/24 -j ACCEPT
# ssh 
iptables -A INPUT -p tcp --dport 22  -j ACCEPT
iptables -A INPUT -p tcp --dport 80  -j ACCEPT
iptables -A INPUT -p tcp --dport 443  -j ACCEPT
iptables -A INPUT -p udp --dport 62202  -j ACCEPT
iptables -A INPUT -p udp --dport 62203  -j ACCEPT

iptables -A INPUT -m set --match-set redcoreset src,dst -j ACCEPT 

iptables -A INPUT -m set --match-set deeptun_company_set src,dst -j ACCEPT 

echo "Setting up FORWARD chain ..."
echo ""

iptables -A FORWARD -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -m set --match-set redcoreset src,dst -j ACCEPT 


iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

echo "Setting iptables default OK ..."
echo ""

### EOF ###
```

```bash
ps -ef|grep nginx
cat /etc/nginx/nginx.conf

stream {
        log_format proxy '$remote_addr [$time_local]'
                 '$protocol $status $bytes_sent $bytes_received '
                 '$session_time "$upstream_addr" '
                 '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';

        error_log  /var/log/nginx/udp-error.log    error;
        access_log /var/log/nginx/udp-access.log proxy ;
        server{
                preread_buffer_size 0;
                listen 30011-30013 udp reuseport;
                proxy_pass 192.168.107.12:$server_port;
        }
}

```