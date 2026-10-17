# Yakuniy loyihalar rejasi: butun learn-database bo'yicha portfolio

Nima uchun alohida modul: darslar bitta mavzuni chuqur o'rgatadi, loyiha esa ularni birlashtirib "ishlab chiqarishga yaroqli" tizim qurishni talab qiladi: sxema dizayni, business logic (procedure, funksiya, trigger), testlar, unumdorlik o'lchovi, backup va hujjat. Har loyiha GitHub'da alohida ko'rsatiladigan portfolio ishi va intervyuda "men buni qurdim, mana trade-off'lar" deb gapiradigan mavzu. 12 loyiha uch yo'nalishga bo'lingan: RDBMS va server-side dasturlash (1–4), NoSQL va polyglot persistence (5–7), data engineering (8–10), ichki tuzilish va platforma (11–12).

Boshlash: har loyihaning "Shart" qatoridagi modullar tugagan bo'lishi kerak. Hammasini qilish shart emas: kasb yo'nalishiga qarab tanlang (pastdagi "Yo'nalish bo'yicha tanlov" jadvali).

## Ishlash tartibi

- Har loyiha: `projects/NN-slug/` papka, reja `projects/docs/NN-slug.md` (loyiha boshlanganda Claude batafsil spetsifikatsiya yozadi: user story'lar, sxema talablari, qabul mezonlari, bosqichlar).
- Papka tuzilishi: `README.md` (arxitektura diagrammasi Mermaid'da, ishga tushirish, trade-off'lar), `docs/adr/` (arxitektura qarorlari), `schema/` yoki `migrations/` (Flyway/Liquibase/sqitch yoki vendor uslubida), `src/` (procedure, funksiya, package, pipeline kodi), `tests/` (pgTAP, tSQLt, utPLSQL, mytap, `pytest`, dbt testlari), `bench/` (yuk testi skriptlari va natijalar), `docker-compose.override.yml`, `Makefile` (loyihaning o'z buyruqlari).
- Buyruqlar: `make proj n=01` (loyihani ishga tushirish: konteynerlar, migratsiya, seed), `make proj-test n=01` (barcha testlar), `make check`.
- Loyiha "qabul qilindi" faqat: testlar yashil, README va ADR yozilgan, bench natijalari jadvalda, men tekshirib tasdiqlaganman.

## Vaqt hisobi

| Loyiha | Umumiy | Siz uchun | Shart (modullar) |
|---|---|---|---|
| 1. E-commerce OLTP backend (PostgreSQL) | 3 hafta | 2–3 hafta | `sql`, `postgres` I–V, `theory` (tranzaksiya, indeks), `ops` (migratsiya, test) |
| 2. Bitta domen, to'rt RDBMS | 4 hafta | 3–4 hafta | `postgres`, `mysql`, `mssql`, `oracle` (procedure/funksiya bosqichlari) |
| 3. Banking core (SQL Server) | 3 hafta | 3 hafta | `mssql` to'liq, `theory` (isolation, concurrency control) |
| 4. Billing tizimi (Oracle PL/SQL) | 3 hafta | 3 hafta | `oracle` to'liq |
| 5. Social feed (MongoDB + Redis) | 2–3 hafta | 2 hafta | `mongodb`, `redis`, `app` |
| 6. IoT telemetriya (Cassandra + ClickHouse) | 3 hafta | 2–3 hafta | `cassandra`, `clickhouse`, `data-engineering` VIII (Kafka) |
| 7. Mahsulot qidiruvi (Elasticsearch + CDC) | 2–3 hafta | 2 hafta | `elasticsearch`, `postgres` (logical decoding), `data-engineering` VII |
| 8. End-to-end batch ELT lakehouse | 4–5 hafta | 4 hafta | `data-engineering` I–VII, IX–XI |
| 9. Real-time streaming pipeline | 4 hafta | 3–4 hafta | `data-engineering` VIII, XI, `clickhouse` |
| 10. Data Vault 2.0 + Kimball mart | 3 hafta | 2–3 hafta | `data-engineering` II, X |
| 11. Mini DB engine (Go yoki Python) | 6–8 hafta | 5–6 hafta | `theory` to'liq, `../../learn-golang` yoki `../../learn-python` asoslari |
| 12. DB platforma Kubernetes'da | 3–4 hafta | 3 hafta | `postgres` (replication, backup), `ops` to'liq |
| **Jami (12 ta)** | **40–48 hafta** | **34–40 hafta** | |

### Yo'nalish bo'yicha tanlov

| Yo'nalish | Majburiy loyihalar | Tavsiya |
|---|---|---|
| Backend / database developer | 1, 2, 5 | 3 yoki 4, 7 |
| DBA / database reliability engineer | 1, 12 | 3, 11 |
| Data engineer | 8, 9, 10 | 6, 7 |
| Enterprise (bank, telekom, davlat) | 2, 3, 4 | 10 |
| Database internals / staff darajasi | 11 | 12, 2 |

## I bosqich: RDBMS va server-side dasturlash

1. **E-commerce OLTP backend (PostgreSQL)**: maqsad: production darajasidagi OLTP sxema va bazadagi business logic. Domen: mijozlar, mahsulotlar va variantlar, ombor qoldig'i, savat, buyurtma va qatorlari, to'lov, chegirma va promokod, audit. Stack: PostgreSQL 17/18, PL/pgSQL, pgTAP, Flyway yoki sqitch, `pgbench`, `pg_stat_statements`. Talablar: 3NF sxema va to'g'ri constraint'lar (`CHECK`, `EXCLUDE`, deferred FK), `NUMERIC` pul uchun, PL/pgSQL procedure'lar (`place_order`: qoldiqni `SELECT ... FOR UPDATE` bilan band qilish, idempotency key, xatoda rollback), funksiyalar (narx hisoblash, `STABLE`/`IMMUTABLE` to'g'ri), trigger'lar (audit jadval, `updated_at`), row-level security (mijoz faqat o'z buyurtmasini ko'radi), partitioning (buyurtmalar oy bo'yicha), indeks strategiyasi (`EXPLAIN (ANALYZE, BUFFERS)` bilan asoslangan), concurrent buyurtmada overselling yo'qligini isbotlovchi test, `pgbench` custom skript bilan TPS va p99. Baholash: pgTAP testlar (≥40 ta, sxema va logika), race condition testi, bench jadvali, migratsiyalar qayta ishga tushirilsa buzilmaydi, README'da indeks va isolation qarorlari
2. **Bitta domen, to'rt RDBMS: port va taqqoslash hisoboti**: maqsad: dialekt va server-side dasturlash farqlarini amalda ko'rish. Domen: kutubxona yoki klinika (navbat, shifokor, qabul, to'lov). Stack: PostgreSQL (PL/pgSQL, pgTAP), MySQL 8.4 (stored routines, mytap), SQL Server (T-SQL, tSQLt), Oracle 23ai Free (PL/SQL package, utPLSQL). Talablar: bitta logik model, to'rtta fizik sxema (tip xaritasi jadvali: `SERIAL`/`AUTO_INCREMENT`/`IDENTITY`/`GENERATED AS IDENTITY`, `BOOLEAN` yo'qligi, sana tiplari), har bazada bir xil 6 ta procedure va 4 ta funksiya (qabulga yozish, bekor qilish, hisob-faktura, hisobotlar), xatolarni qayta ishlash (`EXCEPTION`, `DECLARE ... HANDLER`, `TRY/CATCH` + `THROW`, `EXCEPTION WHEN` + `RAISE_APPLICATION_ERROR`), trigger, cursor va set-based variant, rekursiv CTE, window function, bir xil test to'plami har bazada, bir xil yuk testi. Baholash: to'rtala bazada testlar yashil, `docs/comparison.md`: sintaksis, tranzaksiya va isolation default'lari, locking xatti-harakati, unumdorlik, tooling va litsenziya bo'yicha jadval va xulosa
3. **Banking core (SQL Server T-SQL)**: maqsad: moliyaviy tizimda to'g'rilik, izolyatsiya va audit. Domen: mijoz, hisob, ikki tomonlama yozuv (double-entry ledger), o'tkazma, foiz hisoblash, kunlik yopish (end-of-day). Stack: SQL Server 2022/2025, T-SQL, tSQLt, SQL Agent job, Query Store. Talablar: ledger invariant (har tranzaksiyada debet = kredit) `CHECK` va procedure darajasida, `usp_Transfer` (deadlock'siz tartibli lock olish, `SET XACT_ABORT ON`, `TRY/CATCH`, `THROW`, retry on deadlock 1205), isolation tanlovi (`READ COMMITTED SNAPSHOT` vs `SNAPSHOT` vs `SERIALIZABLE`) asoslangan, temporal table (system-versioned) bilan hisob tarixi, ledger table (SQL Server 2022) yoki audit trigger, `OUTPUT` bilan audit, table-valued parameter bilan batch o'tkazma, inline TVF hisobotlar, columnstore index hisobot jadvalida, end-of-day SQL Agent job, Query Store bilan regressiya tahlili. Baholash: tSQLt testlar, parallel o'tkazma stress testida balans buzilmasligi, deadlock grafigi tahlili README'da, isolation ADR
4. **Billing tizimi (Oracle PL/SQL package'lar)**: maqsad: package-based enterprise arxitektura. Domen: telekom yoki kommunal billing: abonent, tarif, xizmat ishlatish yozuvlari (CDR), oylik hisob, to'lov, qarzdorlik. Stack: Oracle 23ai Free, PL/SQL, utPLSQL, SQL Developer/SQLcl, DBMS_SCHEDULER. Talablar: package spec va body ajratilgan (`pkg_tariff`, `pkg_rating`, `pkg_invoice`, `pkg_payment`), `%TYPE`/`%ROWTYPE`, collection'lar va `BULK COLLECT ... LIMIT` + `FORALL ... SAVE EXCEPTIONS` bilan million CDR ni rating qilish, pipelined table function hisobotlar uchun, custom exception'lar va `RAISE_APPLICATION_ERROR`, autonomous transaction bilan error log, compound trigger, `DBMS_SCHEDULER` bilan oylik hisob job, partitioning (CDR interval partition), `EXPLAIN PLAN` va `DBMS_XPLAN` bilan tuning, row-by-row vs bulk vaqt taqqoslash. Baholash: utPLSQL testlar va coverage, bulk vs row-by-row bench jadvali, package dependency diagrammasi, README

## II bosqich: NoSQL va polyglot persistence

5. **Social feed (MongoDB + Redis)**: maqsad: document modeli va kesh/real-time qatlam. Domen: foydalanuvchi, post, izoh, like, follow, timeline. Stack: MongoDB 8 (replica set), Redis 8, Go yoki Python yoki Node API (`../app/`). Talablar: schema design pattern'lari asoslangan (embedding vs referencing, bucket, outlier, computed), JSON Schema validation, compound va partial indekslar (`explain("executionStats")` bilan), aggregation pipeline (trend postlar, `$lookup`, `$facet`), multi-document transaction kerak joyda, change streams bilan bildirishnoma, Redis: fan-out-on-write timeline (sorted set), kesh (cache-aside, TTL, stampede'ga qarshi), rate limiter (Lua yoki Functions), leaderboard, pub/sub yoki Streams. Baholash: yuk testi (fan-out-on-write vs fan-out-on-read taqqoslash), index qamrovi, ADR'lar, replica set'da primary o'chganda API ishlashi
6. **IoT telemetriya (Cassandra + Kafka + ClickHouse)**: maqsad: yozishga og'ir tizim va analitika ajratish. Domen: minglab qurilmadan sensor o'lchovlari, alert, kunlik hisobot. Stack: Kafka (KRaft), Cassandra 5 (3 node), ClickHouse, generator skripti. Talablar: query-first Cassandra model (partition key'da vaqt bucket, clustering order, TTL, unbounded partition'dan qochish), consistency level tanlovi (`LOCAL_QUORUM`) va node o'chirilganda xatti-harakat, compaction strategiyasi (TWCS) asoslangan, Kafka'dan Cassandra'ga va ClickHouse'ga yozish, ClickHouse `MergeTree` + materialized view bilan minutlik/soatlik rollup, tombstone muammosini ko'rsatish va oldini olish. Baholash: yozish throughput bench, `nodetool` chiqishlari tahlili, ClickHouse so'rov tezligi jadvali, ADR
7. **Mahsulot qidiruvi (Elasticsearch + CDC PostgreSQL'dan)**: maqsad: search engine va manba bazani sinxron saqlash. Domen: e-commerce katalogi (1-loyiha sxemasidan foydalanish mumkin). Stack: PostgreSQL, Debezium + Kafka Connect, Elasticsearch yoki OpenSearch, kichik API. Talablar: mapping va analyzer dizayni (o'zbek/rus matni, synonym, edge n-gram autocomplete), relevance tuning (`function_score`, boost), facet/aggregation, CDC orqali real-time sinxronizatsiya (Debezium → Kafka → ES sink yoki o'z consumer'i), o'chirish va update'larni to'g'ri qayta ishlash, reindex zero-downtime (alias bilan), sinxronizatsiya lag monitoring. Baholash: manba va indeks o'rtasida divergensiya yo'qligini tekshiruvchi skript, relevance test to'plami, lag o'lchovi

## III bosqich: Data engineering

8. **End-to-end batch ELT lakehouse**: maqsad: OLTP'dan dashboard'gacha to'liq zamonaviy pipeline. Stack: PostgreSQL (manba, 1-loyiha yoki generator), Debezium yoki Airbyte/dlt (ingestion), MinIO + Iceberg (REST catalog), Spark yoki Trino (ishlov), dbt (`dbt-trino` yoki `dbt-spark`), Airflow yoki Dagster (orkestratsiya), Great Expectations yoki dbt testlari (sifat), Superset (dashboard), OpenLineage/Marquez (lineage). Talablar: bronze/silver/gold medallion, incremental yuklash va idempotentlik, SCD Type 2 dimension (dbt snapshot yoki `MERGE`), star schema gold qatlamda, write-audit-publish sifat darvozasi, backfill bir buyruq bilan, Iceberg maintenance job (compaction, snapshot expire), lineage ko'rinadi, 5 ta biznes metrikali dashboard. Baholash: `make proj n=08` bitta buyruq bilan butun stack ko'tariladi va pipeline ishlaydi, ikki marta ishga tushirishda natija bir xil, ataylab buzilgan ma'lumot darvozada ushlanadi, README'da arxitektura, ADR va resurs/xarajat tahlili
9. **Real-time streaming pipeline**: maqsad: event time, state va exactly-once bilan amaliy ish. Domen: clickstream yoki taksi buyurtmalari (real-time narx, faol haydovchilar, konversiya). Stack: Kafka 4 (KRaft) + Schema Registry (Avro yoki Protobuf), Flink SQL (yoki Spark Structured Streaming), ClickHouse, Grafana yoki Superset. Talablar: producer generatori (out-of-order va kech kelgan hodisalar ataylab), Flink'da watermark, tumbling/hopping/session oynalar, stream-table temporal join (dimension CDC'dan), deduplication, exactly-once sink (idempotent yoki transactional), checkpoint va savepoint bilan job'ni upgrade qilish, schema evolution (yangi maydon) pipeline'ni buzmasligi, consumer lag va backpressure monitoring, data quality (null/invalid hodisalar DLQ'ga). Baholash: job o'ldirilib qayta ishga tushirilganda dublikat yoki yo'qotish yo'qligi isboti, latency p95 o'lchovi, README va ADR
10. **Data Vault 2.0 warehouse va Kimball mart (dbt)**: maqsad: enterprise warehouse modellashtirish. Domen: ko'p manbali (CRM, billing, web) sug'urta yoki bank mijozlari. Stack: PostgreSQL yoki DuckDB yoki Snowflake trial, dbt, `automate_dv`, dbt testlari va contracts, dbt docs. Talablar: uchta manba (CSV/seed yoki generator) va har biri boshqa business key formatida, raw vault (hub, link, satellite, hashdiff), business vault (computed satellite), PIT va bridge jadvallar, Kimball information mart (star schema, SCD Type 2 dimension, periodic snapshot fact), semantic layer'da 5 metrika, model contracts, unit testlar, Slim CI GitHub Actions'da. Baholash: yangi manba ustuni qo'shilganda mavjud modellar buzilmaydi, tarixiy holatni istalgan sanaga qayta tiklash so'rovi, dbt docs lineage, Data Vault vs to'g'ridan Kimball ADR

## IV bosqich: Ichki tuzilish va platforma

11. **Mini DB engine (Go yoki Python)**: maqsad: bazaning ichini o'z qo'lingiz bilan qurish (`../theory/` ning amaliy imtihoni). Til: Go (`../../learn-golang`) tavsiya, Python (`../../learn-python`) ham mumkin. Talablar: sahifa (page) asosidagi fayl storage (4 KB page, slotted page), buffer pool (LRU yoki clock eviction), B+tree indeks (insert, search, range scan, split), WAL va crash recovery (redo, checkpoint, `fsync`), oddiy tranzaksiya (bitta writer yoki 2PL), SQL subset parser (`CREATE TABLE`, `INSERT`, `SELECT ... WHERE`, `JOIN` nested loop), REPL, ixtiyoriy: MVCC yoki LSM-tree variant. Baholash: crash testlari (jarayonni o'ldirib qayta ochish, ma'lumot yo'qolmaydi), B+tree property-based testlari, bench (insert/sec, point lookup), README'da arxitektura va SQLite/PostgreSQL bilan taqqoslash. Ilhom: CMU 15-445 BusTub, "Database Internals" (Petrov), "Build Your Own Database From Scratch"
12. **DB platforma Kubernetes'da (CloudNativePG)**: maqsad: DBA/DBRE ish jarayonini to'liq qurish. Stack: kind yoki k3d, CloudNativePG operator, PgBouncer, Prometheus + Grafana (`postgres_exporter` yoki CNPG metrikalari), MinIO (backup maqsadi), Barman Cloud/WAL arxiv. Talablar: 3 instance'li cluster (1 primary, 2 replica), synchronous replication sozlamasi asoslangan, connection pooling, avtomatik failover testi (primary pod'ni o'chirish, RTO o'lchash), PITR (point-in-time recovery) drill: ataylab `DROP TABLE` qilib aniq vaqtga tiklash, RPO o'lchash, rolling upgrade (minor versiya), monitoring dashboard va alert'lar (replication lag, connection, disk), runbook (failover, restore, disk to'lishi, sekin so'rov), xavfsizlik (TLS, secret, minimal privilege rollar). Baholash: failover va restore drill natijalari jadvali (RTO/RPO), runbook bo'yicha boshqa odam tiklay oladigan darajada hujjat, Grafana dashboard JSON git'da

## Ataylab kiritilmagan

- Frontend qismi bor to'liq mahsulotlar: API faqat kerak joyda va minimal (asosiy e'tibor bazada).
- Real bulut infratuzilmasida doimiy ishlaydigan loyiha: hammasi lokal docker yoki kind'da, bulut faqat ixtiyoriy (10-loyihada Snowflake trial).
- Kerak bo'lsa alohida loyiha so'rang (masalan graph DB bilan fraud detection, vector DB bilan RAG qidiruv: `../graph/` va `../vector/` rejalarining oxirgi mavzulari kichik loyiha sifatida).

## Mezon

- Barcha testlar yashil (`make proj-test n=NN`), `make check` toza.
- Bitta buyruq bilan ko'tariladi (`make proj n=NN`), toza mashinada README bo'yicha 15 daqiqada ishga tushadi.
- README: maqsad, arxitektura diagrammasi (Mermaid), ishga tushirish, sxema, asosiy qarorlar, bench natijalari, ma'lum cheklovlar.
- Kamida 3 ta ADR (`docs/adr/0001-*.md`).
- Bench yoki drill natijalari raqamlar bilan (TPS, p99, RTO/RPO, latency, xarajat).
- Men tekshirib tasdiqlaganman va siz loyihani 10 daqiqada intervyu uslubida tushuntira olasiz.

## Manbalar

- Kleppmann, "Designing Data-Intensive Applications": polyglot persistence va trade-off'lar
- Petrov, "Database Internals" (11-loyiha); CMU 15-445/645: https://15445.courses.cs.cmu.edu/
- Reis, Housley, "Fundamentals of Data Engineering" (8–10-loyihalar)
- Linstedt, Olschimke, "Building a Scalable Data Warehouse with Data Vault 2.0" (10-loyiha)
- Feuerstein, "Oracle PL/SQL Programming" (4-loyiha); Ben-Gan, "T-SQL Fundamentals" va "T-SQL Querying" (3-loyiha)
- CloudNativePG hujjatlari: https://cloudnative-pg.io/documentation/ (12-loyiha)
- pgTAP: https://pgtap.org/, tSQLt: https://tsqlt.org/, utPLSQL: https://www.utplsql.org/, MyTAP: https://github.com/hepabolu/mytap
- ADR shablonlari: https://adr.github.io/
