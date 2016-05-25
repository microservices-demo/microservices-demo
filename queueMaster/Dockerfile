FROM java:openjdk-8-alpine

WORKDIR /usr/src/queue-master

COPY . /usr/src/queue-master
RUN ./mvnw -DskipTests clean package
RUN mv ./target/*.jar ./target/app.jar

EXPOSE 80

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/usr/src/queue-master/target/app.jar"]