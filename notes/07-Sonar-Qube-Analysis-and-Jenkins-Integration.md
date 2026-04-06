# SonarQube Code Analysis & Jenkins Integration

Integrating SonarQube with Jenkins allows you to automatically analyze every build for code quality and security.

---

## 1. Prerequisites
- **Jenkins** with the "SonarQube Scanner" plugin installed.
- **SonarQube Server** URL and API Token.

---

## 2. Configuration in Jenkins

### A. Global Tool Configuration
1. Go to **Manage Jenkins** > **Global Tool Configuration**.
2. Add **SonarQube Scanner**.
3. Give it a name (e.g., `sonar-scanner`) and let it "Install automatically."

### B. Configure System
1. Go to **Manage Jenkins** > **Configure System**.
2. Find the **SonarQube servers** section.
3. Click "Add SonarQube."
4. Add the **Name** and **Server URL** (e.g., `http://localhost:9000`).
5. Add the **Server authentication token** as a hidden Jenkins credential (Secret Text).

---

## 3. Jenkins Pipeline Integration
In your `Jenkinsfile`, add a stage to run the analysis:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('MySonarServer') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
```

---

## 4. Key SonarQube Properties
Create a `sonar-project.properties` file in your project root to avoid passing many flags:
```properties
sonar.projectKey=my-java-app
sonar.projectName=My Java Application
sonar.projectVersion=1.0
sonar.sources=src/main/java
sonar.java.binaries=target/classes
sonar.tests=src/test/java
```

---

## 5. Quality Gates
A **Quality Gate** is a policy that fails the build if certain metrics are not met:
- **Success**: Code is ready for production.
- **Warning**: Code is okay, but needs attention.
- **Failed**: Code must be fixed before proceeding.

> **Pro Tip**: Always use `waitForQualityGate` in your pipeline. It forces the build to wait for SonarQube's verdict, preventing "bad" code from reaching production.
