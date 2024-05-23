# DevOpsProject
Creating a project that integrates Ansible, Jenkins, Docker Desktop, Minikube, Maven, and Apache Tomcat involves several steps. Below is a detailed guide to set up a CI/CD pipeline using these tools.

### Prerequisites
1. **Install Ansible**: Follow the installation instructions from the [Ansible documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
2. **Install Jenkins**: Download and install Jenkins from the [official website](https://www.jenkins.io/download/).
3. **Install Docker Desktop**: Get Docker Desktop from the [Docker website](https://www.docker.com/products/docker-desktop/).
4. **Install Minikube**: Install Minikube by following the [Minikube start guide](https://minikube.sigs.k8s.io/docs/start/).
5. **Install Maven**: Install Maven from the [Apache Maven site](https://maven.apache.org/install.html).
6. **Install Apache Tomcat**: Download and set up Apache Tomcat from the [Tomcat website](https://tomcat.apache.org/download-90.cgi).

### Project Structure
Let's create a sample Java project that will be built using Maven, packaged into a Docker container, deployed on Minikube, and managed via Ansible and Jenkins.

### Step-by-Step Guide

### Installation and Configurations
1) Launch and Connect | EC2 | t2 medium | amazon linux 2023
Region | ap-south-1

```
// update machine
sudo yum update -y
// install python
// install java
sudo yum install jre
java --version
// install maven
sudo yum install maven -y
sudo yum install python -y
// install git
sudo yum install git -y
// configure git
git config --global user.name atulkamble
git config --global user.email "atul_kamble@hotmail.com"
// clone git project repo
git clone https://github.com/atulkamble/DevOpsProject.git
cd DevOpsProject
pwd
ls
// install docker
sudo yum install docker
sudo usermod -aG docker $USER && newgrp docker
sudo docker login
sudo systemctl start docker.service
// install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm
minikube start 
```



#### 1. Create a Maven Project
Create a simple Java web application with Maven.

**pom.xml**:
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>simple-webapp</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <build>
        <finalName>simple-webapp</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.3.1</version>
            </plugin>
        </plugins>
    </build>
</project>
```

**src/main/webapp/index.jsp**:
```jsp
<!DOCTYPE html>
<html>
<head>
    <title>Simple Web App</title>
</head>
<body>
    <h1>Hello, World!</h1>
</body>
</html>
```

#### 2. Dockerize the Application
Create a Dockerfile to containerize the web application.

**Dockerfile**:
```Dockerfile
FROM tomcat:9.0
COPY target/simple-webapp.war /usr/local/tomcat/webapps/
```

#### 3. Set Up Minikube
Start Minikube and create a Kubernetes deployment for the Dockerized application.

```sh
minikube start
```

Create a Kubernetes deployment and service.

**k8s-deployment.yml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-webapp-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: simple-webapp
  template:
    metadata:
      labels:
        app: simple-webapp
    spec:
      containers:
      - name: simple-webapp
        image: simple-webapp:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: simple-webapp-service
spec:
  type: NodePort
  selector:
    app: simple-webapp
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30007
```

#### 4. Jenkins Setup
1. **Install Plugins**: Install necessary plugins like Docker, Maven, Kubernetes, and Ansible in Jenkins.
2. **Create a Jenkins Pipeline**: Create a Jenkins pipeline to automate the build, Dockerization, and deployment process.

**Jenkinsfile**:
```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo/simple-webapp.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("simple-webapp:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh 'kubectl apply -f k8s-deployment.yml'
                }
            }
        }
    }
}
```

#### 5. Ansible Setup
Ansible can be used to manage configurations and deployments.

**ansible/playbook.yml**:
```yaml
---
- name: Deploy simple-webapp on Kubernetes
  hosts: localhost
  tasks:
    - name: Apply Kubernetes deployment
      command: kubectl apply -f k8s-deployment.yml
```

**ansible/ansible.cfg**:
```ini
[defaults]
inventory = ./inventory
host_key_checking = False
```

**ansible/inventory**:
```ini
localhost ansible_connection=local
```

#### 6. Running the Project
- **Build the Maven Project**:
    ```sh
    mvn clean package
    ```

- **Build and Run Docker Image**:
    ```sh
    docker build -t simple-webapp:latest .
    docker run -d -p 8080:8080 simple-webapp:latest
    ```

- **Deploy to Minikube**:
    ```sh
    kubectl apply -f k8s-deployment.yml
    ```

- **Run Ansible Playbook**:
    ```sh
    ansible-playbook ansible/playbook.yml
    ```

- **Jenkins Pipeline**: Run the pipeline through Jenkins UI.

This setup integrates all the tools specified to create a CI/CD pipeline for a simple Java web application. Adjust configurations and scripts according to your specific requirements and environment.
