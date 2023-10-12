FROM maven:3.9.4-eclipse-temurin-17-alpine as build

WORKDIR /app
COPY . /app
RUN mvn clean install

FROM eclipse-temurin:17-jre-alpine

COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
 