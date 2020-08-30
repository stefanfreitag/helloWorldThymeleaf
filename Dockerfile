FROM gradle:jdk11 AS builder
WORKDIR /home/root/build/
COPY . .
RUN gradle build -x test

FROM openjdk:11-jre-slim
RUN useradd --create-home --shell /bin/bash stefan
WORKDIR /home/stefan
COPY --from=builder /home/root/build/build/libs/*.jar /home/stefan/helloWorldThymeleaf.jar
USER stefan
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/home/stefan/helloWorldThymeleaf.jar"]

EXPOSE 8080
