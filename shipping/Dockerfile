FROM java:openjdk-8-alpine

WORKDIR /usr/src/shipping

COPY . /usr/src/shipping
RUN ./mvnw -DskipTests clean package
RUN mv ./target/*.jar ./target/app.jar

EXPOSE 80

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/usr/src/shipping/target/app.jar"]