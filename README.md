# Java CI/CD with Maven, SonarQube and Ansible VM Deployment

## 📌 Project Overview

This project demonstrates an end-to-end **Java CI/CD pipeline using GitHub Actions**, where a Java application is built with Maven, analyzed with SonarQube, and deployed as a JAR using **Ansible**.

For this demo, we are intentionally using a **GitHub-hosted Ubuntu runner as the deployment target** instead of maintaining a separate Linux VM.

This allows us to demonstrate Ansible-based VM deployment without requiring additional cloud infrastructure.

> **Note:** Using the GitHub-hosted runner itself as the deployment target is intended for demonstration and learning purposes. In a production environment, Ansible would normally connect from the CI runner/control node to a persistent Linux VM or server.

---

# 🔄 CI/CD Flow

```text
Developer
    │
    │ Push code
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ├── 1. Checkout Java source code
    │
    ├── 2. Setup Java 17
    │
    ├── 3. Maven Build & Unit Tests
    │
    ├── 4. SonarQube Code Quality Analysis
    │
    ├── 5. Install / Verify Ansible
    │
    ├── 6. Configure Ansible
    │
    ├── 7. Ansible Connectivity Test
    │
    ├── 8. Deploy JAR using Ansible
    │
    ├── 9. Configure systemd service
    │
    └── 10. Validate Application
    │
    ▼
Java Application Running
on GitHub-hosted Ubuntu Runner
```

---

# 🏗️ Architecture

```text
                   GitHub Repository
                          │
                          │ Push / Manual Trigger
                          ▼
                 GitHub Actions Workflow
                          │
                          ▼
                GitHub-hosted Ubuntu Runner
                          │
          ┌───────────────┼────────────────┐
          │               │                │
          ▼               ▼                ▼
       Maven          SonarQube          Ansible
     Build/Test      Code Analysis      Deployment
          │                                │
          │                                ▼
          │                         Local Target
          │                         java_vm
          │                                │
          │                                ▼
          │                         Copy JAR File
          │                                │
          │                                ▼
          │                         systemd Service
          │                                │
          └────────────────────────────────┘
                                           │
                                           ▼
                                   Java Application
```

---

# 🛠️ Technologies Used

| Technology                  | Purpose                                   |
| --------------------------- | ----------------------------------------- |
| GitHub                      | Source code management                    |
| GitHub Actions              | CI/CD automation                          |
| GitHub-hosted Ubuntu Runner | CI environment and demo deployment target |
| Java 17                     | Application runtime                       |
| Maven                       | Build and test automation                 |
| SonarQube                   | Static code quality analysis              |
| Ansible                     | Application deployment automation         |
| systemd                     | Java application service management       |
| YAML                        | GitHub Actions and Ansible configuration  |

---

# 📁 Project Structure

```text
java-python-k8s-cicd/
│
├── .github/
│   └── workflows/
│       └── ansible-vm-deployment.yml
│
├── ansible/
│   ├── inventory/
│   │   └── hosts.yml
│   │
│   ├── templates/
│   │   └── hello-java.service.j2
│   │
│   ├── deploy.yml
│   └── README.md
│
├── src/
│   └── ...
│
├── pom.xml
│
└── README.md
```

---

# 🚀 CI/CD Process

## 1. Source Code Checkout

The workflow starts by checking out the Java application source code from the GitHub repository.

```yaml
- uses: actions/checkout@v4
```

This makes the application source available inside the GitHub-hosted Ubuntu runner.

---

## 2. Configure Java

Java 17 is configured using GitHub Actions.

```yaml
- uses: actions/setup-java@v4
```

The workflow uses the Eclipse Temurin JDK distribution.

---

## 3. Maven Build and Test

Maven is used to compile the Java application, execute tests, and generate the JAR file.

```bash
mvn clean package
```

The resulting artifact is:

```text
target/hello-java-1.0.0.jar
```

This JAR becomes the deployment artifact for the Ansible deployment stage.

---

# 🔍 4. SonarQube Analysis

The generated Java project is analyzed using SonarQube.

The workflow starts a temporary SonarQube instance inside the GitHub-hosted runner using Docker.

The SonarQube server is accessed through:

```text
http://localhost:9000
```

The workflow passes the SonarQube authentication token through a GitHub Actions secret.

Example:

```text
SONAR_TOKEN
SONAR_HOST_URL
```

Since this is a demonstration project, SonarQube data does not need to persist between workflow executions.

---

# ⚙️ 5. Install Ansible

Ansible is installed directly on the GitHub-hosted Ubuntu runner.

```bash
sudo apt-get update
sudo apt-get install -y ansible
```

The runner therefore acts as the **Ansible control node**.

---

# 🎯 6. GitHub-hosted Runner as Deployment Target

Normally, Ansible follows this architecture:

```text
Ansible Control Node
        │
        │ SSH
        ▼
Linux VM
```

For this demo, we simplify the architecture:

```text
GitHub-hosted Ubuntu Runner
          │
          │ Ansible local connection
          ▼
Same GitHub-hosted Ubuntu Runner
```

The inventory therefore defines the target as a local host:

```yaml
all:
  hosts:
    java_vm:
      ansible_connection: local
```

Here:

* `java_vm` is the Ansible inventory hostname.
* `ansible_connection: local` tells Ansible not to use SSH.
* Ansible executes the deployment tasks directly on the GitHub-hosted runner.

This eliminates the requirement for a separate VM for this demonstration.

---

# 📋 7. Ansible Inventory

The inventory is located at:

```text
ansible/inventory/hosts.yml
```

Example:

```yaml
all:
  hosts:
    java_vm:
      ansible_connection: local
```

The name `java_vm` is then used by the Ansible playbook:

```yaml
hosts: java_vm
```

The same hostname is also used for the Ansible connectivity test.

---

# 🔗 8. Ansible Connectivity Test

Before deployment, the workflow verifies that Ansible can communicate with the target.

```bash
ansible \
  -i ansible/inventory/hosts.yml \
  java_vm \
  -m ping
```

Expected result:

```text
java_vm | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

This confirms that Ansible is correctly configured and can execute tasks against the local runner.

---

# 📦 9. JAR Deployment Using Ansible

After the Maven build, the JAR file is available in:

```text
target/hello-java-1.0.0.jar
```

The Ansible playbook performs the deployment.

Typical deployment tasks include:

1. Create the application directory.
2. Copy the generated JAR.
3. Configure the application service.
4. Create/update the systemd service.
5. Start or restart the Java application.
6. Enable the service if required.
7. Verify the application status.

The deployment is automated through:

```bash
ansible-playbook \
  -i ansible/inventory/hosts.yml \
  ansible/deploy.yml
```

---

# 🧩 10. systemd Service

Ansible uses a Jinja2 template to create the Java systemd service.

Template:

```text
ansible/templates/hello-java.service.j2
```

The resulting service is:

```text
hello-java.service
```

This allows the Java application to be managed using standard Linux service commands.

For example:

```bash
systemctl status hello-java
```

The service can also be restarted or stopped using:

```bash
systemctl restart hello-java
systemctl stop hello-java
systemctl start hello-java
```

---

# ✅ 11. Deployment Validation

After Ansible completes the deployment, the workflow validates the service.

Example:

```bash
systemctl is-active --quiet hello-java
```

If the service is running successfully, the CI/CD pipeline completes successfully.

---

# 🔐 GitHub Actions Secrets

Sensitive values should not be hardcoded in the workflow.

The project uses GitHub Actions Secrets for sensitive configuration such as:

```text
SONAR_TOKEN
SONAR_HOST_URL
```

Secrets are referenced using:

```yaml
${{ secrets.SECRET_NAME }}
```

This prevents sensitive credentials from being stored directly in the repository.

---

# 🔄 Complete Pipeline

The complete pipeline can be summarized as:

```text
1. Developer pushes Java code
             │
             ▼
2. GitHub Actions starts
             │
             ▼
3. Checkout source code
             │
             ▼
4. Configure Java 17
             │
             ▼
5. Maven clean package
             │
             ├── Compile
             ├── Unit Tests
             └── Generate JAR
             │
             ▼
6. Start temporary SonarQube
             │
             ▼
7. SonarQube analysis
             │
             ▼
8. Install / verify Ansible
             │
             ▼
9. Ansible ping
             │
             ▼
10. Ansible deployment
             │
             ├── Create application directory
             ├── Copy JAR
             ├── Configure systemd
             ├── Restart service
             └── Enable service
             │
             ▼
11. Validate hello-java service
             │
             ▼
12. Deployment successful
```

---

# 💡 Why Ansible Is Used

Ansible provides a consistent and repeatable way to automate server/application deployment.

Instead of manually executing:

```bash
cp hello-java.jar /opt/hello-java/
systemctl restart hello-java
```

the deployment is described as code inside an Ansible playbook.

This provides:

* Repeatable deployments
* Infrastructure/application automation
* Reduced manual intervention
* Configuration as code
* Easy integration with CI/CD
* Idempotent deployment operations

---

# 🆚 Previous Docker/Kubernetes Approach vs Current Ansible Approach

The repository was initially designed around containerized deployment using Docker and Kubernetes.

For this branch, the deployment model was simplified to demonstrate traditional VM/JAR deployment using Ansible.

### Previous approach

```text
Java
 │
 ▼
Maven
 │
 ▼
Docker Image
 │
 ▼
Docker Hub
 │
 ▼
Kubernetes
 │
 ▼
Helm
 │
 ▼
Application
```

### Current Ansible approach

```text
Java
 │
 ▼
Maven
 │
 ▼
JAR
 │
 ▼
Ansible
 │
 ▼
Linux Environment
 │
 ▼
systemd
 │
 ▼
Java Application
```

The Docker build, Docker image scan, Docker Hub push, Kubernetes, Minikube and Helm deployment stages are therefore not required for this VM deployment flow.

---

# 🎯 Purpose of This Demo

The primary objective of this branch is to demonstrate:

* Java CI/CD using GitHub Actions
* Maven-based application build
* Automated unit testing
* SonarQube code quality analysis
* Ansible installation and configuration
* Ansible inventory management
* Ansible playbook-based application deployment
* JAR deployment
* Linux systemd service management
* Deployment validation
* GitHub-hosted runner usage as a temporary deployment environment

---

# ⚠️ Production Consideration

Using a GitHub-hosted runner as both the CI environment and deployment target is suitable for this demonstration because the runner is temporary and the objective is to demonstrate the Ansible deployment process.

In a production architecture, the recommended model would be:

```text
GitHub Actions Runner
        │
        │ SSH / WinRM
        ▼
Persistent Application VM
        │
        ▼
Java Application
```

The Ansible inventory would then contain the actual VM hostname/IP, and Ansible would remotely deploy the application.

---

# 📌 Key Learning

This project demonstrates how a CI/CD pipeline can move an application through the complete lifecycle:

```text
Source Code
     ↓
Build
     ↓
Test
     ↓
Code Quality
     ↓
Artifact (JAR)
     ↓
Ansible Automation
     ↓
VM Deployment
     ↓
Service Validation
```

The key concept is **build once, deploy the generated artifact using automation** rather than rebuilding the application during deployment.
