


#### search helm online
take superset as instance 
https://superset.apache.org/docs/installation/kubernetes
```bash
# add helm repo of superset
helm repo add superset https://apache.github.io/superset

# search superset
$ helm search repo superset
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
superset/superset       0.14.2          4.1.2           Apache Superset is a modern, enterprise-ready b...

# download template
$ helm pull superset/superset --untar --version 0.14.2

# output all resources without installing them
$ helm template superset superset/superset --values superset/values.yaml --namespace superset

```