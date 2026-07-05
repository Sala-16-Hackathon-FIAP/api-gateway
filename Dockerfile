FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml ./
RUN mvn dependency:go-offline -B -q
COPY src ./src
RUN mvn clean package -DskipTests -B -q

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
COPY --from=build /app/target/newrelic/newrelic.jar newrelic/newrelic.jar
COPY newrelic.yml newrelic/newrelic.yml
EXPOSE 8081

ENTRYPOINT ["java", \
  "-javaagent:/app/newrelic/newrelic.jar", \
  "-Dnewrelic.config.file=/app/newrelic/newrelic.yml", \
  "-jar", "/app/app.jar"]
