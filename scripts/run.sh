#!/usr/bin/env bash
# Papkadagi faylni to'g'ri DB konteynerida ishga tushiradi.
#
#   scripts/run.sh run  <papka> [db] [fayl]
#   scripts/run.sh test <papka> [db] [fayl]
#
# Fayl berilmasa: run uchun main.* (sql, js, cql, redis, cypher, sh, py), test uchun test.* qidiriladi.
# db berilmasa: modul nomidan aniqlanadi (mysql/ -> mysql, sql/ -> postgres va hokazo).
# macOS'dagi bash 3.2 bilan ishlashi uchun associative array ishlatilmagan.
set -euo pipefail

mode="${1:?run yoki test}"
dir="${2:?papka kerak}"
db="${3:-}"
file="${4:-}"

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
dir="${dir%/}"
[ -d "$dir" ] || { echo "Papka topilmadi: $dir"; exit 1; }
module="${dir%%/*}"

# ---- app/ moduli: har dars ichida go/, python/, ts/ papkalari, til lang= yoki .app-lang dan ----
if [ "$module" = app ] && [ -z "$file" ]; then
  lang="${LANG_SEL:-}"
  [ -n "$lang" ] || lang="$(cat "$root/.app-lang" 2>/dev/null || echo go)"
  if [ -d "$dir/$lang" ]; then
    cd "$dir/$lang"
    case "$lang" in
      go) if [ "$mode" = test ]; then exec go test -race ./...; else exec go run .; fi ;;
      python) if [ "$mode" = test ]; then exec "${root}/.venv/bin/python" -m pytest -q; else exec "${root}/.venv/bin/python" main.py; fi ;;
      ts) if [ "$mode" = test ]; then exec npx vitest run; else exec npx tsx main.ts; fi ;;
    esac
  fi
fi

# ---- dialekt fayllari: db= modul standartidan farq qilsa va f= berilmasa, *.<db>.sql hammasi ketma-ket ----
if [ -z "$file" ] && [ "$mode" = run ] && [ -n "$db" ]; then
  dialect_files="$(cd "$dir" && ls -1 *."$db".sql 2>/dev/null | sort -V || true)"
  if [ -n "$dialect_files" ]; then
    for df in $dialect_files; do
      echo "==> $dir/$df ($db)"
      "$0" run "$dir" "$db" "$df"
    done
    exit 0
  fi
fi

# ---- fayl tanlash ----
if [ -z "$file" ]; then
  if [ "$mode" = run ]; then
    candidates="main.sql main.js main.cql main.redis main.cypher main.sh main.py"
  else
    candidates="test.sql test.js test.cypher test.sh test_main.py"
  fi
  for c in $candidates; do
    if [ -f "$dir/$c" ]; then file="$c"; break; fi
  done
  [ -n "$file" ] || { echo "$dir ichida $mode uchun fayl yo'q (kutilgan: $candidates)"; exit 1; }
fi
path="$dir/$file"
[ -f "$path" ] || { echo "Fayl topilmadi: $path"; exit 1; }
ext="${file##*.}"

# ---- modul bo'yicha standart DB ----
if [ -z "$db" ]; then
  case "$module" in
    mysql) db=mysql ;;
    mssql) db=mssql ;;
    oracle) db=oracle ;;
    sqlite) db=sqlite ;;
    clickhouse) db=clickhouse ;;
    timeseries) db=timescale ;;
    newsql) db=cockroach ;;
    *) db=postgres ;;
  esac
fi

need() {
  local c="ldb-$1"
  if ! docker ps --format '{{.Names}}' | grep -qx "$c"; then
    echo "Konteyner $c ishlamayapti. Avval: make up db=$1"
    exit 1
  fi
}

# Konteyner ichidagi yo'l (loyiha /work ga ulangan)
wpath="/work/$path"

run_sql() {
  case "$db" in
    postgres)
      need postgres
      if [ "$mode" = test ]; then
        docker exec ldb-postgres pg_prove -U postgres -d ldb --verbose "$wpath"
      else
        docker exec -i ldb-postgres psql -U postgres -d ldb -X -q -v ON_ERROR_STOP=1 -P pager=off -f "$wpath"
      fi ;;
    timescale)
      need timescale
      docker exec -i ldb-timescale psql -U postgres -d ldb -X -q -v ON_ERROR_STOP=1 -P pager=off -f "$wpath" ;;
    mysql)
      need mysql
      docker exec -i -e MYSQL_PWD=ldb ldb-mysql sh -c "mysql -uroot --table --show-warnings ldb < '$wpath'" ;;
    mssql)
      need mssql
      docker exec -i ldb-mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Ldb_Passw0rd!' -C -b -W -d master -i "$wpath" ;;
    oracle)
      need oracle
      docker exec -i ldb-oracle bash -c "sqlplus -s -L ldb/ldb@//localhost/FREEPDB1 <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200 PAGESIZE 100 FEEDBACK ON
@$wpath
EXIT
EOF" ;;
    sqlite)
      command -v sqlite3 >/dev/null || { echo "sqlite3 yo'q: brew install sqlite"; exit 1; }
      (cd "$dir" && sqlite3 -bail -box db.sqlite < "$file") ;;
    clickhouse)
      need clickhouse
      docker exec -i ldb-clickhouse clickhouse-client -u ldb --password ldb -d ldb --multiquery --queries-file "$wpath" ;;
    cockroach)
      need cockroach
      docker exec -i ldb-cockroach cockroach sql --insecure -f "$wpath" ;;
    yugabyte)
      need yugabyte
      docker exec -i ldb-yugabyte bash -c "bin/ysqlsh -h \$(hostname) -U yugabyte -v ON_ERROR_STOP=1 -f '$wpath'" ;;
    tidb)
      need tidb
      docker run --rm -i --network ldb_default -v "$root":/work:ro mysql:8.4 \
        sh -c "mysql -h tidb -P 4000 -uroot --table test < '$wpath'" ;;
    *) echo "Noma'lum db: $db"; exit 1 ;;
  esac
}

case "$ext" in
  sql) run_sql ;;
  js)
    need mongodb
    docker exec -i ldb-mongodb mongosh --quiet "mongodb://localhost:27017/ldb?replicaSet=rs0" "$wpath" ;;
  cql)
    need cassandra
    docker exec -i ldb-cassandra cqlsh -f "$wpath" ;;
  redis)
    need redis
    docker exec -i ldb-redis sh -c "redis-cli < '$wpath'" ;;
  cypher)
    need neo4j
    docker exec -i ldb-neo4j cypher-shell -u neo4j -p ldbpassword --format plain -f "$wpath" ;;
  sh)
    # Lokal ishga tushadi; ulanish manzillari env orqali beriladi.
    export PG_URL="postgresql://postgres:ldb@localhost:5432/ldb"
    export MYSQL_URL="mysql://root:ldb@localhost:3306/ldb"
    export MONGO_URL="mongodb://localhost:27017/ldb?replicaSet=rs0&directConnection=true"
    export REDIS_URL="redis://localhost:6379"
    export ES_URL="http://localhost:9200"
    export DDB_URL="http://localhost:8000"
    export QDRANT_URL="http://localhost:6333"
    export CH_URL="http://ldb:ldb@localhost:8123"
    export S3_URL="http://localhost:9000"
    export KAFKA_BOOTSTRAP="localhost:9092"
    export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-ldb}" AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-ldbpassword}" AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
    (cd "$dir" && bash "$file") ;;
  py)
    if command -v uv >/dev/null 2>&1; then
      if [ "$mode" = test ]; then (cd "$dir" && uv run --project "$root" pytest -q); else (cd "$dir" && uv run --project "$root" python "$file"); fi
    else
      py="$root/.venv/bin/python"; [ -x "$py" ] || py=python3
      if [ "$mode" = test ]; then (cd "$dir" && "$py" -m pytest -q); else (cd "$dir" && "$py" "$file"); fi
    fi ;;
  *) echo "Qo'llab-quvvatlanmaydigan fayl turi: $file"; exit 1 ;;
esac
