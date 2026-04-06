# SonarQube Server Setup and Administration

**SonarQube** is an automatic code review tool to detect bugs, vulnerabilities, and code smells in your source code. It can be integrated with your existing workflow to enable continuous code inspection across your project branches and pull requests.

---

## 1. System Requirements
- **Java**: SonarQube is built with Java. Version 17 is typically required for recent versions.
- **Database**: PostgreSQL (Recommended), Microsoft SQL Server, or Oracle. 
  - *Note: SonarQube no longer supports MySQL.*
- **Memory**: Minimum 2GB of RAM (4GB+ recommended for production).

---

## 2. Setup Options

### A. Using Zip File (Manual)
1. Download the community edition from [sonarsource.com](https://www.sonarsource.com/products/sonarqube/downloads/).
2. Unzip the file.
3. Start the server:
   - Linux/Mac: `./bin/[OS]/sonar.sh start`
   - Windows: `./bin/windows-x86-64/StartSonar.bat`
4. Access at `http://localhost:9000` (Default credentials: `admin` / `admin`).

### B. Using Docker (Recommended for Learning)
```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:community
```

---

## 3. Basic Administration
- **Quality Profiles**: Define the rules that SonarQube uses during analysis (e.g., "Sonar Way" is the default).
- **Quality Gates**: A set of conditions a project must meet before it can be released (e.g., "Coverage must be > 80%").
- **Users & Groups**: Manage who can view analysis results and change settings.
- **Plugins**: Extend functionality (e.g., support for COBOL, specialized security rules).

---

## 4. Key SonarQube Files
- `conf/sonar.properties`: Main configuration file (DB connections, port settings).
- `logs/sonar.log`: Main log file for troubleshooting.
- `extensions/plugins/`: Where manual plugin JARs are placed.

---

## 5. First Time Login Steps
1. Change the default `admin` password immediately.
2. Create a **User Token** (found in My Account > Security). You will need this token for Jenkins or GitHub Actions integration.
3. Configure your **Sourcing** (Bitbucket, GitHub, GitLab, or Azure DevOps).
