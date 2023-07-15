

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
[root@master01 ~]# kgp -A
NAMESPACE          NAME                                       READY   STATUS              RESTARTS        AGE     IP              NODE       NOMINATED NODE   READINESS GATES
calico-apiserver   calico-apiserver-7bbfc646c5-gd429          0/1     ContainerCreating   0               6m22s   <none>          node02     <none>           <none>
calico-apiserver   calico-apiserver-7bbfc646c5-pfh5v          0/1     ContainerCreating   0               6m22s   <none>          node02     <none>           <none>
calico-system      calico-kube-controllers-789dc4c76b-rfpmh   0/1     Running             0               6m24s   10.244.140.66   node02     <none>           <none>
calico-system      calico-node-7222w                          0/1     CrashLoopBackOff    6 (37s ago)     6m24s   192.168.5.140   master01   <none>           <none>
calico-system      calico-node-bzz7p                          0/1     Running             1 (4m50s ago)   6m24s   192.168.5.142   node02     <none>           <none>
calico-system      calico-typha-575b4cb7bf-jlfx7              1/1     Running             0               6m24s   192.168.5.140   master01   <none>           <none>
calico-system      csi-node-driver-2qg79                      2/2     Running             0               6m24s   10.244.241.64   master01   <none>           <none>
calico-system      csi-node-driver-gdmwk                      0/2     ContainerCreating   0               6m24s   <none>          node02     <none>           <none>
kube-system        coredns-7bdc4cb885-gmtpk                   1/1     Running             0               34m     10.244.140.67   node02     <none>           <none>
kube-system        coredns-7bdc4cb885-jxdnx                   1/1     Running             0               34m     10.244.140.64   node02     <none>           <none>
kube-system        etcd-master01                              1/1     Running             4 (61m ago)     3h9m    192.168.5.140   master01   <none>           <none>
kube-system        kube-apiserver-master01                    1/1     Running             10 (61m ago)    3h9m    192.168.5.140   master01   <none>           <none>
kube-system        kube-controller-manager-master01           1/1     Running             24 (45s ago)    3h9m    192.168.5.140   master01   <none>           <none>
kube-system        kube-proxy-g8xg5                           1/1     Running             1 (26m ago)     139m    192.168.5.142   node02     <none>           <none>
kube-system        kube-proxy-vtxvn                           1/1     Running             1 (61m ago)     3h9m    192.168.5.140   master01   <none>           <none>
kube-system        kube-scheduler-master01                    1/1     Running             17 (38s ago)    3h9m    192.168.5.140   master01   <none>           <none>
tigera-operator    tigera-operator-549d4f9bdb-j7rrj           0/1     CrashLoopBackOff    1 (80s ago)     11m     192.168.5.142   node02     <none>           <none>

```

```bash
k run -it --image=nicolaka/netshoot sh #启动
```