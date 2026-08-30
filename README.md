# Java + Python Kubernetes CI/CD

Minimal DevOps demonstration project using GitHub Actions,
Docker, SonarQube, container security scanning, Artifactory,
Helm and Minikube.

## Architecture

GitHub
   |
   v
GitHub Actions
   |
   v
Self-hosted Ubuntu Runner
   |
   +--> Maven Build
   |
   +--> SonarQube
   |
   +--> Docker Build
   |
   +--> Security Scan
   |
   +--> Artifactory
   |
   v
Minikube
   |
   v
Helm
   |
   v
Java Application

## Application

The application is a minimal Java HTTP server.

It listens on port 8080 and returns:

Hello World from Java + Kubernetes!

## Docker Image

The Docker image contains:

- Java 17 runtime
- Python 3
- Python virtual environment
- Java application

## CI/CD Flow

1. Checkout source code
2. Build Java application using Maven
3. Run SonarQube analysis
4. Build Docker image
5. Scan Docker image for vulnerabilities
6. Login to Artifactory
7. Push Docker image
8. Start Minikube
9. Create Kubernetes image pull secret
10. Deploy using Helm
11. Validate Kubernetes deployment

## Image Tagging

Docker images are tagged using the Git commit SHA.

Example:

hello-java:8a3c91f...

This avoids using only the `latest` tag and allows a specific
version of the image to be deployed.

## Kubernetes

The application is deployed using a Helm chart.

The chart contains:

- Deployment
- Service
- Image pull secret configuration
- Readiness probe
- Liveness probe

## Required GitHub Secrets

The following repository secrets are required:

REGISTRY
REGISTRY_USERNAME
REGISTRY_PASSWORD
SONAR_TOKEN

Example:

REGISTRY=<VM-IP>:<REGISTRY-PORT>

## Local Testing

Build the application:

mvn clean package

Build the Docker image:

docker build -t hello-java:local .

Run the container:

docker run -p 8080:8080 hello-java:local

Test:

curl http://localhost:8080

## Kubernetes Testing

Start Minikube:

minikube start --driver=docker

Deploy:

helm upgrade --install hello-java ./helm/hello-java

Check pods:

kubectl get pods

Check service:

kubectl get service hello-java
