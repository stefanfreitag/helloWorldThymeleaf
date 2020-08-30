# Steps from Java Source Code to K8s service

## Source code

- Build the project

```sh
$ ./gradlew build

BUILD SUCCESSFUL in 1s
5 actionable tasks: 5 up-to-date
```

## Building the image

- Build and tag the Docker image

```sh
❯ docker build -t hello-world-thymeleaf .
Sending build context to Docker daemon   16.1MB
Step 1/11 : FROM gradle:jdk11 AS builder
 ---> 95637c863244
Step 2/11 : WORKDIR /home/root/build/
 ---> Using cache
 ---> 0adf19ca6189
Step 3/11 : COPY . .
 ---> 240e37efc0d3
Step 4/11 : RUN gradle build -x test
 ---> Running in e2ff6ce52c53

Welcome to Gradle 6.5!

Here are the highlights of this release:
 - Experimental file-system watching
 - Improved version ordering
 - New samples

For more details see https://docs.gradle.org/6.5/release-notes.html

Starting a Gradle Daemon (subsequent builds will be faster)
> Task :compileJava
> Task :processResources
> Task :classes
> Task :bootJar
> Task :jar SKIPPED
> Task :assemble
> Task :spotlessJava
> Task :spotlessJavaCheck
> Task :spotlessMisc
> Task :spotlessMiscCheck
> Task :spotlessCheck
> Task :check
> Task :build

BUILD SUCCESSFUL in 1m 7s
7 actionable tasks: 7 executed
Removing intermediate container e2ff6ce52c53
 ---> 8d5d003d2fd0
Step 5/11 : FROM openjdk:11-jre-slim
 ---> 030d68516e3a
Step 6/11 : RUN useradd --create-home --shell /bin/bash stefan
 ---> Using cache
 ---> 96065b7a5b89
Step 7/11 : WORKDIR /home/stefan
 ---> Using cache
 ---> a852795cc7ea
Step 8/11 : COPY --from=builder /home/root/build/build/libs/*.jar /home/stefan/helloWorldThymeleaf.jar
 ---> 4543a832e0c6
Step 9/11 : USER stefan
 ---> Running in f6ba7fbe68f9
Removing intermediate container f6ba7fbe68f9
 ---> 2987e6b524aa
Step 10/11 : ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/home/stefan/helloWorldThymeleaf.jar"]
 ---> Running in 5f08f220c2d3
Removing intermediate container 5f08f220c2d3
 ---> 0890e7608fe9
Step 11/11 : EXPOSE 8080
 ---> Running in 9ba01baff459
Removing intermediate container 9ba01baff459
 ---> adb472c08285
Successfully built adb472c08285
Successfully tagged hello-world-thymeleaf:latest
```
## Local testing

- Spin up an instance of the image and set the active profile.

```sh
$ docker run -e "SPRING_PROFILES_ACTIVE=production" -p 8080:8080 -t hello-world-thymeleaf:latest

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.3.3.RELEASE)

2020-08-30 17:26:43.115  INFO 1 --- [           main] d.f.s.h.HelloWorldThymeleafApplication   : Starting HelloWorldThymeleafApplication on bc704380158b with PID 1 (/home/stefan/helloWorldThymeleaf.jar started by stefan in /home/stefan)
2020-08-30 17:26:43.122  INFO 1 --- [           main] d.f.s.h.HelloWorldThymeleafApplication   : The following profiles are active: production
2020-08-30 17:26:45.203  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
2020-08-30 17:26:45.222  INFO 1 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2020-08-30 17:26:45.223  INFO 1 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.37]
2020-08-30 17:26:45.348  INFO 1 --- [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2020-08-30 17:26:45.348  INFO 1 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 2082 ms                         
```

## Pushing the image

- Login to the registry

```sh
$ docker login
Authenticating with existing credentials...
WARNING! Your password will be stored unencrypted in /home/stefan/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

- Tag the container image

```sh
❯ docker tag 8042e539e388 stefanfreitag/hello-world-thymeleaf:0.0.2
```

- Push the image 

```sh
$ docker push stefanfreitag/hello-world-thymeleaf:0.0.2

The push refers to repository [docker.io/stefanfreitag/hello-world-thymeleaf]
4c4b2faf6360: Pushed 
fa8e63d09b3e: Layer already exists 
65be02c43d23: Layer already exists 
9fc268fda517: Layer already exists 
94cf29cec5e1: Layer already exists 
13cb14c2acd3: Layer already exists 
0.0.2: digest: sha256:c6c2b0f4613c9a6058914a932b2df13d6df596b0de4cd52a44cb48e30039a72b size: 1579
``` 

## From Docker-Compose to Kubernetes yaml

```sh
$ kompose convert
INFO Network backend is detected at Source, shall be converted to equivalent NetworkPolicy at Destination 
INFO Kubernetes file "hello-world-service.yaml" created 
INFO Kubernetes file "hello-world-deployment.yaml" created 
INFO Kubernetes file "backend-networkpolicy.yaml" created 
  
```

## Kubernetes Cluster using kind

- Create the cluster
```sh
$ kind create cluster --config kind-config.yaml
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.18.2) 🖼 
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
```

## Deploying the application

- Listing existing services and deployments
```sh
$ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   93s

$ kubectl get deployments
No resources found in default namespace.
```

- Applying service and deployment yaml files

```sh
$ kubectl apply -f hello-world-service.yaml
service/hello-world created

$ kubectl apply -f hello-world-deployment.yaml
```

- Listing services and deployments

```sh
$ kubectl get services
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
hello-world   ClusterIP   10.101.32.145   <none>        8080/TCP   15s
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP    3m10s

$ kubectl get deployments
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
hello-world   1/1     1            1           34s
```

- Get deployment pod and use it for port forwarding

```sh
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
hello-world-6847b486fc-b2xng   1/1     Running   0          2m15s

$ kubectl port-forward hello-world-6847b486fc-b2xng 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

## Links
* [DockerHub](https://hub.docker.com/)
* [Kompose](https://kompose.io/)

