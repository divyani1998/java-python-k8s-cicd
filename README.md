## CI/CD Pipeline Implementation & Design Decisions

### Overview

This project demonstrates an end-to-end **CI/CD pipeline for a Java application**, integrating code quality, containerization, security scanning, container image publishing, and Kubernetes deployment.

The pipeline is implemented using **GitHub Actions** and runs on a **self-hosted Ubuntu runner**.

### Tools & Technologies Used

The pipeline uses the following tools:

* **GitHub** – Source code management and version control
* **GitHub Actions** – CI/CD pipeline automation
* **Self-hosted Ubuntu Runner** – Executes the CI/CD jobs
* **Java 17 / Maven** – Application build and packaging
* **SonarQube** – Static code quality analysis
* **Docker** – Application containerization
* **Docker Hub** – Container image registry
* **Trivy** – Container vulnerability and secret scanning
* **Minikube** – Local Kubernetes environment for deployment demonstration
* **Kubernetes** – Container orchestration
* **Helm** – Kubernetes application deployment and release management

---

## CI/CD Pipeline Flow

The overall pipeline follows this flow:

```text
Developer
    |
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    v
Self-Hosted Ubuntu Runner
    |
    +----> Checkout Source Code
    |
    +----> Java 17 + Maven Build & Test
    |
    +----> SonarQube Code Quality Analysis
    |
    +----> Docker Image Build
    |
    +----> Trivy Security Scan
    |
    +----> Push Docker Image to Docker Hub
    |
    +----> Start / Verify Minikube
    |
    +----> Create Kubernetes Image Pull Secret
    |
    +----> Helm Deployment
    |
    +----> Kubernetes Deployment Validation
    |
    v
Application Running on Kubernetes
```

---

## Why Docker Hub Instead of Artifactory?

For this project, **Docker Hub is used as the container image registry instead of JFrog Artifactory**.

### Reason

This project is primarily a **CI/CD demonstration**, and Docker Hub provides a simple and lightweight way to demonstrate the complete container lifecycle:

```text
Build → Scan → Push → Pull → Deploy
```

Using Docker Hub avoids introducing additional Artifactory infrastructure and configuration requirements for this demo.

In an enterprise environment, the same pipeline can be adapted to use:

* JFrog Artifactory
* Amazon ECR
* Azure Container Registry
* GitHub Container Registry
* Other enterprise container registries

The pipeline design remains essentially the same; only the authentication and image registry configuration changes.

---

## Docker Image Versioning

Docker images are tagged using the **Git commit SHA**:

```text
<dockerhub-username>/hello-java:<GITHUB_SHA>
```

For example:

```text
sahud12/hello-java:2ba153327fa0e5c0cb7c6022762f063387c27390
```

### Why Git SHA?

Using the commit SHA provides an immutable and traceable image version.

It allows us to identify:

* Which source-code commit produced the image
* Which image was deployed to Kubernetes
* Which version needs to be rolled back if required

This is preferable to relying only on tags such as:

```text
latest
dev
test
```

because those tags can point to different images over time.

---

## Docker Hub Authentication

Docker Hub credentials are stored securely as **GitHub Actions Secrets**.

The pipeline uses:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

The token is used instead of storing the Docker Hub password directly.

The pipeline authenticates using the Docker Login Action before building and pushing the image.

---

## Security Scanning with Trivy

After the Docker image is built, **Trivy** scans the image for:

* Operating system vulnerabilities
* Application/library vulnerabilities
* Go binary vulnerabilities
* Java dependencies
* Python packages
* Secrets

Example scan result:

```text
Target                         Vulnerabilities
------------------------------------------------
Ubuntu                         0
Java application               0
Python packages                0
Go binary                      8 HIGH
```

### Demo Pipeline Behavior

For this demonstration, vulnerabilities are **reported but do not block the remaining CI/CD flow**.

This allows the complete pipeline to be demonstrated even when the image contains vulnerabilities.

In a production DevSecOps implementation, the policy can be changed to fail the pipeline based on defined severity thresholds, for example:

```text
CRITICAL → Fail pipeline
HIGH     → Fail pipeline
MEDIUM   → Warning
LOW      → Informational
```

This provides flexibility to implement different security gates based on organizational requirements.

---

## Kubernetes Deployment

The application is deployed to a local Kubernetes cluster using **Minikube**.

Minikube is used because this project is intended as a demonstration environment and provides a lightweight Kubernetes cluster without requiring a cloud Kubernetes service.

In an enterprise environment, the same Helm deployment approach can be used with:

* Amazon EKS
* Azure AKS
* Google GKE
* OpenShift
* Other Kubernetes clusters

---

## Why Helm?

The application is deployed using **Helm** instead of directly applying individual Kubernetes YAML files.

Helm provides:

* Reusable Kubernetes templates
* Parameterized configuration
* Easy image version updates
* Consistent deployments
* Environment-specific configuration
* Simple upgrade and rollback capabilities

The pipeline dynamically passes the Docker image repository and Git commit SHA:

```bash
helm upgrade --install hello-java ./helm/hello-java \
  --set image.repository="<dockerhub-username>/hello-java" \
  --set image.tag="${GITHUB_SHA}"
```

This means the Kubernetes deployment automatically uses the exact Docker image generated by the current pipeline execution.

---

## Kubernetes Image Pull Secret

Because the Docker Hub repository can be private, the pipeline creates a Kubernetes Docker registry secret:

```text
dockerhub-secret
```

The secret allows Kubernetes to authenticate with Docker Hub and pull the application image.

The credentials are supplied from GitHub Actions Secrets rather than being hard-coded in the repository.

---

## Deployment Validation

After Helm deployment, the pipeline validates the Kubernetes deployment using:

```bash
kubectl get pods
kubectl get services
kubectl rollout status deployment/hello-java --timeout=120s
```

The rollout status ensures that the application deployment successfully reaches the expected running state.

---

## Self-Hosted GitHub Actions Runner

The workflow runs on:

```yaml
runs-on: self-hosted
```

A self-hosted Ubuntu machine is used as the GitHub Actions runner.

The runner contains the required tools such as:

* Docker
* Maven
* kubectl
* Helm
* Minikube
* Trivy
* GitHub Actions Runner

### Why Self-Hosted Runner?

A self-hosted runner provides greater control over:

* Installed tools
* Docker environment
* Kubernetes/Minikube access
* Network configuration
* Custom enterprise requirements

For this demo, it also allows the pipeline to directly interact with the local Docker and Minikube environment.

---

## End-to-End CI/CD Lifecycle

The implemented pipeline follows a typical DevSecOps lifecycle:

```text
SOURCE
  ↓
GitHub
  ↓
BUILD
  ↓
Maven
  ↓
CODE QUALITY
  ↓
SonarQube
  ↓
CONTAINERIZE
  ↓
Docker
  ↓
SECURITY SCAN
  ↓
Trivy
  ↓
PUBLISH
  ↓
Docker Hub
  ↓
DEPLOY
  ↓
Helm + Kubernetes
  ↓
VALIDATE
  ↓
Application Running
```

---

## Key DevSecOps Practices Demonstrated

This project demonstrates the following practices:

* CI/CD automation using GitHub Actions
* Self-hosted runner implementation
* Automated Maven build
* Automated code quality analysis
* Docker image creation
* Container vulnerability scanning
* Secret scanning
* Secure registry authentication
* Immutable Docker image tagging
* Container image publishing
* Kubernetes deployment automation
* Helm-based deployments
* Kubernetes rollout validation
* Separation of credentials from source code using GitHub Secrets

---

## Production Enhancement Opportunities

The current implementation is designed primarily for demonstration purposes. For a production implementation, the following enhancements could be added:

* Use an enterprise registry such as **JFrog Artifactory or Amazon ECR**
* Configure Trivy as a blocking security gate for Critical/High vulnerabilities
* Add SAST, SCA and DAST stages
* Add SBOM generation
* Implement image signing and verification
* Add Kubernetes security scanning
* Deploy to managed Kubernetes such as EKS/AKS/GKE
* Implement environment promotion: Dev → QA → UAT → Production
* Add manual approval gates
* Implement Helm rollback strategy
* Add Prometheus and Grafana monitoring
* Add centralized logging
* Implement GitOps using Argo CD
* Add deployment notifications
* Implement automated rollback on failed deployments

---

## Summary

The project demonstrates how a Java application can move from **source code to a running Kubernetes deployment through an automated DevSecOps pipeline**.

The primary flow is:

**GitHub → GitHub Actions → Maven → SonarQube → Docker → Trivy → Docker Hub → Minikube/Kubernetes → Helm → Application**

Docker Hub is intentionally used as the registry for this demonstration to keep the setup simple. The architecture can easily be extended to an enterprise registry such as JFrog Artifactory or a cloud container registry without changing the fundamental CI/CD workflow.
