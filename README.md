# pgvector-fortran

[pgvector](https://github.com/pgvector/pgvector) examples for Fortran

Supports [Libpq-Fortran](https://github.com/ShinobuAmasaki/libpq-fortran)

[![Build Status](https://github.com/pgvector/pgvector-fortran/actions/workflows/build.yml/badge.svg)](https://github.com/pgvector/pgvector-fortran/actions)

## Getting Started

Follow the instructions for your database library:

- [Libpq-Fortran](#libpq-fortran)

## Libpq-Fortran

Enable the extension

```fortran
type(c_ptr) :: res

res = PQexec(conn, "CREATE EXTENSION IF NOT EXISTS vector")
```

Create a table

```fortran
res = PQexec(conn, "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")
```

Insert vectors

```fortran
character(256) :: values(2)

values(1) = "[1,2,3]"
values(2) = "[4,5,6]"
res = PQexecParams(conn, "INSERT INTO items (embedding) VALUES ($1), ($2)", 2, [0, 0], values)
```

Get the nearest neighbors

```fortran
character(256) :: values(1)

values(1) = "[3,1,2]"
res = PQexecParams(conn, "SELECT * FROM items ORDER BY embedding <-> $1 LIMIT 5", 1, [0], values)
```

Add an approximate index

```fortran
res = PQexec(conn, "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
! or
res = PQexec(conn, "CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100)")
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](app/main.f90)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/pgvector/pgvector-fortran/issues)
- Fix bugs and [submit pull requests](https://github.com/pgvector/pgvector-fortran/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/pgvector/pgvector-fortran.git
cd pgvector-fortran
createdb pgvector_fortran_test
fpm run
```

Specify the path to libpq if needed:

```sh
FPM_CFLAGS="-I/opt/homebrew/opt/libpq/include" FPM_LDFLAGS="-L/opt/homebrew/opt/libpq/lib" fpm run
```
