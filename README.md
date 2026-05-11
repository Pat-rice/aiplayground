# Pet Store API Template

A spec-first Go API template combining **TypeSpec**, **oapi-codegen**, **sqlc**, and **schemathesis**.

## Stack

| Tool | Role |
|---|---|
| [TypeSpec](https://typespec.io) | API contract definition |
| [oapi-codegen](https://github.com/oapi-codegen/oapi-codegen) | Go server code generation from OpenAPI |
| [sqlc](https://sqlc.dev) | Type-safe Go code from SQL queries |
| [PostgreSQL](https://www.postgresql.org) | Database (via Docker Compose) |
| [schemathesis](https://schemathesis.readthedocs.io) | API fuzz testing |

## Pipeline

```
TypeSpec (.tsp) --> OpenAPI 3.0 (YAML) --> Go server code (net/http)
SQL queries     --> Go database code (pgx/v5)
```

## Quick Start

```bash
# Start PostgreSQL
docker compose up postgres -d

# Set environment
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/petstore?sslmode=disable"

# Generate all code (TypeSpec + oapi-codegen + sqlc)
make generate

# Build and run
make run
```

Or run everything with Docker:

```bash
docker compose up --build
```

## Development

### Prerequisites

- Go 1.22+
- Node.js 20+ (for TypeSpec)
- Docker & Docker Compose
- [schemathesis](https://github.com/schemathesis/schemathesis) (for fuzz testing)

### Make Targets

| Target | Description |
|---|---|
| `make generate` | Run full generation pipeline (TypeSpec + oapi-codegen + sqlc) |
| `make generate-typespec` | Compile TypeSpec to OpenAPI YAML |
| `make generate-api` | Generate Go server code from OpenAPI |
| `make generate-db` | Generate Go database code from SQL |
| `make build` | Build the API binary |
| `make run` | Build and run locally |
| `make test` | Run unit tests |
| `make lint` | Run golangci-lint |
| `make fuzz` | Run schemathesis fuzz tests |
| `make docker-up` | Start all services |
| `make docker-down` | Stop all services |

### Project Structure

```
typespec/           TypeSpec API definition
api/                Generated OpenAPI spec
internal/api/       Generated Go server code (oapi-codegen)
internal/db/        Generated Go database code (sqlc)
internal/server/    Handler implementation
internal/config/    Configuration loading
internal/migrate/   Database migration runner
cmd/api/            Application entrypoint
db/migrations/      SQL migration files
db/queries/         SQL queries for sqlc
```

### Workflow

1. Edit `typespec/main.tsp` to change the API contract
2. Edit `db/queries/pets.sql` to change database queries
3. Run `make generate` to regenerate all code
4. Implement/update handlers in `internal/server/server.go`
5. Run `make test` and `make fuzz` to verify

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Health check |
| GET | `/pets` | List pets (with `limit` and `offset`) |
| POST | `/pets` | Create a pet |
| GET | `/pets/{petId}` | Get a pet by ID |
| PUT | `/pets/{petId}` | Update a pet |
| DELETE | `/pets/{petId}` | Delete a pet |

## License

MIT
