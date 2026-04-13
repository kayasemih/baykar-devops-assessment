# ============================================================
# Baykar DevOps Case — Makefile
# ============================================================
# The command center. Type "make help" to see all available targets.
# Every operational task should be runnable from here.
# ============================================================

.DEFAULT_GOAL := help

# Colors for terminal output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m # No Color

.PHONY: help up down build test logs clean lint seed etl status

## ─── Local Development ──────────────────────────────────────

help: ## Show this help message
	@echo ""
	@echo "$(GREEN)Baykar DevOps Case — Available Commands$(NC)"
	@echo "========================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

up: ## Start all services (MongoDB + Backend + Frontend)
	@echo "$(GREEN)▶ Starting all services...$(NC)"
	cp -n .env.example .env 2>/dev/null || true
	docker compose up -d --build
	@echo ""
	@echo "$(GREEN)✓ Services are starting. Run 'make status' to check health.$(NC)"
	@echo "$(GREEN)  Frontend:  http://localhost:3000$(NC)"
	@echo "$(GREEN)  Backend:   http://localhost:5050$(NC)"
	@echo "$(GREEN)  MongoDB:   localhost:27017$(NC)"

down: ## Stop all services
	@echo "$(RED)▶ Stopping all services...$(NC)"
	docker compose down

build: ## Build all Docker images (no cache)
	@echo "$(GREEN)▶ Building images...$(NC)"
	docker compose build --no-cache

status: ## Check health of all running services
	@echo "$(GREEN)▶ Service Status:$(NC)"
	@docker compose ps
	@echo ""
	@echo "$(GREEN)▶ Health Checks:$(NC)"
	@bash scripts/health-check.sh

logs: ## Tail logs from all services
	docker compose logs -f

logs-backend: ## Tail only backend logs
	docker compose logs -f backend

logs-frontend: ## Tail only frontend logs
	docker compose logs -f frontend

## ─── Data & Testing ─────────────────────────────────────────

seed: ## Insert sample records into MongoDB
	@echo "$(GREEN)▶ Seeding database...$(NC)"
	@bash scripts/seed-db.sh

test: ## Run health checks and basic API tests
	@echo "$(GREEN)▶ Running tests...$(NC)"
	@bash scripts/health-check.sh

etl: ## Run the Python ETL job once
	@echo "$(GREEN)▶ Running ETL job...$(NC)"
	docker compose run --rm etl

## ─── Cleanup ────────────────────────────────────────────────

clean: ## Remove all containers, volumes, and images
	@echo "$(RED)▶ Cleaning up everything...$(NC)"
	docker compose down -v --rmi local --remove-orphans
	@echo "$(GREEN)✓ Clean.$(NC)"

## ─── Quality ────────────────────────────────────────────────

lint: ## Lint Dockerfiles with hadolint
	@echo "$(GREEN)▶ Linting Dockerfiles...$(NC)"
	docker run --rm -i hadolint/hadolint < apps/frontend/Dockerfile || true
	docker run --rm -i hadolint/hadolint < apps/backend/Dockerfile || true
	docker run --rm -i hadolint/hadolint < apps/etl/Dockerfile || true
	docker run --rm -i hadolint/hadolint < apps/mongodb/Dockerfile || true

scan: ## Scan Docker images for vulnerabilities (requires Trivy)
	@echo "$(GREEN)▶ Scanning images...$(NC)"
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest image baykar-frontend:latest || true
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest image baykar-backend:latest || true
