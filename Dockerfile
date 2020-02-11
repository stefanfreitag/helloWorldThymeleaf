FROM amazoncorretto:11.0.6
ENV ARTIFACT_VERSION=0.0.1-SNAPSHOT
ENV ARTIFACT_NAME=helloWorldThymeleaf-$ARTIFACT_VERSION.jar
ENV APP_HOME=/usr/app/
WORKDIR $APP_HOME
COPY build/libs/$ARTIFACT_NAME .
CMD java -jar $ARTIFACT_NAME
EXPOSE 8080
