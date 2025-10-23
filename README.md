# FileRise Docker CI/CD

This repository no longer contains the application code, Dockerfile, or `start.sh` script. Instead, it hosts the GitHub Actions workflow that builds and publishes the FileRise Docker image for multiple CPU architectures (amd64 & arm64).

Visit <https://github.com/error311/FileRise> for additional details

---

## What Happens Here

1. **Manual updates** to this repo (e.g. changes to the CI workflow) trigger the pipeline.  
2. **Automatic sync**: When `CHANGELOG.md` in the [FileRise](https://github.com/error311/FileRise) repo is updated, a sync workflow pushes the updated changelog into this repo.  
3. **CI Trigger**: Any push—whether manual or from the changelog sync—starts the build-and-push action.  
4. **Build & Push**:  
   - Uses Docker Buildx to build for `linux/amd64` and `linux/arm64`.  
   - Pushes the multi-arch manifest to Docker Hub under `error311/filerise-docker:latest`.

## Prerequisites

- A GitHub Actions runner with Docker Buildx support.  
- **Secrets** configured in this repo:  
  - `DOCKER_USERNAME` & `DOCKER_PASSWORD`: Docker Hub credentials for pushing images.

## Workflow: `main.yml`

Located under `.github/workflows/main.yml`, it performs:

1. **Checkout** this repo.  
2. **Setup Buildx** via `docker/setup-buildx-action`.  
3. **Login** to Docker Hub.  
4. **Cache** Docker layers.  
5. **Build & Push** the image for multiple platforms.

You can inspect or modify the build parameters (e.g. target platforms, cache settings) in that workflow file.

## How to Use

- **Pull the image** on any host:
  
  ```bash
  docker pull error311/filerise-docker:latest
  ```
  
  Docker will automatically select the appropriate architecture (amd64, arm64).
  
- Run:

  ```bash
  docker run -d \
  -p 80:80 \
  --name filerise \
  error311/filerise-docker:latest
  ```
