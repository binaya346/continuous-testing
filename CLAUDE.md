# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an educational course repository on **Continuous Testing** — covering testing concepts, SonarQube setup, Jenkins/GitHub Actions CI integration, and Selenium web automation. It contains lecture notes, a practical hands-on SonarQube lab, and quick-reference cheatsheets.

## Repository Structure

- `notes/` — Markdown lecture notes (01–08) covering testing theory, TDD, Selenium, SonarQube, SonarLint, and CI/CD integrations
- `hands-on/sonarqube-production/` — Docker Compose–based SonarQube lab environment
- `cheatsheets/` — Quick-reference materials

## Running the SonarQube Lab

```bash
# Automated setup (verifies prerequisites, starts containers, waits for readiness)
cd hands-on/sonarqube-production
./setup.sh

# Or start manually
cd hands-on/sonarqube-production
docker compose up -d

# Stop
docker compose down

# Stop and remove volumes (full reset)
docker compose down -v
```

SonarQube is available at `http://localhost:9000` (default credentials: `admin` / `admin`).

## Environment Configuration

Environment variables are in `hands-on/sonarqube-production/.env`. Key settings:

- `SONAR_VERSION` — SonarQube edition (default: `community`)
- `SONAR_PORT` — Host port (default: `9000`)
- `POSTGRES_PASSWORD` — Change before any real deployment
- `SONAR_*_JAVA_OPTS` — JVM heap sizes (default: 512m; increase for larger codebases)

## Architecture of the SonarQube Stack

The `docker-compose.yml` defines two services on an isolated `sonarnet` bridge network:

- **sonarqube** — The analysis server (depends on db being healthy)
- **db** — PostgreSQL 15 backend

Data is persisted in named volumes: `sonarqube_data`, `sonarqube_extensions`, `sonarqube_logs`, `postgresql_data`.

## Common Troubleshooting

**Elasticsearch won't start (Linux):**
```bash
sudo sysctl -w vm.max_map_count=262144
```

**Port conflict:** Change `SONAR_PORT` in `.env`.

**Out of memory:** Increase `SONAR_WEB_JAVA_OPTS`, `SONAR_CE_JAVA_OPTS`, and `SONAR_SEARCH_JAVA_OPTS` in `.env`.
