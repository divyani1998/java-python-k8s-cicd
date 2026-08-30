# Runtime image containing Java 17.
FROM eclipse-temurin:17-jre

# Install Python and the virtual-environment package.
RUN apt-get update && \
    apt-get install -y python3 python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment.
RUN python3 -m venv /opt/venv

# Make the virtual environment the default Python environment.
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Copy the Java application JAR.
COPY target/hello-java-1.0.0.jar app.jar

EXPOSE 8080

# Start the Java application.
ENTRYPOINT ["java", "-jar", "app.jar"]
