#!/usr/bin/env bash
# Vendor test freymvorklarini konteynerlarga o'rnatadi (bir marta, volume saqlanadi).
#   scripts/install-test-frameworks.sh mysql    MyTAP
#   scripts/install-test-frameworks.sh mssql    tSQLt
#   scripts/install-test-frameworks.sh oracle   utPLSQL
# pgTAP postgres image ichida allaqachon bor (docker/postgres/Dockerfile).
set -euo pipefail
db="${1:?mysql|mssql|oracle}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
case "$db" in
  mysql)
    git clone --depth 1 https://github.com/hepabolu/mytap.git "$tmp/mytap"
    docker cp "$tmp/mytap" ldb-mysql:/tmp/mytap
    docker exec -i -e MYSQL_PWD=ldb ldb-mysql sh -c 'cd /tmp/mytap && ./install.sh -u root -h 127.0.0.1 -P 3306'
    echo "MyTAP o'rnatildi (tap sxemasi)." ;;
  mssql)
    curl -fsSL -o "$tmp/tSQLt.zip" https://tsqlt.org/download/tsqlt/
    (cd "$tmp" && unzip -q tSQLt.zip)
    docker cp "$tmp" ldb-mssql:/tmp/tsqlt
    docker exec -i ldb-mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Ldb_Passw0rd!' -C -b -Q "IF DB_ID('ldb') IS NULL CREATE DATABASE ldb; ALTER DATABASE ldb SET TRUSTWORTHY ON; EXEC sp_configure 'clr enabled', 1; RECONFIGURE;"
    docker exec -i ldb-mssql bash -c 'cd /tmp/tsqlt && for f in PrepareServer.sql tSQLt.class.sql; do [ -f "$f" ] && /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Ldb_Passw0rd!" -C -b -d ldb -i "$f"; done'
    echo "tSQLt o'rnatildi (ldb bazasi)." ;;
  oracle)
    ver="$(curl -fsSL https://api.github.com/repos/utPLSQL/utPLSQL/releases/latest | sed -n 's/.*"tag_name": "\(.*\)".*/\1/p')"
    curl -fsSL -o "$tmp/ut.tar.gz" "https://github.com/utPLSQL/utPLSQL/releases/download/$ver/utPLSQL.tar.gz"
    (cd "$tmp" && tar xzf ut.tar.gz)
    docker cp "$tmp/utPLSQL" ldb-oracle:/tmp/utPLSQL
    docker exec -i ldb-oracle bash -c 'cd /tmp/utPLSQL/source && sqlplus -s -L sys/ldb@//localhost/FREEPDB1 AS SYSDBA @install_headless_with_trigger.sql ut3 ut3 users'
    echo "utPLSQL $ver o'rnatildi (ut3 sxemasi)." ;;
  *) echo "Noma'lum: $db"; exit 1 ;;
esac
