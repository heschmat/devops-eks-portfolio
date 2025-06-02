.PHONY: dev down rebuild

dev:
	docker compose -f docker-compose.dev.yml up --build

down:
	docker compose -f docker-compose.dev.yml down

rebuild:
	docker compose -f docker-compose.dev.yml down
	docker compose -f docker-compose.dev.yml up --build
