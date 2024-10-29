# Start with the official Flink image
FROM flink:1.18.1-java11

# Arguments for versions
ARG FLINK_VERSION=1.18.1
ARG PULSAR_VERSION=3.3.1
ARG SCALA_VERSION=2.12

# Environment variables
ENV FLINK_HOME=/opt/flink
ENV PULSAR_SQL_HOME=/opt/pulsar-sql

# Switch to root user for installations
USER root

# Install wget and other necessary tools
RUN apt-get update && \
    apt-get install -y wget curl && \
    rm -rf /var/lib/apt/lists/*

# Create directory for Pulsar SQL connector
RUN mkdir -p ${PULSAR_SQL_HOME}

# Download and install Pulsar SQL connector from Maven Central

RUN wget -P ${FLINK_HOME}/lib https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-pulsar/4.1.0-1.18/flink-sql-connector-pulsar-4.1.0-1.18.jar

# Download Pulsar client dependencies
RUN wget -P ${FLINK_HOME}/lib "https://repo1.maven.org/maven2/org/apache/pulsar/pulsar-client-all/${PULSAR_VERSION}/pulsar-client-all-${PULSAR_VERSION}.jar" \
    && wget -P ${FLINK_HOME}/lib "https://repo1.maven.org/maven2/org/apache/pulsar/pulsar-client-api/${PULSAR_VERSION}/pulsar-client-api-${PULSAR_VERSION}.jar" \
    && wget -P ${FLINK_HOME}/lib "https://repo1.maven.org/maven2/org/apache/pulsar/pulsar-client-admin-api/${PULSAR_VERSION}/pulsar-client-admin-api-${PULSAR_VERSION}.jar" 

# Add Flink Avro dependency (often needed with Pulsar)
RUN wget -P ${FLINK_HOME}/lib "https://repo1.maven.org/maven2/org/apache/flink/flink-avro/${FLINK_VERSION}/flink-avro-${FLINK_VERSION}.jar" 

RUN wget -P ${FLINK_HOME}/lib "https://repo1.maven.org/maven2/org/apache/flink/flink-json/${FLINK_VERSION}/flink-json-${FLINK_VERSION}.jar" 

# Add custom configuration if needed
#COPY conf/* ${FLINK_HOME}/conf/

# Create directory for user-specific jars
RUN mkdir -p ${FLINK_HOME}/usrlib && \
    chown -R flink:flink ${FLINK_HOME}/usrlib

# Set proper permissions
RUN chown -R flink:flink ${FLINK_HOME}/lib/ \
    && chown -R flink:flink ${PULSAR_SQL_HOME}/

# Switch back to flink user
USER flink

# Expose Flink UI port
EXPOSE 8081

# Start Flink
# CMD ["bash", "-c", "bin/start-cluster.sh; tail -f /dev/null"]