FROM java:openjdk-8-alpine

EXPOSE 80
WORKDIR /usr/src/accounts

COPY . /usr/src/accounts
RUN ./mvnw -DskipTests clean package
RUN mv ./target/*.jar ./target/app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","./target/app.jar", "--port=80"]
