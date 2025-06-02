.PHONY: dev down rebuild build push clean

# Set default tag if not passed (e.g. `make build` will default to :latest)
IMAGE_TAG ?= latest
IMAGE_NAME := ghcr.io/heschmat/devops_eks_portfolio

# Dev mode (hot reload via Air)
dev:
	docker compose -f docker-compose.dev.yml up --build

down:
	docker compose -f docker-compose.dev.yml down

rebuild:
	docker compose -f docker-compose.dev.yml down
	docker compose -f docker-compose.dev.yml up --build

# make build IMAGE_TAG=v1
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfile .

push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

# Remove stopped containers and dangling images
clean:
	docker system prune -f
