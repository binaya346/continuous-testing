# SonarQube + Jenkins Integration — Step-by-Step Guide

> **Tested on:** SonarQube Community Build **26.x**, Jenkins **2.x**, Java **25**
> **Goal:** Automatically analyse code quality on every push using Jenkins + SonarQube.

---

## How it works

```
GitHub push
    │
    ▼
Jenkins Pipeline
    │
    ├─ mvn compile sonar:sonar  ──▶  SonarQube analyses code
    │                                       │
    │                                  Quality Gate
    │                                       │
    ◀──────── webhook result ──────────────┘
    │
    ├─ PASSED → continue pipeline (Docker build, etc.)
    └─ FAILED → abort pipeline
```

> **Note:** You do NOT need to manually create a project in SonarQube first.
> When the pipeline runs, SonarQube automatically creates the project using your
> Maven `<artifactId>` from `pom.xml` as the project key.

---

## Prerequisites

- SonarQube running at `http://localhost:9000` (default credentials: `admin` / `admin`)
- Jenkins running and accessible
- Your project is a Maven Java app with `mvnw` (Maven wrapper) at the repo root
- SonarQube Scanner plugin installed in Jenkins (version 2.11 or later)

---

## Step 1 — Generate a SonarQube Token

Jenkins needs a token to authenticate with SonarQube when sending scan results.

1. Log in to SonarQube at `http://localhost:9000`
2. Click your **avatar** (top right) → **My Account** → **Security** tab
3. Under *Generate Tokens*:
   - **Name:** `jenkins-token`
   - **Type:** `Global Analysis Token`
   - **Expiration:** your choice (no expiration for learning)
4. Click **Generate**
5. **Copy the token immediately** — it is shown only once

---

## Step 2 — Add the Token to Jenkins Credentials

1. Open Jenkins → **Manage Jenkins** → **Credentials** → **System** → **Global credentials** → **Add Credentials**
2. Fill in:

   | Field       | Value                        |
   |-------------|------------------------------|
   | Kind        | `Secret text`                |
   | Secret      | *(paste the token from Step 1)* |
   | ID          | `sonarqube-token`            |
   | Description | `SonarQube analysis token`   |

3. Click **Create**

---

## Step 3 — Install the SonarQube Scanner Plugin

1. Jenkins → **Manage Jenkins** → **Plugins** → **Available plugins**
2. Search for `SonarQube Scanner` and install it
3. Restart Jenkins if prompted

> If you already see **SonarQube Scanner** listed under **Installed plugins**, skip this step.

---

## Step 4 — Register SonarQube Server in Jenkins

1. Jenkins → **Manage Jenkins** → **System**
2. Scroll to **SonarQube servers**
3. Check the **Environment variables** checkbox (this enables `withSonarQubeEnv` in pipelines)
4. Click **Add SonarQube** and fill in:

   | Field                        | Value                                                                                  |
   |------------------------------|----------------------------------------------------------------------------------------|
   | Name                         | `SonarQube` *(must match the name used in the Jenkinsfile)*                            |
   | Server URL                   | `http://host.docker.internal:9000` if Jenkins runs in Docker, or `http://localhost:9000` if Jenkins runs natively |
   | Server authentication token  | select `sonarqube-token` from the dropdown                                             |

5. Click **Save**

> **`host.docker.internal` vs `localhost`:**
> If Jenkins runs inside a Docker container, `localhost` inside that container refers to the
> container itself — not your machine. Use `host.docker.internal` so the container can reach
> SonarQube running on the host.

---

## Step 5 — Add the Webhook in SonarQube

The webhook lets SonarQube notify Jenkins when analysis is complete so `waitForQualityGate` can proceed.

1. SonarQube → **Administration** → **Configuration** → **Webhooks**
2. Click **Create**:

   | Field  | Value                                                                                                 |
   |--------|-------------------------------------------------------------------------------------------------------|
   | Name   | `Jenkins`                                                                                             |
   | URL    | `http://host.docker.internal:8080/sonarqube-webhook/` (Jenkins in Docker) or `http://localhost:8080/sonarqube-webhook/` |
   | Secret | *(leave blank for local dev)*                                                                         |

3. Click **Create**

> **Important:** The URL must end with `/sonarqube-webhook/` — including the trailing slash.

---

## Step 6 — Add SonarQube Stages to Your Jenkinsfile

Add these two stages to your pipeline. Place them **before** the Docker build stage so the pipeline fails fast on quality issues without wasting time building an image.

```groovy
stage('🔍 Code Quality') {
    agent {
        docker {
            image 'eclipse-temurin:25-jdk-alpine'
            reuseNode true
        }
    }
    steps {
        withSonarQubeEnv('SonarQube') {
            sh './mvnw -B compile sonar:sonar'
        }
    }
}

stage('✅ Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

**Key points:**
- `eclipse-temurin:25-jdk-alpine` — must match the Java version in your `pom.xml` (Java 25 here)
- `reuseNode true` — runs the container on the same workspace node so it can read your source files
- `./mvnw compile` — compiles the code first so SonarQube has bytecode for accurate Java analysis
- `sonar:sonar` — runs the analysis and sends results to SonarQube
- `withSonarQubeEnv('SonarQube')` — automatically injects `SONAR_HOST_URL` and `SONAR_TOKEN` from Jenkins System config; `'SonarQube'` must match the server name from Step 4
- `waitForQualityGate abortPipeline: true` — waits for SonarQube webhook result; fails the build if the Quality Gate fails

> **No `sonar-project.properties` needed for Maven projects.**
> Maven's sonar plugin reads `<artifactId>` from `pom.xml` as the project key automatically.
> SonarQube creates the project on first run — no manual project setup required.

---

## Step 7 — Add SonarQube Properties to pom.xml (Optional but Recommended)

To control the project name shown in SonarQube, add this inside `<properties>` in your `pom.xml`:

```xml
<properties>
    <sonar.projectKey>your-app-name</sonar.projectKey>
    <sonar.projectName>Your App Name</sonar.projectName>
    <sonar.sources>src/main/java</sonar.sources>
    <sonar.tests>src/test/java</sonar.tests>
    <sonar.exclusions>**/target/**,**/node_modules/**</sonar.exclusions>
</properties>
```

Without this, SonarQube uses the `<artifactId>` as the project key — which is fine and is actually
the recommended default for Maven projects.

---

## Step 8 — Run the Pipeline

Trigger the pipeline by pushing a commit. On first run:

1. Jenkins checks out the code
2. Maven compiles the source and runs `sonar:sonar`
3. SonarQube receives the results and **auto-creates the project**
4. SonarQube evaluates the Quality Gate and sends the result back via webhook
5. Jenkins proceeds or aborts based on the result

After the run, open `http://localhost:9000` — your project will appear automatically.

---

## Reading Results in SonarQube

| Section            | What it shows                                              |
|--------------------|------------------------------------------------------------|
| **Overview**       | Overall Quality Gate status (Passed / Failed)              |
| **Issues**         | Bugs, vulnerabilities, code smells, security hotspots      |
| **Security Hotspots** | Code that needs manual security review                  |
| **Measures**       | Coverage, duplications, complexity metrics                 |
| **Code**           | Browse source files with inline annotations                |

### Issue types

| Type                 | Meaning                                              |
|----------------------|------------------------------------------------------|
| **Bug**              | Likely incorrect behaviour — fix before release      |
| **Vulnerability**    | Security weakness that can be exploited              |
| **Security Hotspot** | Sensitive code that needs human review               |
| **Code Smell**       | Maintainability issue — technical debt               |

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `waitForQualityGate` times out | Webhook not reachable | Check webhook URL uses `host.docker.internal`, not `localhost`, when Jenkins is in Docker |
| Wrong project name in SonarQube | Maven uses `<artifactId>` | Add `<sonar.projectKey>` in `pom.xml` properties |
| `release version 25 not supported` | Wrong JDK in Docker image | Match image JDK version to your `pom.xml` Java version |
| `No files matching target/classes` | Scan ran before compile | Use `./mvnw compile sonar:sonar` not just `sonar:sonar` |
| `Connection refused` to SonarQube | Wrong URL | Use `host.docker.internal:9000` if Jenkins is in Docker |
| `Bad credentials` from GitHub | Expired PAT | Regenerate token in GitHub → update Jenkins credential |
| Build fails Quality Gate | Real code issues found | Check SonarQube dashboard for specific issues |
