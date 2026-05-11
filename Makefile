.PHONY: generate generate-typespec generate-api generate-db build run test test-unit test-integration lint fuzz docker-up docker-down seed clean

# Docker images
GOLANG_IMAGE     ?= golang:1.26-alpine
NODE_IMAGE       ?= node:22-alpine
SQLC_IMAGE       ?= sqlc/sqlc:1.30.0
LINT_IMAGE       ?= golangci/golangci-lint:v2.11.4-alpine
SCHEMATHESIS_IMAGE ?= schemathesis/schemathesis:latest

# API version used for code generation (must match a TypeSpec Versions enum value)
API_VERSION ?= 1.0

# Common docker run flags
DOCKER_RUN    := docker run --rm -v $(CURDIR):/work -w /work
DOCKER_RUN_GO := $(DOCKER_RUN) -v aiplayground-gomod:/go/pkg/mod $(GOLANG_IMAGE)

## Full code generation pipeline
generate: generate-typespec generate-api generate-db

## TypeSpec -> OpenAPI YAML (generates all versions under api/openapi-spec/<version>/)
generate-typespec:
	$(DOCKER_RUN) -w /work/api/typespec $(NODE_IMAGE) sh -c "npm install && npx tsp compile ."

## OpenAPI YAML -> Go server code (uses API_VERSION)
generate-api:
	$(DOCKER_RUN_GO) go run github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen \
		-config oapi-codegen.yaml api/openapi-spec/$(API_VERSION)/openapi.yaml

## SQL -> Go database code
generate-db:
	$(DOCKER_RUN) $(SQLC_IMAGE) generate

## Build the API binary
build:
	go build -o bin/api ./cmd/api

## Run locally (requires DATABASE_URL)
run: build
	./bin/api

## Run all tests (unit + integration, requires Docker)
test:
	go test ./...

## Lint with golangci-lint
lint:
	$(DOCKER_RUN) $(LINT_IMAGE) golangci-lint run ./...

## Fuzz test with schemathesis against running server (uses API_VERSION)
fuzz:
	$(DOCKER_RUN) --network host $(SCHEMATHESIS_IMAGE) run api/openapi-spec/$(API_VERSION)/openapi.yaml --base-url http://localhost:8080

## Start all services with Docker Compose
docker-up:
	docker compose up -d --build

## Stop all services
docker-down:
	docker compose down

## Seed the local database (requires docker-up)
seed:
	docker compose exec -T postgres psql -U postgres -d petstore < db/seeds/pets.sql

## Clean build artifacts
clean:
	rm -rf bin/ api/typespec/node_modules/ api/openapi-spec/
