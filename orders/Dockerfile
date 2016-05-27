FROM java:openjdk-8-alpine

EXPOSE 80
WORKDIR /usr/src/app
COPY ./target/*.jar ./app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","./app.jar", "--port=80"]
