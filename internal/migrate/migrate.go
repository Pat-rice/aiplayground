package migrate

import (
	"errors"
	"fmt"
	"io/fs"
	"strings"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/pgx/v5"
	"github.com/golang-migrate/migrate/v4/source/iofs"
)

// Run applies all pending up migrations.
// databaseURL can use postgres:// or pgx5:// scheme; it is normalized to pgx5://.
func Run(migrationsFS fs.FS, databaseURL string) error {
	source, err := iofs.New(migrationsFS, ".")
	if err != nil {
		return fmt.Errorf("creating migration source: %w", err)
	}

	migrateURL := toPgx5Scheme(databaseURL)

	m, err := migrate.NewWithSourceInstance("iofs", source, migrateURL)
	if err != nil {
		return fmt.Errorf("creating migrator: %w", err)
	}
	defer m.Close()

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return fmt.Errorf("running migrations: %w", err)
	}

	return nil
}

func toPgx5Scheme(url string) string {
	if strings.HasPrefix(url, "postgres://") {
		return "pgx5://" + strings.TrimPrefix(url, "postgres://")
	}
	if strings.HasPrefix(url, "postgresql://") {
		return "pgx5://" + strings.TrimPrefix(url, "postgresql://")
	}
	return url
}
