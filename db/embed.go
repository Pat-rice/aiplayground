package db

import "embed"

//go:embed migrations/*.sql
var MigrationsFS embed.FS

//go:embed seeds/*.sql
var SeedsFS embed.FS
