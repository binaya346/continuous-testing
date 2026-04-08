# SonarQube In-Depth — Projects, Issues, Quality Gates, and Rules

> This note covers SonarQube concepts in depth — what everything means, how to configure it,
> and how it connects to your Jenkins pipeline. Read this alongside note 09 which covers the
> setup steps.

---

## Part 1 — What is a Project in SonarQube?

A **project** in SonarQube represents one codebase being analysed. Every time your Jenkins
pipeline runs `sonar:sonar`, it sends analysis results for that project.

### How a project is identified

SonarQube identifies a project by its **Project Key** — a unique string. For Maven projects,
this comes from `<artifactId>` in `pom.xml` unless you override it with `sonar.projectKey`.

```
First pipeline run  →  SonarQube auto-creates the project
Subsequent runs     →  SonarQube updates the same project with new results
```

### What lives inside a project

| Section              | What it contains                                                  |
|----------------------|-------------------------------------------------------------------|
| **Overview**         | Summary dashboard — Quality Gate status and all metric ratings    |
| **Issues**           | Every bug, vulnerability, code smell found in the code            |
| **Security Hotspots**| Code areas that need manual security review                       |
| **Measures**         | Detailed numbers — coverage %, duplication %, complexity          |
| **Code**             | Browse source files with inline issue annotations                 |
| **Activity**         | History of every analysis run with trends over time               |
| **Project Settings** | Quality Gate, Quality Profile, New Code definition per project    |

---

## Part 2 — The Six Metrics on the Dashboard

When you open a project in SonarQube, you see six key metrics. Here is what each one means.

---

### 2.1 Security

**What it measures:** Vulnerabilities in your code that could be exploited by an attacker.

**Rating scale:**

| Rating | Condition                                      |
|--------|------------------------------------------------|
| A      | No vulnerabilities                             |
| B      | At least one Minor vulnerability               |
| C      | At least one Major vulnerability               |
| D      | At least one Critical vulnerability            |
| E      | At least one Blocker vulnerability             |

**Examples SonarQube catches:**
- SQL injection (building queries with string concatenation)
- Hardcoded passwords or API keys in source code
- Insecure random number generation
- XML External Entity (XXE) attacks
- Unvalidated user input passed to system commands

---

### 2.2 Reliability

**What it measures:** Bugs — code that is likely to behave incorrectly or crash at runtime.

**Rating scale:** Same A–E scale as Security, based on the worst severity bug found.

**Examples SonarQube catches:**
- NullPointerException risk (`object.method()` without null check)
- Using `==` instead of `.equals()` to compare Strings in Java
- Resource leaks (database connections, file handles never closed)
- Unreachable code after a `return` statement
- Off-by-one errors in loops

---

### 2.3 Maintainability

**What it measures:** Code smells — code that is not wrong today but makes the codebase
harder to understand, change, or extend over time. Also called **Technical Debt**.

**Rating scale:** Based on the ratio of technical debt time vs the estimated time to write
the whole project from scratch.

| Rating | Debt ratio     |
|--------|----------------|
| A      | ≤ 5%           |
| B      | 6–10%          |
| C      | 11–20%         |
| D      | 21–50%         |
| E      | > 50%          |

**Examples SonarQube catches:**
- Methods that are too long or do too many things
- Deeply nested `if` blocks (cognitive complexity)
- Duplicated code blocks
- Magic numbers (using `42` instead of a named constant)
- Empty catch blocks that swallow exceptions silently
- Dead code (variables declared but never used)

---

### 2.4 Coverage

**What it measures:** What percentage of your source code is executed by your automated tests.

```
Coverage % = (Lines executed by tests / Total lines) × 100
```

**Why it matters:** High coverage means your tests verify more of your code behaviour.
Low coverage means bugs can hide in untested paths.

**Coverage requires a test report.** For Maven + JaCoCo:

```xml
<!-- Add to pom.xml -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.12</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

Then change your pipeline command to run tests:
```groovy
sh './mvnw -B verify sonar:sonar'   // verify runs tests + jacoco report
```

> Without a coverage tool configured, SonarQube shows `0.0%` — it does not calculate
> coverage itself, it reads the report generated by JaCoCo (Java), Istanbul (JS), etc.

---

### 2.5 Duplications

**What it measures:** Blocks of code that are copy-pasted in multiple places.

**Why it matters:** Duplicated code means a bug fix or change must be made in multiple
places — easy to miss one. It is a sign that logic should be extracted into a shared method.

SonarQube flags a block as duplicated when the same sequence of tokens (roughly 10+ lines)
appears in more than one place.

---

### 2.6 Security Hotspots

**What it is:** Security-sensitive code that is NOT necessarily a vulnerability but requires
a human to review and confirm it is safe.

**The difference from Vulnerabilities:**

| Vulnerability | Security Hotspot |
|---|---|
| SonarQube is confident this is a security flaw | SonarQube is unsure — needs human judgement |
| Automatically flagged as an issue | Must be manually reviewed and marked Safe or Unsafe |
| Counts against Security rating | Does not count against Security rating until reviewed |

**Examples:**
- Using `Math.random()` — might be fine, might need `SecureRandom` depending on context
- Disabling SSL certificate validation — suspicious, but could be intentional in test code
- Storing data in cookies — depends on what data and whether it is sensitive

**How to handle hotspots:**
1. Open the hotspot in SonarQube
2. Read the description and your code carefully
3. Mark as **Safe** (reviewed, not a risk) or **Fixed** (you changed the code)

---

## Part 3 — Quality Gate

### What is a Quality Gate?

A **Quality Gate** is a set of conditions that your project must pass to be considered
healthy. Think of it as the definition of "good enough to ship".

When your pipeline runs `waitForQualityGate`, Jenkins asks SonarQube:
*"Did this project pass all conditions?"* — and acts on the answer.

```
Analysis completes
      │
      ▼
SonarQube evaluates each condition
      │
      ├── All conditions pass  →  Quality Gate: PASSED  →  Jenkins continues
      └── Any condition fails  →  Quality Gate: FAILED  →  Jenkins aborts build
```

### The default gate — Sonar way

SonarQube ships with a built-in gate called **Sonar way**. Its default conditions focus on
**New Code** (code changed in the current analysis) rather than the entire codebase.
This is intentional — it lets legacy projects improve gradually rather than blocking
everything on old existing issues.

Default conditions in **Sonar way**:

| Metric                        | Condition         | Meaning                                      |
|-------------------------------|-------------------|----------------------------------------------|
| New Bugs                      | > 0               | Any new bug introduced fails the gate        |
| New Vulnerabilities           | > 0               | Any new vulnerability fails the gate         |
| New Security Hotspots Reviewed| < 100%            | All new hotspots must be reviewed            |
| New Code Coverage             | < 80%             | New code must have 80%+ test coverage        |
| New Duplicated Lines          | > 3%              | New code must not duplicate excessively      |

---

### Creating a Custom Quality Gate

Use this when you want different rules than the default — for example, during a learning
project where you want looser coverage requirements.

1. **Administration** → **Quality Gates** → **Create**
2. Enter a name: e.g. `Dev Gate`
3. Click **Add Condition** for each rule you want:

   | Metric | Operator | Value | Effect |
   |--------|----------|-------|--------|
   | New Bugs | is greater than | 0 | Fail if any new bug |
   | New Vulnerabilities | is greater than | 0 | Fail if any new vulnerability |
   | New Coverage | is less than | 50 | Fail if coverage below 50% |
   | New Code Smells | is greater than | 10 | Fail if more than 10 new smells |

4. Click **Save**

> You can add as many or as few conditions as you want. A gate with no conditions always passes.

---

### Assigning a Quality Gate to a Project

By default, all projects use the **Sonar way** gate. To use your custom gate:

1. Open your project in SonarQube
2. **Project Settings** (bottom left sidebar) → **Quality Gate**
3. Select your custom gate from the dropdown
4. Click **Save**

From the next pipeline run, SonarQube will evaluate your project against the new gate.

---

### The `Unknown url: /api/project_branches/get_ai_code_assurance` error

You may see this error when saving Quality Gate settings. **It is harmless.** It is the
SonarQube UI trying to call an AI Code Assurance API that only exists in paid editions.
Your gate was saved successfully — ignore this error.

---

## Part 4 — Jenkins Pipeline Stages Explained Line by Line

```groovy
stage('🔍 Code Quality') {
```
Defines a named stage. The name appears in the Jenkins pipeline UI as a labelled box.

```groovy
    agent {
        docker {
            image 'eclipse-temurin:25-jdk-alpine'
```
This stage runs inside a Docker container using the `eclipse-temurin:25-jdk-alpine` image.
This image contains JDK 25 — it must match the Java version in your `pom.xml`. If your
project uses Java 21, use `eclipse-temurin:21-jdk-alpine` instead.

```groovy
            reuseNode true
```
By default, each `agent { docker }` block spins up its container on a fresh node. `reuseNode true`
tells Jenkins to run this container on the **same node and workspace** as the parent pipeline.
Without this, the container cannot see your checked-out source code.

```groovy
    steps {
        withSonarQubeEnv('SonarQube') {
```
`withSonarQubeEnv` is provided by the SonarQube Scanner plugin. It automatically injects two
environment variables into the shell:
- `SONAR_HOST_URL` — the SonarQube server URL you configured in Jenkins System settings
- `SONAR_TOKEN` — the authentication token from Jenkins credentials

`'SonarQube'` must exactly match the **Name** you gave the server in
**Manage Jenkins → System → SonarQube servers**.

```groovy
            sh './mvnw -B compile sonar:sonar'
```
Runs three Maven goals in sequence:

| Part | What it does |
|------|--------------|
| `./mvnw` | Uses the Maven wrapper in your repo — no Maven installation needed on the agent |
| `-B` | Batch mode — suppresses interactive prompts and colours output for CI logs |
| `compile` | Compiles `src/main/java` into `target/classes` — SonarQube's Java plugin requires bytecode |
| `sonar:sonar` | Runs the SonarQube analysis, reads `target/classes`, and sends all results to SonarQube |

```groovy
stage('✅ Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
```
Wraps the step in a 5-minute timeout. If SonarQube does not respond within 5 minutes
(e.g. the webhook is misconfigured), Jenkins will not wait forever — it will abort.

```groovy
            waitForQualityGate abortPipeline: true
```
Pauses the pipeline and waits for SonarQube to call back via the webhook with the
Quality Gate result.

- `abortPipeline: true` — if the gate FAILS, mark the Jenkins build as FAILED and stop
- `abortPipeline: false` — report the result but always let the build continue

The webhook must be configured in SonarQube (**Administration → Webhooks**) pointing to
`http://your-jenkins/sonarqube-webhook/` for this step to receive the result.

---

## Part 5 — Rules

### What is a Rule?

A **rule** is a single check that SonarQube applies to your code. Each issue you see in the
dashboard was raised by one rule. Every rule has:

| Property | Example |
|---|---|
| **Key** | `java:S2077` |
| **Name** | `Formatting SQL queries is security-sensitive` |
| **Type** | Bug / Vulnerability / Code Smell / Security Hotspot |
| **Severity** | Blocker / Critical / Major / Minor / Info |
| **Language** | Java, Python, JavaScript, etc. |
| **Tags** | `sql`, `injection`, `security` |

### Browsing rules

**Rules** (top navigation bar) → filter by:
- Language
- Type
- Severity
- Tag (e.g. `owasp-a1`, `performance`, `design`)

Click any rule to read a full description, a non-compliant code example, and a compliant
code example showing how to fix it.

---

### What is a Quality Profile?

A **Quality Profile** is a collection of active rules for a specific language. It is the
answer to: *"Which rules should SonarQube apply when analysing this language?"*

Every project is assigned one Quality Profile per language. The default is **Sonar way**
for each language — a curated set maintained by SonarSource.

```
Project
  └── Quality Profile (per language)
        └── Active Rules (the checks that run)
              └── Each rule raises Issues when violated
```

---

### Creating a Custom Quality Profile

You cannot edit the built-in **Sonar way** profile. You must copy it first.

1. **Administration** → **Quality Profiles**
2. Select your language (e.g. Java)
3. Click the **⚙ gear icon** next to **Sonar way** → **Copy**
4. Name it e.g. `Our Java Rules`
5. Click **Copy**

Now you have your own profile you can modify.

---

### Activating and Deactivating Rules

#### Deactivate a rule (stop checking for it)

Use this when a rule fires incorrectly for your project or is not relevant.

1. Open your custom profile (**Administration → Quality Profiles → Our Java Rules**)
2. Click **Active Rules** tab — you see all currently active rules
3. Find the rule you want to disable (use the search box)
4. Click **Deactivate** next to it
5. Confirm

#### Activate a new rule (add a check)

1. Open your custom profile
2. Click **Activate More** button (top right)
3. Browse or search the inactive rules
4. Click **Activate** next to any rule you want to add
5. You can set the severity (override the default) when activating

---

### Assigning a Quality Profile to a Project

1. Open your project in SonarQube
2. **Project Settings** → **Quality Profiles**
3. For each language, select your custom profile from the dropdown
4. Click **Save**

From the next pipeline run, your project uses your custom rules.

---

### Suppressing a Rule for a Specific Line in Code

If a rule fires on a line where you have reviewed the code and it is intentionally written
that way, you can suppress it with an annotation in Java:

```java
@SuppressWarnings("java:S2077")  // rule key — SQL query is built safely, input validated
public ResultSet runQuery(String safeSql) {
    return statement.executeQuery(safeSql);
}
```

> Use sparingly. Every suppression is a deliberate decision to ignore a check.
> The annotation and comment serve as documentation of that decision.

---

### Marking Issues as Exceptions in the SonarQube UI

Instead of changing code, you can resolve issues directly in the SonarQube dashboard:

| Status | When to use |
|--------|-------------|
| **Won't Fix** | Intentional — you accept this deviation from the rule |
| **False Positive** | The rule fired incorrectly for this specific case |
| **Accepted** | Acknowledged — will fix in a future sprint |

These statuses remove the issue from the Quality Gate count so your gate can pass even
with known, accepted issues.

To mark an issue:
1. **Issues** tab in your project
2. Click the issue
3. Click the status dropdown → select Won't Fix / False Positive / Accepted
4. Add a comment explaining why (good practice for team visibility)

---

## Quick Reference Summary

```
SonarQube Project
│
├── Analysed by → Quality Profile (which rules run)
│                       └── Rules (individual checks)
│
├── Results in → Issues
│                   ├── Bugs           (Reliability)
│                   ├── Vulnerabilities (Security)
│                   ├── Code Smells    (Maintainability)
│                   └── Security Hotspots (manual review)
│
├── Measured by → Metrics
│                   ├── Coverage %
│                   └── Duplications %
│
└── Evaluated by → Quality Gate (pass/fail threshold)
                        └── Result sent to Jenkins via Webhook
                                └── waitForQualityGate → pass or abort
```
