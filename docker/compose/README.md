# Laboratoriya compose fayllari

Asosiy `docker-compose.yml` da har DB bitta tugunda. Klaster, replika va HA mashqlari uchun qo'shimcha fayllar shu papkada, nomi profil nomi bilan bir xil: `make up db=<nom>` ularni avtomatik ulaydi (`-f docker-compose.yml -f docker/compose/<nom>.yml --profile <nom>`). Fayl tegishli dars yozilganda qo'shiladi.

| Profil | Modul va mavzu | Tarkib |
|---|---|---|
| `postgres-replica` | postgres: replication | primary + streaming replica, PgBouncer |
| `patroni` | postgres: HA | 3 Patroni tugun + etcd |
| `mysql-replica` | mysql: replication | source + replica (GTID) |
| `mysql-cluster` | mysql: Group Replication | 3 tugun + MySQL Router |
| `mssql-ag` | mssql: Always On | 3 instance (`ldb-mssql2`, `ldb-mssql3`) |
| `mongodb-sharded` | mongodb: sharding | config RS + 2 shard RS + mongos |
| `cassandra-cluster` | cassandra: multi-node | 3 tugun (`ldb-cassandra-1..3`) |
| `scylla` | cassandra: ScyllaDB | ScyllaDB bitta tugun |
| `redis-cluster` | redis: Cluster | 6 tugun (3 master + 3 replica) |
| `redis-sentinel` | redis: Sentinel | master + 2 replica + 3 sentinel |
| `localstack` | dynamodb: Streams + Lambda | LocalStack |
| `clickhouse-cluster` | clickhouse: Distributed | 2 shard x 2 replika + 3 Keeper |
| `cockroach-cluster` | newsql: replication, chaos | 3 tugun (`ldb-cockroach-1..3`) |
| `tidb-cluster` | newsql: TiDB | PD + TiKV + TiDB + TiFlash |
| `tsdb` | timeseries | InfluxDB 3, QuestDB, Prometheus, Grafana |
| `vectordb` | vector | Milvus, Weaviate, Chroma |
| `spark`, `flink`, `airflow`, `superset` | data-engineering | tegishli bosqichlarda |
