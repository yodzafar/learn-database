# learn-database

Ma'lumotlar bazalari va data engineering'ni professional darajagacha o'rganish uchun shaxsiy o'quv loyihasi. Tuzilma va ish uslubi `../learn-golang` va `../learn-python` bilan bir xil: har modulda reja (`docs/00-reja.md`), darslar (`docs/NN-*.md`), progress (`docs/PROGRESS.md`) va sizning kodingiz (`NN-*/` papkalar). Claude o'qituvchi va reviewer, kodni siz yozasiz (`CLAUDE.md`).

Qamrov: DB nazariyasi va ichki tuzilishi, standart SQL, to'rtta asosiy RDBMS (PostgreSQL, MySQL, SQL Server, Oracle) procedura, funksiya, trigger, cursor, paketlari bilan to'laqonli, SQLite, NoSQL (MongoDB, Cassandra, Redis, DynamoDB), search (Elasticsearch), graph (Neo4j), OLAP (ClickHouse), NewSQL (CockroachDB, YugabyteDB, TiDB), time-series, vector DB, to'liq data engineering yo'nalishi, DBA/ops, ilovadan DB bilan ishlash, masalalar va yakuniy loyihalar.

## Tuzilma

```
learn-database/
├── ROADMAP.md                 # haftalar bo'yicha jadval: nima ketma-ket, nima parallel
├── PROGRESS.md                # modullar bo'yicha indeks
├── Makefile                   # barcha buyruqlar, `make help`
├── docker-compose.yml         # barcha DBlar, har biri o'z profilida (make up db=...)
├── docker/                    # maxsus image'lar (postgres + pgTAP/pgvector/PostGIS/pg_cron), trino katalog
├── scripts/                   # run.sh (faylni to'g'ri DB'da ishga tushirish), shell.sh, test-all.sh
├── .sqlfluff                  # SQL lint (har vendor modulida o'z dialekti)
│
├── theory/                    # 1) Nazariya va ichki tuzilish: relational model, normalizatsiya, ACID,
│                              #    isolation, MVCC, B-tree/LSM, WAL/ARIES, optimizer, distributed, mini-DB
├── sql/                       # 2) Standart SQL (ANSI/ISO), PostgreSQL'da, har mavzuda dialekt farqlari
│   ├── docs/                  #    00-reja.md, 01-sql-basics.md, schema/shop.sql, PROGRESS.md
│   └── 01-sql-basics/         #    sizning kodingiz: main.sql (+ test.sql)
│
├── postgres/                  # 3) PostgreSQL 18 chuqur: MVCC, indekslar, PL/pgSQL, replication, tuning
├── mysql/                     # 4) MySQL 8.4: InnoDB, stored programs, replication, InnoDB Cluster, MariaDB
├── mssql/                     # 5) SQL Server 2022: T-SQL to'laqonli, plans, Query Store, Always On
├── oracle/                    # 6) Oracle 23ai: PL/SQL (paketlar, collections, bulk), RMAN, AWR
├── sqlite/                    # 7) SQLite: embedded, WAL, FTS5, JSON, edge (libSQL/Turso)
│
├── mongodb/                   # 8) MongoDB 8.0: schema design, aggregation, sharding, transactions
├── cassandra/                 # 9) Cassandra 5.0 va ScyllaDB: query-first modeling, consistency, SAI
├── redis/                     # 10) Redis 8: tuzilmalar, Lua va Functions, Streams, Cluster, Query Engine
├── dynamodb/                  # 11) DynamoDB: single-table design, GSI, Streams (DynamoDB Local)
├── elasticsearch/             # 12) Elasticsearch/OpenSearch: mapping, analysis, Query DSL, aggregations
├── graph/                     # 13) Neo4j va Cypher, GDS, Apache AGE, GQL
├── clickhouse/                # 14) ClickHouse: MergeTree oilasi, MV, real-time analytics
├── newsql/                    # 15) CockroachDB, YugabyteDB, TiDB, Spanner modeli
├── timeseries/                # 16) TimescaleDB, InfluxDB 3, QuestDB
├── vector/                    # 17) pgvector, Qdrant, Milvus, ANN algoritmlari, hybrid search
│
├── data-engineering/          # 18) Data Engineering to'liq: modeling (Kimball, Data Vault), warehouse,
│                              #     lakehouse (Iceberg/Delta), Spark, Kafka, Flink, CDC, Airflow, dbt, sifat
├── ops/                       # 19) DBA/DBRE: migratsiya, CI/CD, backup/DR, HA, monitoring, K8s operatorlar
├── app/                       # 20) Ilovadan DB: pool, ORM vs SQL, N+1, outbox, multi-tenancy (Go/Python/TS)
│
├── problems/                  # Masalalar: LeetCode SQL 50, HackerRank, pgexercises, intervyu
│   ├── leetcode/0175-combine-two-tables/   # main.sql, schema.sql, test.sql
│   └── interview/0001-retention/
└── projects/                  # Yakuniy loyihalar (portfolio)
```

Qoidalar:
- Har kod papkasi `<modul>/NN-slug/`, asosiy fayl modulga qarab: SQL modullarida `main.sql` (yoki `task_N.sql`), MongoDB `main.js`, Cassandra `main.cql`, Redis `main.redis`, Neo4j `main.cypher`, Elasticsearch/DynamoDB `main.sh`. Test: `test.sql` (pgTAP, MyTAP, tSQLt, utPLSQL), `test.js`, `test.sh`.
- Fayl qayta ishga tushirilsa ham xato bermasin (idempotent), har dars o'z sxemasida (`lesson05`).
- Hujjatlar faqat `docs/` papkalarida, kod faqat raqamli papkalarda.

## Versiyalar

| DB / asbob | Versiya (docker image) | Klient |
|---|---|---|
| PostgreSQL | 18 (`ldb/postgres:18`, pgTAP, pgvector, PostGIS, pg_cron, plpgsql_check, pg_partman, hypopg, PL/Python) | `psql`, DBeaver |
| MySQL | 8.4 LTS (`mysql:8.4`) | `mysql`, MySQL Shell |
| SQL Server | 2022 Developer (`mssql/server:2022-latest`, amd64, Rosetta orqali) | `sqlcmd`, VS Code mssql, DBeaver |
| Oracle | 23ai Free (`gvenzl/oracle-free:23-slim`) | SQL*Plus, SQLcl, VS Code SQL Developer |
| SQLite | 3.4x (lokal, `brew install sqlite`) | `sqlite3` |
| MongoDB | 8.0 (bitta tugunli replica set `rs0`) | `mongosh`, Compass |
| Cassandra | 5.0 | `cqlsh` |
| Redis | 8.0 | `redis-cli`, Redis Insight |
| DynamoDB | DynamoDB Local | `aws` CLI, NoSQL Workbench |
| Elasticsearch | 8.17 + Kibana | `curl`, Kibana Dev Tools |
| Neo4j | 5 + APOC + GDS | `cypher-shell`, Neo4j Browser (:7474) |
| ClickHouse | 25.3 LTS | `clickhouse-client`, :8123 |
| TimescaleDB | latest-pg17 (:5433) | `psql` |
| Qdrant | latest | REST :6333 |
| CockroachDB / YugabyteDB / TiDB | v24.3 / latest / latest | `cockroach sql`, `ysqlsh`, `mysql` |
| Kafka | 4.0 (KRaft), Kafka UI (:8080), Schema Registry (:8085), Debezium Connect 3.0 (:8083) | `kafka-*.sh` |
| MinIO, Iceberg REST, Trino | latest (MinIO konsol :9001, Iceberg REST :8181) | `mc`, Trino UI (:8082) |

Klaster, replika va HA mashqlari (Patroni, Group Replication, Always On, sharded MongoDB, Redis Cluster, 3 tugunli Cassandra/CockroachDB va h.k.), shuningdek Spark, Flink, Airflow va Superset `docker/compose/<profil>.yml` laboratoriya fayllari orqali tegishli dars bilan qo'shiladi: `make up db=redis-cluster`. Ro'yxat: `docker/compose/README.md`.

## O'rnatish (Mac, Apple Silicon)

1. Docker: **OrbStack** tavsiya etiladi (`brew install orbstack`, yengil, Rosetta avtomatik) yoki Docker Desktop (Settings > General > "Use Rosetta for x86_64/amd64 emulation" yoqilsin, SQL Server uchun shart). Xotira: kamida 8 GB ajrating; Oracle, SQL Server, Cassandra va Elasticsearch har biri 1–2 GB yeydi, hammasini birdan ko'tarmang.
2. `brew install sqlite uv` (ixtiyoriy: `brew install --cask dbeaver-community`).
3. `make doctor`: muhit tekshiruvi.
4. `make setup`: `.venv` va `sqlfluff`.
5. `make up db=postgres`, keyin `make shell db=postgres`. Birinchi build pgTAP va kengaytmalarni o'rnatadi (bir necha daqiqa).
6. Test freymvorklari kerak bo'lganda: `make install-tests db=mysql|mssql|oracle`.

## Buyruqlar

```
make up db=postgres                ko'tarish (rdbms, nosql, de, newsql, all guruhlari ham bor)
make shell db=oracle               interaktiv klient
make reset db=mysql                toza qayta boshlash (volume o'chadi)
make down                          hammasini to'xtatish

make sql n=01                      sql/01-*/main.sql (PostgreSQL'da)
make sql n=03 db=mssql             o'sha faylni SQL Server'da
make pg n=05, make my n=05, make ms n=05, make ora n=05, make lite n=02
make mongo n=03, make cass n=02, make rds n=04, make ddb n=01, make es n=02, make graph n=01
make ch n=03, make nsql n=02 db=tidb, make ts n=01, make vec n=02, make th n=04
make de n=10, make ops n=03, make app n=02, make proj n=01
make lc n=0175                     problems/leetcode/0175-*/
make pg-test n=14                  test.sql (pgTAP)
make new d=postgres/05-mvcc        yangi papka

make lint                          sqlfluff
make check                         lint + barcha testlar
```

Ulanish ma'lumotlari (faqat lokal): PostgreSQL `postgres/ldb@localhost:5432/ldb`, MySQL `root/ldb@localhost:3306/ldb`, SQL Server `sa/Ldb_Passw0rd!@localhost:1433`, Oracle `ldb/ldb@localhost:1521/FREEPDB1`, MongoDB `mongodb://localhost:27017/?replicaSet=rs0&directConnection=true`, Neo4j `neo4j/ldbpassword`, ClickHouse `ldb/ldb@localhost:8123`, MinIO `ldb/ldbpassword`.

## Qayerdan boshlash

`ROADMAP.md` dagi tartib: `sql/docs/01-sql-basics.md` va parallel `theory/` I bosqichi. Keyin PostgreSQL asosiy, qolgan RDBMS'lar va NoSQL parallel, data engineering SQL va bitta RDBMS chuqur o'tilgach.
