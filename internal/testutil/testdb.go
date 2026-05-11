package testutil

import (
	"context"
	"fmt"
	"io/fs"
	"log"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/ory/dockertest/v3"
	"github.com/ory/dockertest/v3/docker"

	_ "github.com/golang-migrate/migrate/v4/database/pgx/v5"

	dbpkg "github.com/patrice/petstore-api/db"
	"github.com/patrice/petstore-api/internal/migrate"
)

type TestDB struct {
	Pool     *pgxpool.Pool
	pool     *dockertest.Pool
	resource *dockertest.Resource
}

func SetupTestDB() (*TestDB, error) {
	pool, err := dockertest.NewPool("")
	if err != nil {
		return nil, fmt.Errorf("could not construct dockertest pool: %w", err)
	}

	if err := pool.Client.Ping(); err != nil {
		return nil, fmt.Errorf("could not connect to Docker: %w", err)
	}

	pool.MaxWait = 60 * time.Second

	resource, err := pool.RunWithOptions(&dockertest.RunOptions{
		Repository: "postgres",
		Tag:        "16-alpine",
		Env: []string{
			"POSTGRES_DB=petstore_test",
			"POSTGRES_USER=postgres",
			"POSTGRES_PASSWORD=postgres",
			"listen_addresses='*'",
		},
	}, func(config *docker.HostConfig) {
		config.AutoRemove = true
		config.RestartPolicy = docker.RestartPolicy{Name: "no"}
	})
	if err != nil {
		return nil, fmt.Errorf("could not start postgres container: %w", err)
	}

	resource.Expire(120)

	databaseURL := fmt.Sprintf("postgres://postgres:postgres@localhost:%s/petstore_test?sslmode=disable",
		resource.GetPort("5432/tcp"))

	var pgPool *pgxpool.Pool
	if err := pool.Retry(func() error {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		var err error
		pgPool, err = pgxpool.New(ctx, databaseURL)
		if err != nil {
			return err
		}
		return pgPool.Ping(ctx)
	}); err != nil {
		pool.Purge(resource)
		return nil, fmt.Errorf("could not connect to postgres: %w", err)
	}

	migrationsFS, err := fs.Sub(dbpkg.MigrationsFS, "migrations")
	if err != nil {
		pgPool.Close()
		pool.Purge(resource)
		return nil, fmt.Errorf("could not sub migrations FS: %w", err)
	}

	if err := migrate.Run(migrationsFS, databaseURL); err != nil {
		pgPool.Close()
		pool.Purge(resource)
		return nil, fmt.Errorf("could not run migrations: %w", err)
	}

	return &TestDB{
		Pool:     pgPool,
		pool:     pool,
		resource: resource,
	}, nil
}

func (tdb *TestDB) Teardown() {
	if tdb.Pool != nil {
		tdb.Pool.Close()
	}
	if err := tdb.pool.Purge(tdb.resource); err != nil {
		log.Printf("could not purge dockertest resource: %v", err)
	}
}

func (tdb *TestDB) TruncatePets(ctx context.Context) error {
	_, err := tdb.Pool.Exec(ctx, "TRUNCATE TABLE pets RESTART IDENTITY")
	return err
}

func (tdb *TestDB) SeedPets(ctx context.Context) error {
	sql, err := dbpkg.SeedsFS.ReadFile("seeds/pets.sql")
	if err != nil {
		return fmt.Errorf("could not read seed file: %w", err)
	}
	_, err = tdb.Pool.Exec(ctx, string(sql))
	return err
}
