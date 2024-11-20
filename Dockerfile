FROM eclipse-temurin:17-jre

WORKDIR /app

COPY target/starter.jar starter.jar
COPY target/smt-simulation-processor.jar smt-simulation-processor.jar
COPY faaast-config.json faaast-config.json

CMD ["java", "-jar", "starter.jar", "--config", "/app/faaast-config.json"]