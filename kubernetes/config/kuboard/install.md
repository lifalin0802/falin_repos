




```bash
docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -p 80:80/tcp \
  -p 10081:10081/udp \
  -p 10081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://192.168.5.140:80" \
  -e KUBOARD_AGENT_SERVER_UDP_PORT="10081" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
  -v /root/kuboard-data:/data \
  eipwork/kuboard:v3.5.0.2

docker run -d --name rancher -v /etc/localtime:/etc/localtime \
-v /opt/rancher/mysql:/var/lib/mysql \
--restart=unless-stopped -p 8080:8080/tcp rancher/server 

docker run --name rancher-master -d --restart=unless-stopped --privileged -p 8001:80 -p 443:443 rancher/rancher:stable
docker run -p ip:hostPort:containerPort redis
```