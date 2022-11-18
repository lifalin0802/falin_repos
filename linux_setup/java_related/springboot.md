
### 命令方式启动：
```bash
java -jar springboot-01-helloworld-1.0-SNAPSHOT.jar --spring.output.ansi.enabled=NEVER
```


### dockerfile 捏取镜像：
```dockerfile
#FROM java:8-jre-alpine
FROM openjdk:8u302-jdk
RUN mkdir -p /data/app
ARG JAVA_OPTS
RUN echo ${JAVA_OPTS} 
ENV JAVA_OPTS ${JAVA_OPTS}

COPY ./springboot-01-helloworld-1.0-SNAPSHOT.jar /data/app/hello.jar
EXPOSE 8080
WORKDIR /data/app
ENTRYPOINT ["java","-jar","/data/app/hello.jar","-Xshare:off","--spring.output.ansi.enabled=ALWAYS"]
```

### 编译镜像：
```bash
docker build -t hellojava:1 .
docker build --build-arg JAVA_OPTS='-Xms512m -Xmx2g -Xss256k -XX:+UseG1GC' -t hellojava:5 .
docker tag hellojava:ansi yldc-docker.pkg.coding.yili.com/pubrepo/pubdocker/hellojava:ansi 

```

### deployment 这样写：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hellojava
  namespace: wx-yrcrm-uat 
  labels:
    app: hellojava  
spec:  
  replicas: 1
  selector:
    matchLabels:
      app: hellojava 
  template:
    metadata:
      labels:
        app: hellojava
    spec:
      containers:
      - name: hellojava
        image: yldc-docker.pkg.coding.yili.com/pubrepo/pubdocker/hellojava:1
        imagePullPolicy: IfNotPresent    
        command: ["java","-jar","/data/app/hello.jar","-Xshare:off"]
        args: ["--spring.output.ansi.enabled=NEVER"]
        ports:
          - containerPort: 8090     
```

或者这样：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hellojava
  namespace: wx-yrcrm-uat 
  labels:
    app: hellojava  
spec:  
  replicas: 1
  selector:
    matchLabels:
      app: hellojava 
  template:
    metadata:
      labels:
        app: hellojava
    spec:
      containers:
      - name: hellojava
        image: yldc-docker.pkg.coding.yili.com/pubrepo/pubdocker/hellojava:1
        imagePullPolicy: IfNotPresent
        command: ["/bin/sh"]
        args: ["-ec", "exec java -Xshare:off -jar /data/app/hello.jar -Dspring.output.ansi.enabled=NEVER"]
        ports:
        - containerPort: 8090

```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hellojava
  namespace: wx-yrcrm-uat 
  labels:
    app: hellojava  
spec:  
  replicas: 1
  selector:
    matchLabels:
      app: hellojava 
  template:
    metadata:
      labels:
        app: hellojava
    spec:
      containers:
      - name: hellojava
        image: yldc-docker.pkg.coding.yili.com/pubrepo/pubdocker/hellojava:ansi
        imagePullPolicy: IfNotPresent    
        env:
        - name: JAVA_TOOL_OPTIONS   #work ！！
          value: -Dspring.output.ansi.enabled=never 
        #- name: SPRING_OUTPUT_ANSI_ENABLED  #work ！！
        #  value: never
        ports:
          - containerPort: 8090 
```


```bash
k apply -f deploy.yaml.2
k exec -it hellojava-c67858776-jhstf  -n wx-yrcrm-uat -- bash
```


JAVA_TOOL_OPTIONS  
JAVA_OPTS 都不好使
优先级：
k8s command > dockerfile >  k8s env > application.properties > application.yml
application.properties  application.yml 中的spring.outptut.ansi.enabled 不出现env中

