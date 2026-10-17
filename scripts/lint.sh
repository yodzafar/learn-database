#!/usr/bin/env bash
# sqlfluff lint/fix. Dialekt: *.mysql.sql -> mysql, *.mssql.sql -> tsql, *.oracle.sql -> oracle,
# *.sqlite.sql -> sqlite, *.clickhouse.sql -> clickhouse; qolganlari modul .sqlfluff (standart postgres).
set -uo pipefail
cmd="${1:-lint}"
cd "$(dirname "$0")/.."
sf=".venv/bin/sqlfluff"; [ -x "$sf" ] || sf=sqlfluff
command -v "$sf" >/dev/null 2>&1 || [ -x "$sf" ] || { echo "sqlfluff yo'q: make setup"; exit 1; }
files="$(find . \( -name docs -o -name docker -o -name .venv -o -name target -o -name dbt_packages -o -name node_modules \) -prune -o -name '*.sql' -print | sed 's|^\./||' | sort)"
[ -n "$files" ] || { echo "Hali .sql fayl yo'q"; exit 0; }
rc=0
default=""
for f in $files; do
  case "$f" in
    *.mysql.sql) d=mysql ;; *.mssql.sql) d=tsql ;; *.oracle.sql) d=oracle ;;
    *.sqlite.sql) d=sqlite ;; *.clickhouse.sql) d=clickhouse ;; *) default="$default $f"; continue ;;
  esac
  "$sf" "$cmd" --dialect "$d" "$f" || rc=1
done
[ -z "$default" ] || "$sf" "$cmd" $default || rc=1
exit $rc
