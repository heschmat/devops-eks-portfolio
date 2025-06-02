.PHONY: dev down rebuild build-prod run-prod clean

# Dev mode (hot reload via Air)
dev:
	docker compose -f docker-compose.dev.yml up --build

down:
	docker compose -f docker-compose.dev.yml down

rebuild:
	docker compose -f docker-compose.dev.yml down
	docker compose -f docker-compose.dev.yml up --build

# Production build using multi-stage Dockerfile
build-prod:
	docker build -t go-static-app:prod -f Dockerfile .

# Run the prod image
run-prod:
	docker run --rm -p 8080:8080 go-static-app:prod

# Remove stopped containers and dangling images
clean:
	docker system prune -f
