 ⚡ root@fli-mbp  /Users/lifalin/code/kube-prometheus-stack  k api-resources
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
componentstatuses                 cs           v1                                     false        ComponentStatus
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
limitranges                       limits       v1                                     true         LimitRange
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                     false        PersistentVolume
pods                              po           v1                                     true         Pod
podtemplates                                   v1                                     true         PodTemplate
replicationcontrollers            rc           v1                                     true         ReplicationController
resourcequotas                    quota        v1                                     true         ResourceQuota
secrets                                        v1                                     true         Secret
serviceaccounts                   sa           v1                                     true         ServiceAccount
services                          svc          v1                                     true         Service
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1                false        CustomResourceDefinition
apiservices                                    apiregistration.k8s.io/v1              false        APIService
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet
tokenreviews                                   authentication.k8s.io/v1               false        TokenReview
localsubjectaccessreviews                      authorization.k8s.io/v1                true         LocalSubjectAccessReview
selfsubjectaccessreviews                       authorization.k8s.io/v1                false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io/v1                false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io/v1                false        SubjectAccessReview
allowlistedv2workloads                         auto.gke.io/v1                         false        AllowlistedV2Workload
allowlistedworkloads                           auto.gke.io/v1                         false        AllowlistedWorkload
horizontalpodautoscalers          hpa          autoscaling/v2                         true         HorizontalPodAutoscaler
cronjobs                          cj           batch/v1                               true         CronJob
jobs                                           batch/v1                               true         Job
certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest
backendconfigs                    bc           cloud.google.com/v1                    true         BackendConfig
leases                                         coordination.k8s.io/v1                 true         Lease
endpointslices                                 discovery.k8s.io/v1                    true         EndpointSlice
events                            ev           events.k8s.io/v1                       true         Event
falconcontainers                               falcon.crowdstrike.com/v1alpha1        false        FalconContainer
flowschemas                                    flowcontrol.apiserver.k8s.io/v1beta2   false        FlowSchema
prioritylevelconfigurations                    flowcontrol.apiserver.k8s.io/v1beta2   false        PriorityLevelConfiguration
memberships                                    hub.gke.io/v1                          false        Membership
capacityrequests                  capreq       internal.autoscaling.gke.io/v1alpha1   true         CapacityRequest
capacityrequests                  capreq       internal.autoscaling.k8s.io/v1alpha1   true         CapacityRequest
collectorsets                                  logicmonitor.com/v1alpha1              true         CollectorSet
nodes                                          metrics.k8s.io/v1beta1                 false        NodeMetrics
pods                                           metrics.k8s.io/v1beta1                 true         PodMetrics
alertmanagerconfigs               amcfg        monitoring.coreos.com/v1alpha1         true         AlertmanagerConfig
alertmanagers                     am           monitoring.coreos.com/v1               true         Alertmanager
podmonitors                       pmon         monitoring.coreos.com/v1               true         PodMonitor
probes                            prb          monitoring.coreos.com/v1               true         Probe
prometheusagents                  promagent    monitoring.coreos.com/v1alpha1         true         PrometheusAgent
prometheuses                      prom         monitoring.coreos.com/v1               true         Prometheus
prometheusrules                   promrule     monitoring.coreos.com/v1               true         PrometheusRule
scrapeconfigs                     scfg         monitoring.coreos.com/v1alpha1         true         ScrapeConfig
servicemonitors                   smon         monitoring.coreos.com/v1               true         ServiceMonitor
thanosrulers                      ruler        monitoring.coreos.com/v1               true         ThanosRuler
frontendconfigs                                networking.gke.io/v1beta1              true         FrontendConfig
managedcertificates               mcrt         networking.gke.io/v1                   true         ManagedCertificate
serviceattachments                             networking.gke.io/v1                   true         ServiceAttachment
servicenetworkendpointgroups      svcneg       networking.gke.io/v1beta1              true         ServiceNetworkEndpointGroup
ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
ingresses                         ing          networking.k8s.io/v1                   true         Ingress
networkpolicies                   netpol       networking.k8s.io/v1                   true         NetworkPolicy
runtimeclasses                                 node.k8s.io/v1                         false        RuntimeClass
updateinfos                       updinf       nodemanagement.gke.io/v1alpha1         true         UpdateInfo
poddisruptionbudgets              pdb          policy/v1                              true         PodDisruptionBudget
clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole
rolebindings                                   rbac.authorization.k8s.io/v1           true         RoleBinding
roles                                          rbac.authorization.k8s.io/v1           true         Role
scalingpolicies                                scalingpolicy.kope.io/v1alpha1         true         ScalingPolicy
priorityclasses                   pc           scheduling.k8s.io/v1                   false        PriorityClass
volumesnapshotclasses                          snapshot.storage.k8s.io/v1             false        VolumeSnapshotClass
volumesnapshotcontents                         snapshot.storage.k8s.io/v1             false        VolumeSnapshotContent
volumesnapshots                                snapshot.storage.k8s.io/v1             true         VolumeSnapshot
csidrivers                                     storage.k8s.io/v1                      false        CSIDriver
csinodes                                       storage.k8s.io/v1                      false        CSINode
csistoragecapacities                           storage.k8s.io/v1                      true         CSIStorageCapacity
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass
volumeattachments                              storage.k8s.io/v1                      false        VolumeAttachment
audits                                         warden.gke.io/v1                       false        Audit
 ⚡ root@fli-mbp  /Users/lifalin/code/kube-prometheus-stack  k api-versions
admissionregistration.k8s.io/v1
apiextensions.k8s.io/v1
apiregistration.k8s.io/v1
apps/v1
authentication.k8s.io/v1
authorization.k8s.io/v1
auto.gke.io/v1
auto.gke.io/v1alpha1
autoscaling/v1
autoscaling/v2
autoscaling/v2beta2
batch/v1
certificates.k8s.io/v1
cloud.google.com/v1
cloud.google.com/v1beta1
coordination.k8s.io/v1
discovery.k8s.io/v1
events.k8s.io/v1
falcon.crowdstrike.com/v1alpha1
flowcontrol.apiserver.k8s.io/v1beta1
flowcontrol.apiserver.k8s.io/v1beta2
hub.gke.io/v1
internal.autoscaling.gke.io/v1alpha1
internal.autoscaling.k8s.io/v1alpha1
logicmonitor.com/v1alpha1
metrics.k8s.io/v1beta1
monitoring.coreos.com/v1
monitoring.coreos.com/v1alpha1
networking.gke.io/v1
networking.gke.io/v1beta1
networking.gke.io/v1beta2
networking.k8s.io/v1
node.k8s.io/v1
nodemanagement.gke.io/v1alpha1
policy/v1
rbac.authorization.k8s.io/v1
scalingpolicy.kope.io/v1alpha1
scheduling.k8s.io/v1
snapshot.storage.k8s.io/v1
snapshot.storage.k8s.io/v1beta1
storage.k8s.io/v1
storage.k8s.io/v1beta1
v1
warden.gke.io/v1