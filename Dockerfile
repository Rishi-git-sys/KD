
# Stage 1: Build Java application
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY java-app/pom.xml .
COPY java-app/src src

RUN mvn -B -DskipTests package

# Stage 2: Java + Python runtime
FROM eclipse-temurin:17-jre-jammy

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies in an isolated environment
COPY python-analysis/requirements.txt /tmp/requirements.txt

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir \
    -r /tmp/requirements.txt

# Copy Java application
COPY --from=build /app/target/job-portal-1.1.0.jar app.jar

# Copy Python analytics
COPY python-analysis/ /python-analysis/

ENV PYTHON_PATH=/opt/venv/bin/python
ENV ANALYSIS_OUTPUT=/python-analysis/output

EXPOSE 8080


RUN mkdir -p /python-analysis/output
CMD ["java", "-jar", "app.jar"]
