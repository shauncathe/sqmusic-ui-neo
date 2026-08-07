# syntax=docker/dockerfile:1
#
# Embedded single-service build for SQmusic UI Neo.
# Clones the upstream Simple SQ Music Plus backend, bakes our single-file
# frontend (frontend/index.html) into the backend's static resources, then
# compiles and runs it. Result: ONE service serving both UI ("/") and API ("/api").

# ---- Build stage ----
FROM maven:3.9.4-eclipse-temurin-21 AS builder

# Upstream backend ref to embed the UI into. Override at build time:
#   docker compose build --build-arg BACKEND_REF=3.0
ARG BACKEND_REF=3.0
ARG BACKEND_REPO=https://github.com/59799517/simple_sq_music_plus.git

WORKDIR /build

# Shallow, sparse clone of the backend (only what we need to compile).
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    git clone --depth 1 --filter=blob:none --sparse --branch "${BACKEND_REF}" "${BACKEND_REPO}" repo && \
    cd repo && git sparse-checkout set src pom.xml && cd /build

# Embed the UI: replace the backend static index with our single-file frontend.
COPY frontend/index.html /build/repo/src/main/resources/static/index.html

# Build the backend JAR. Tests skipped for speed; drop -DskipTests in CI gating.
RUN cd /build/repo && mvn -q -DskipTests clean package

# ---- Runtime stage (mirrors upstream Dockerfile.main base) ----
FROM mcr.microsoft.com/openjdk/jdk:21-ubuntu

WORKDIR /app

COPY --from=builder /build/repo/target/*.jar /app/app.jar

EXPOSE 8099
VOLUME ["/music"]

ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
