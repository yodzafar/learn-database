#!/usr/bin/env bash
# Interaktiv klient: scripts/shell.sh <db>
set -euo pipefail
db="${1:?db kerak: postgres|mysql|mssql|oracle|mongodb|cassandra|redis|neo4j|clickhouse|timescale|cockroach|yugabyte|tidb|sqlite|kafka}"
c="ldb-$db"
[ "$db" = sqlite ] || [ "$db" = tidb ] || docker ps --format '{{.Names}}' | grep -qx "$c" || { echo "$c ishlamayapti. Avval: make up db=$db"; exit 1; }
case "$db" in
  postgres)   exec docker exec -it ldb-postgres psql -U postgres -d ldb ;;
  timescale)  exec docker exec -it ldb-timescale psql -U postgres -d ldb ;;
  mysql)      exec docker exec -it -e MYSQL_PWD=ldb ldb-mysql mysql -uroot ldb ;;
  mssql)      exec docker exec -it ldb-mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Ldb_Passw0rd!' -C ;;
  oracle)     exec docker exec -it ldb-oracle sqlplus ldb/ldb@//localhost/FREEPDB1 ;;
  mongodb)    exec docker exec -it ldb-mongodb mongosh "mongodb://localhost:27017/ldb?replicaSet=rs0" ;;
  cassandra)  exec docker exec -it ldb-cassandra cqlsh ;;
  redis)      exec docker exec -it ldb-redis redis-cli ;;
  neo4j)      exec docker exec -it ldb-neo4j cypher-shell -u neo4j -p ldbpassword ;;
  clickhouse) exec docker exec -it ldb-clickhouse clickhouse-client -u ldb --password ldb -d ldb ;;
  cockroach)  exec docker exec -it ldb-cockroach cockroach sql --insecure ;;
  yugabyte)   exec docker exec -it ldb-yugabyte bash -c 'bin/ysqlsh -h $(hostname) -U yugabyte' ;;
  tidb)       exec docker run --rm -it --network ldb_default mysql:8.4 mysql -h tidb -P 4000 -uroot test ;;
  kafka)      exec docker exec -it ldb-kafka bash -c 'cd /opt/kafka/bin && exec bash' ;;
  sqlite)     exec sqlite3 ;;
  *) echo "Noma'lum db: $db"; exit 1 ;;
esac
