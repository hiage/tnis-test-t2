# Docker Image Build

## Prerequisites

1. **Docker**: Ensure Docker is installed and running
2. **Docker Buildx**: Required for multi-architecture builds
3. **Docker Hub Access**: For pushing images to `docker.io/hiage/image-name`

## Quick Start

### 1. Build and Push Multi-Architecture Image

```bash
make build-all
```