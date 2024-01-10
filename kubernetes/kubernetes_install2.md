

```bash
kubeadm token create --print-join-command #生成token 
k delete node centos #删除节点 之后 再 node resetm, node join


```

### 卸载kubernetes
```bash
kubeadm reset -f
modprobe -r ipip
#lsmod
rm -rf ~/.kube/
#rm -rf /etc/kubernetes/
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /etc/systemd/system/kubelet.service
rm -rf /usr/bin/kube*
rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /var/lib/etcd
rm -rf /var/etcd
yum -y remove kubeadm* kubectl* kubelet* 



cd /opt/certs
scp ca.pem root@192.168.5.140:/etc/kubernetes/pki/ca.crt
scp ca-key.pem root@192.168.5.140:/etc/kubernetes/pki/ca.key


```


```bash
cd /etc/kubernetes/pki

kubeadm init \
--apiserver-advertise-address=192.168.5.140 \
--image-repository registry.aliyuncs.com/google_containers \
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \
--upload-certs

export KUBECONFIG=/etc/kubernetes/admin.conf

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config 



kubectl  nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all node.kubernetes.io/not-ready-

k taint nodes node02 node.kubernetes.io/not-ready:NoSchedule #执行之后，如果k describe node XX taint还有污点， 就重启node节点


Taints:             node-role.kubernetes.io/control-plane:NoSchedule
                    node.kubernetes.io/not-ready:NoSchedule



#安装tigera-calico operator
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: 10.244.0.0/16  #要写对 pod subnet cidr
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
    nodeAddressAutodetectionV4:
      interface: ens.*   #很重要
---
apiVersion: operator.tigera.io/v1
kind: APIServer 
metadata: 
  name: default 
spec: {}

```




### calicoctl 安装
```bash
curl -L https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64 -o kubectl-calico
chmod +x ./calicoctl

export DATASTORE_TYPE=kubernetes

kubectl calico -h #kubectl calico -h
calicoctl -l debug get nodes #debug模式开启
```

### 查看pod网段
```bash
 kubectl get configmap kubeadm-config -n kube-system -o yaml
 [root@master01 ~]# kubectl get configmap kubeadm-config -n kube-system -o yaml
apiVersion: v1
data:
  ClusterConfiguration: |
    apiServer:
      extraArgs:
        authorization-mode: Node,RBAC
      timeoutForControlPlane: 4m0s
    apiVersion: kubeadm.k8s.io/v1beta3
    certificatesDir: /etc/kubernetes/pki
    clusterName: kubernetes
    controllerManager: {}
    dns: {}
    etcd:
      local:
        dataDir: /var/lib/etcd
    imageRepository: registry.aliyuncs.com/google_containers
    kind: ClusterConfiguration
    kubernetesVersion: v1.27.2
    networking:
      dnsDomain: cluster.local
      podSubnet: 10.244.0.0/16
      serviceSubnet: 10.96.0.0/16
    scheduler: {}
kind: ConfigMap
metadata:
  creationTimestamp: "2023-05-28T12:24:59Z"
  name: kubeadm-config
  namespace: kube-system
  resourceVersion: "238"
  uid: c66f3082-b12a-4273-a3bd-d2b62ee8b401

 ```


```bash
k run -it --image=nicolaka/netshoot sh #启动
```