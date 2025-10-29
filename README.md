# FileRise Docker · CI/CD

This repository builds and publishes the official **FileRise** Docker image for multiple architectures (`amd64`, `arm64`).  
The application source code lives in **[error311/FileRise](https://github.com/error311/FileRise)**.

---

## Overview

This repo does **not** contain the FileRise application, Dockerfile, or startup scripts.  
Instead, it provides a **fully automated CI/CD pipeline** that:

- Pulls the latest FileRise source code.
- Runs version stamping to replace cache-busting placeholders.
- Builds a multi-architecture Docker image.
- Pushes the final image to Docker Hub.

---

## How It Works

1. **Source of truth:**  
   The `VERSION` file in this repo defines which FileRise version should be built (e.g., `v1.7.0`).

2. **Automatic sync:**  
   When a new release is published in [FileRise](https://github.com/error311/FileRise), its CI workflow automatically:
   - Updates `CHANGELOG.md` here.
   - Writes the new version into `VERSION`.

3. **CI Trigger:**  
   Any push to this repo’s `main` branch — whether from the upstream sync or manual changes — triggers the build pipeline.

4. **Build & Push:**
   - Checks out both this repo and the FileRise app repository.
   - Runs `scripts/stamp-assets.sh` to replace `{{APP_VER}}` / `{{APP_QVER}}` placeholders and normalize `?v=` cache-busters.
   - Verifies that all placeholders were replaced successfully.
   - Builds and pushes a multi-architecture Docker image to Docker Hub:
     - `error311/filerise-docker:latest`
     - `error311/filerise-docker:vX.Y.Z`

---

## Prerequisites

- GitHub Actions runner with **Docker Buildx** and **QEMU** support.
- The following **repository secrets** configured under  
  `Settings → Secrets and variables → Actions`:
  - `DOCKER_USERNAME` – your Docker Hub username.
  - `DOCKER_PASSWORD` – your Docker Hub password or access token.

---

## Publish Flow

1. The **FileRise** repository releases a new version (e.g. `v1.7.0`).
2. Its workflow syncs the latest `CHANGELOG.md` and `VERSION` into this repo.
3. That push triggers this repo’s CI.
4. The pipeline:
   - Stamps versioned assets inside `app/`
   - Builds the multi-architecture Docker image
   - Pushes it to Docker Hub as:
     - `error311/filerise-docker:v1.7.0`
     - `error311/filerise-docker:latest`

---

## Using the Docker Image

### Pull the image
```bash
docker pull error311/filerise-docker:latest
# or a specific version
docker pull error311/filerise-docker:v1.7.0
```

### Run FileRise
```
docker run -d \
  -p 80:80 \
  --name filerise \
  error311/filerise-docker:latest
```
Docker will automatically select the correct architecture for your platform.

---

### Troubleshooting
- **Old version built:**
Make sure the VERSION file contains the desired tag (e.g. v1.7.0) and the upstream sync completed.
- **Placeholders not replaced:**
The workflow fails if {{APP_QVER}} or {{APP_VER}} remain in HTML/JS/CSS.
Confirm that app/scripts/stamp-assets.sh exists and runs properly.
- **Private dependencies:**
If your FileRise build depends on private modules, update the workflow’s checkout step with the necessary credentials.

---

### Related Repositories
- **Main application:** error311/FileRise￼
- **Docker Hub:** error311/filerise-docker￼

