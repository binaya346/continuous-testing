# SonarQube GitHub Integration Guide

This guide provides a step-by-step walkthrough to connect your SonarQube instance with GitHub and set up your first project.

---

## Part 1: Initial Setup

1.  **Start SonarQube:** Run the `./setup.sh` script or `docker compose up -d`.
2.  **Access UI:** Open `http://localhost:9000` in your browser.
3.  **Login:** Use the default credentials:
    *   **Username:** `admin`
    *   **Password:** `admin`
4.  **Change Password:** You will be prompted to change the administrator password immediately. **Don't forget this new password!**

---

## Part 2: Connect SonarQube to GitHub

To integrate with GitHub (e.g., for Pull Request Decoration), you need to create a **GitHub App** on GitHub and configure it in SonarQube.

### Step 1: Create a GitHub App
1.  Go to **GitHub Settings** > **Developer Settings** > **GitHub Apps**.
2.  Click **New GitHub App**.
3.  **App Name:** `SonarQube-Local` (or anything unique).
4.  **Homepage URL:** `http://localhost:9000`.
5.  **Webhook:**
    *   **Active:** `false` (until you use a public URL with a proxy like ngrok).
6.  **Permissions:** Set the following permissions:
    *   **Repository permissions:**
        *   `Checks`: Read & write
        *   `Contents`: Read-only
        *   `Metadata`: Read-only
        *   `Pull requests`: Read & write
7.  **Installation:** Select **Any account / Only on this account** as per your preference.
8.  **Save:** Click **Create GitHub App**.
9.  **Note Down:**
    *   **App ID**
    *   **Client ID**
10. **Generate a Client Secret:** Click **Generate a new client secret** and save it.
11. **Private Key:** Scroll down and click **Generate a private key**. Download the `.pem` file.

### Step 2: Configure SonarQube
1.  In SonarQube, go to **Administration** > **Configuration** > **General-Settings** > **DevOps Platform Integrations**.
2.  Click the **GitHub** tab.
3.  Click **Create configuration**.
4.  Fill in the details:
    *   **Configuration Name:** `GitHub-Local`
    *   **GitHub URL:** `https://github.com` (for GitHub Cloud)
    *   **GitHub App ID:** (From step 1.9)
    *   **Client ID:** (From step 1.9)
    *   **Client Secret:** (From step 1.10)
    *   **Private Key:** (Open the `.pem` file from step 1.11 and copy/paste its content).
5.  Click **Save**.

---

## Part 3: Create and Analyze a Project

1.  **Add Project:** Go to the **Projects** page and click **Add Project** > **GitHub**.
2.  **Select Repository:** Choose the repository you want to analyze.
3.  **Setup Project:** Follow the on-screen instructions for "With GitHub Actions" or "Manually".

### Manual Analysis (Example)
If you want to run analysis from your local command line:
1.  **Generate Token:** Go to **My Account** > **Security** > **Generate Token**. Use type `Project Analysis Token`.
2.  **Add sonar-project.properties:** Create this file in your project root:
    ```properties
    sonar.projectKey=my-unique-project-key
    sonar.token=your-generated-token
    sonar.host.url=http://localhost:9000
    sonar.sources=.
    ```
3.  **Run Scanner:** Use `sonar-scanner` (if installed) or a Dockerized scanner:
    ```bash
    docker run \
        --rm \
        -e SONAR_HOST_URL="http://localhost:9000" \
        -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=my-unique-project-key" \
        -e SONAR_TOKEN="your-generated-token" \
        -v "$(pwd):/usr/src" \
        sonarsource/sonar-scanner-cli
    ```

---

## Troubleshooting
- **Elasticsearch failures:** Ensure `vm.max_map_count` is set correctly on the host.
- **Port conflicts:** If 9000 is taken, change `SONAR_PORT` in the `.env` file.
- **Memory issues:** If the UI is slow or crashing, increase the `-Xmx` values in the `.env` file.
