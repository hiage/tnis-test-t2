# Simple Multi-Architecture Makefile

# Variables
PLATFORMS = linux/amd64,linux/arm64

# Frontend
FRONTEND_IMAGE = hiage/frontend:latest
FRONTEND_DOCKERFILE = frontend/Dockerfile

# Backend
BACKEND_IMAGE = hiage/backend:latest
BACKEND_DOCKERFILE = backend/Dockerfile

# Fluent-bit
FLUENTBIT_IMAGE = hiage/fluent-bit:latest
FLUENTBIT_DOCKERFILE = fluent-bit/fluentbit.Dockerfile

# Default target
all: help

build-all: build-frontend build-backend build-fluent-bit
build-frontend:
	@echo "Building multi-architecture Docker image: $(FRONTEND_IMAGE)"
	@echo "Platforms: $(PLATFORMS)"
	docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(FRONTEND_IMAGE) \
		--file $(FRONTEND_DOCKERFILE) \
		--push \
		frontend/

build-backend:
	@echo "Building multi-architecture Docker image: $(BACKEND_IMAGE)"
	@echo "Platforms: $(PLATFORMS)"
	docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(BACKEND_IMAGE) \
		--file $(BACKEND_DOCKERFILE) \
		--push \
		backend/

build-fluent-bit:
	@echo "Building multi-architecture Docker image: $(FLUENTBIT_IMAGE)"
	@echo "Platforms: $(PLATFORMS)"
	docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(FLUENTBIT_IMAGE) \
		--file $(FLUENTBIT_DOCKERFILE) \
		--push \
		fluent-bit/

help:
	@echo "Available targets:"
	@echo "  build-frontend   - Build and push multi-arch frontend image"
	@echo "  build-backend    - Build and push multi-arch backend image"
	@echo "  build-fluent-bit - Build and push multi-arch fluent-bit image"
	@echo "  help             - Show this help message"
