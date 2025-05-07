FROM maven:3.8.6-openjdk-8-slim AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM openjdk:8-jre-alpine

WORKDIR /usr/src/app

ENV	SERVICE_USER=myuser \
	SERVICE_UID=10001 \
	SERVICE_GROUP=mygroup \
	SERVICE_GID=10001

RUN	addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} && \
	adduser -g "${SERVICE_NAME} user" -D -H -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER}

COPY --from=builder /app/target/*.jar app.jar

RUN chown -R ${SERVICE_USER}:${SERVICE_GROUP} ./app.jar

ENV JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1 -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom"

USER ${SERVICE_USER}
EXPOSE 80
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/urandom","-jar","./app.jar", "--port=80"]
