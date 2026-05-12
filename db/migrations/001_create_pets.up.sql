CREATE TABLE IF NOT EXISTS pets (
    id         BIGSERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    kind       TEXT NOT NULL CHECK (kind IN ('dog', 'cat', 'fish', 'bird', 'reptile')),
    age        INTEGER NOT NULL CHECK (age >= 0 AND age <= 100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_pets_kind ON pets (kind);
