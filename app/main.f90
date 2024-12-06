program main
  use iso_c_binding
  use libpq
  implicit none

  type(c_ptr) :: conn
  type(c_ptr) :: res
  character(256) :: values(3)
  integer :: ntuples
  integer :: i

  conn = PQconnectdb("postgres://localhost/pgvector_fortran_test")
  if (PQstatus(conn) /= CONNECTION_OK) then
    stop 1
  endif

  res = PQexec(conn, "CREATE EXTENSION IF NOT EXISTS vector")
  if (PQresultStatus(res) /= PGRES_COMMAND_OK) then
    stop 1
  endif
  call PQclear(res)

  res = PQexec(conn, "DROP TABLE IF EXISTS items")
  if (PQresultStatus(res) /= PGRES_COMMAND_OK) then
    stop 1
  endif
  call PQclear(res)

  res = PQexec(conn, "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")
  if (PQresultStatus(res) /= PGRES_COMMAND_OK) then
    stop 1
  endif
  call PQclear(res)

  values(1) = "[1,1,1]"
  values(2) = "[2,2,2]"
  values(3) = "[1,1,2]"
  res = PQexecParams(conn, "INSERT INTO items (embedding) VALUES ($1), ($2), ($3)", 3, [0, 0, 0], values)
  if (PQresultStatus(res) /= PGRES_COMMAND_OK) then
    stop 1
  endif
  call PQclear(res)

  values(1) = "[1,1,1]"
  res = PQexecParams(conn, "SELECT * FROM items ORDER BY embedding <-> $1 LIMIT 5", 1, [0], values)
  if (PQresultStatus(res) /= PGRES_TUPLES_OK) then
    stop 1
  endif
  ntuples = PQntuples(res)
  do i = 0, ntuples - 1
    print *, PQgetvalue(res, i, 0), ": ", PQgetvalue(res, i, 1)
  end do
  call PQclear(res)

  res = PQexec(conn, "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
  if (PQresultStatus(res) /= PGRES_COMMAND_OK) then
    stop 1
  endif
  call PQclear(res)

  call PQfinish(conn)
end program main
