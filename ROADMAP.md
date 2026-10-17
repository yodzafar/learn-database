# ROADMAP: barcha yo'nalishlar bo'yicha yagona jadval

Bu fayl 20 ta modul rejasini, `problems/` va `projects/` ni bitta vaqt chizig'iga joylaydi. Har rejaning o'zi mavzular ro'yxati; bu yerda "qaysi haftada nima, nima bilan parallel" degan savolga javob.

## Hajm

| Modul | Mavzu | Bosqich | Modul | Mavzu | Bosqich |
|---|---|---|---|---|---|
| theory | 35 | 9 | redis | 29 | 8 |
| sql | 35 | 6 | dynamodb | 18 | 6 |
| postgres | 51 | 8 | elasticsearch | 24 | 7 |
| mysql | 42 | 7 | graph | 17 | 5 |
| mssql | 52 | 8 | clickhouse | 21 | 6 |
| oracle | 58 | 11 | newsql | 17 | 5 |
| sqlite | 15 | 4 | timeseries | 14 | 4 |
| mongodb | 38 | 9 | vector | 14 | 4 |
| cassandra | 28 | 7 | data-engineering | 56 | 12 |
| ops | 30 | 7 | app | 21 | 6 |
| **Jami** | **~615 mavzu** | | projects | 12 loyiha | 4 |
| | | | problems | ~160 masala | 5 |

## Hisob asoslari

- Kuniga o'rtacha 3.5 soat: 2–2.5 soat **asosiy yo'nalish** + 1 soat **parallel yo'nalish**. Shanba: masalalar (`problems/`) va o'tgan haftani takrorlash. Yakshanba: dam yoki qarzni yopish.
- Sizning fonigiz (Senior Frontend, 6–7 yil, JS/TS kuchli, parallel Go va Python) hisobga olingan: dasturlash, JSON, HTTP, git, Docker tanish; yangi narsa: set-based fikrlash, tranzaksiya va concurrency, DB ichki tuzilishi, procedural SQL dialektlari, distributed storage, data platformalar.
- Jami: **~100 hafta (taxminan 2 yil)** hammasi bilan. Kuniga 6 soat bo'lsa 12–14 oy. Hammasi shart emas: pastdagi "Yo'nalish bo'yicha yo'llar" jadvalida 6–14 oylik qisqa yo'llar bor.
- `learn-golang` yoki `learn-python` bilan bir vaqtda olib borilsa, kuniga 3.5 soat yetmaydi. Tavsiya: bir vaqtda faqat bitta loyiha asosiy (2–2.5 soat), boshqasi 1 soat parallel. Bu loyihani parallel olib borsangiz, quyidagi jadvalning faqat "Asosiy" ustuni 1 soatlik parallelga aylanadi va muddat 2 barobar uzayadi; shuning uchun parallel rejimda avval bitta yo'nalish (masalan Data Engineer) tanlang.
- Bir vaqtda ko'pi bilan **bitta asosiy + ikkita parallel** yo'nalish.
- Qoida: mavzu "tugadi" deyilishi uchun vazifalar bajarilgan, `make check` toza, men tekshirganman. Keyingisiga o'tish shu shart bilan.

## Bog'liqliklar (nima nimadan keyin)

```
sql I–II ──► theory II–III (normalizatsiya, tranzaksiya) ──► postgres I–III
sql I–IV ──► har qanday vendor moduli (mysql, mssql, oracle, sqlite, clickhouse, newsql)
postgres I–IV (PL/pgSQL) ──► mysql III, mssql III, oracle IV–VII (procedural SQL "farqlar orqali" tez)
theory IV–V (storage, index, optimizer) ──► postgres II–III, mssql IV, oracle VIII
theory VII (distributed: replication, partitioning, Raft, CAP) ──► mongodb VII, cassandra, dynamodb, newsql, redis VI
sql + postgres I–III + theory III ──► data-engineering I–III ──► data-engineering IV–XII
data-engineering IV (formatlar) + VIII (Kafka) ──► clickhouse IV, projects 6–9
postgres + bitta NoSQL + app ──► ops ──► projects 12
Python I–III yoki Go I–III ──► app, theory IX (mini-DB), data-engineering VI (PySpark), IX (Airflow)
```

## Vaqt chizig'i

| Hafta | Asosiy yo'nalish (2–2.5 soat) | Parallel 1 (1 soat) | Parallel 2 (shanba) | Bosqich yakuni |
|---|---|---|---|---|
| 1–4 | sql 1–14: asoslar, tiplar, NULL, JOIN, aggregatsiya, subquery | theory 1–8: relational model, algebra, ER, normalizatsiya | LeetCode SQL 50: Select, Basic Joins | |
| 5–8 | sql 15–26: CTE, window, pivot, sana/JSON, MERGE, view, DCL | theory 9–14: ACID, isolation anomaliyalari, 2PL/MVCC/SSI, deadlock | SQL 50: Aggregate, Sorting, Advanced Joins | |
| 9–11 | sql 27–35: patternlar (gaps-and-islands, top-N), anti-patternlar, procedural SQL'ga kirish | sqlite 1–15 | SQL 50 tugatish | **SQL tugadi: istalgan RDBMS'da kuchli so'rov yozasiz** |
| 12–17 | postgres 1–17: arxitektura, tiplar, MVCC, VACUUM, TOAST, indekslar, EXPLAIN | theory 15–24: storage, buffer pool, B-tree, LSM, optimizer, join algoritmlari | LeetCode Database II bosqich | |
| 18–23 | postgres 18–29: PL/pgSQL to'liq (funksiya, procedure, cursor, exception, dynamic SQL, trigger, event trigger, pgTAP) | theory 25–32: WAL/ARIES, replication, partitioning, consensus, CAP/PACELC | II bosqich tugatish | |
| 24–30 | postgres 30–51: locking, partitioning, FTS, JSONB, FDW, extension, RLS, replication, backup, tuning, loyihalar | redis 1–29 | HackerRank + pgexercises | **PostgreSQL tugadi: kuchli backend/DB muhandis** |
| 31–36 | data-engineering 1–15: landshaft, Kimball, Data Vault, analitik SQL | theory 33–35: NoSQL taksonomiyasi, DB tanlash, mini-DB loyiha (Go/Python) | intervyu: funnel, retention, sessionization | **theory tugadi** |
| 37–42 | data-engineering 16–29: formatlar, object storage, Iceberg/Delta, Trino, warehouse'lar, Spark | clickhouse 1–21 | intervyu: median, YoY, SCD, dedup | |
| 43–48 | data-engineering 30–40: ingestion, CDC (Debezium), Kafka, Flink, streaming | mongodb 1–23 | intervyu: optimizatsiya va procedura masalalari | |
| 49–53 | data-engineering 41–46: Airflow, Dagster, dbt chuqur | mongodb 24–38 | projects 8 boshlanadi (batch lakehouse) | |
| 54–57 | data-engineering 47–56: sifat, kontrakt, lineage, governance, cloud, DataOps, intervyu | app 1–21 (Go yoki Python) | projects 8–9 | **Data Engineering tugadi: Data Engineer sifatida ishga kirish mumkin** |
| 58–64 | mysql 1–42 (stored programs, InnoDB, replication, InnoDB Cluster) | cassandra 1–28 | projects 10 (Data Vault + Kimball) | **mysql tugadi** |
| 65–72 | mssql 1–52 (T-SQL to'liq, plans, Query Store, Always On) | dynamodb 1–18, elasticsearch 1–8 | projects 3 (MSSQL banking core) | **mssql tugadi** |
| 73–81 | oracle 1–58 (PL/SQL paketlar, collections, bulk, RMAN, AWR) | elasticsearch 9–24 | projects 4 (Oracle billing) | **oracle tugadi: to'rt RDBMS** |
| 82–87 | ops 1–30 (migratsiya, CI/CD, backup/DR, HA, observability, K8s operatorlar) | graph 1–17, newsql 1–6 | projects 1, 2 (PG e-commerce, to'rt RDBMS port) | **ops tugadi** |
| 88–92 | timeseries 1–14, vector 1–14 | newsql 7–17 | projects 11 (mini DB engine) | |
| 93–100 | projects 5, 6, 7, 12 (polyglot, IoT, search+CDC, CloudNativePG platforma) | qolgan masalalar, DB system design | portfolio README'lar | **Hammasi tugadi** |

## Bosqichlar qisqacha

1. **SQL poydevori (1–11 hafta).** Standart SQL PostgreSQL'da, har darsda MySQL/MSSQL/Oracle/SQLite dialekt farqlari. Parallel: nazariya (relational model, normalizatsiya, tranzaksiya). Bu bosqichsiz qolgan hamma narsa sayoz bo'ladi, qisqartirilmaydi.
2. **PostgreSQL chuqur (12–30 hafta).** Ichki tuzilish (MVCC, VACUUM, WAL), indekslar va planlar, PL/pgSQL to'liq, ekspluatatsiya. Parallel: storage/optimizer/distributed nazariyasi, Redis. Yakunida backend uchun DB bo'yicha senior darajadagi bilim.
3. **Data Engineering (31–57 hafta).** Modellashtirish, warehouse va lakehouse, Spark, Kafka va streaming, CDC, orkestratsiya, dbt, sifat va governance. Parallel: ClickHouse, MongoDB, ilovadan DB. Yakunida 3 ta DE portfolio loyihasi.
4. **Enterprise RDBMS (58–81 hafta).** MySQL, SQL Server, Oracle: har biri procedural tili (stored programs, T-SQL, PL/SQL) bilan to'laqonli. PostgreSQL'dan keyin "farqlar orqali" tezroq o'tadi. Parallel: Cassandra, DynamoDB, Elasticsearch.
5. **Ops va maxsus DBlar (82–92 hafta).** DBA/DBRE amaliyoti, graph, NewSQL, time-series, vector.
6. **Loyihalar (93–100 hafta).** Qolgan portfolio loyihalari (bir qismi oldingi bosqichlarda shanba kunlari boshlangan).

## Yo'nalish bo'yicha yo'llar (hammasi shart emas)

| Maqsad | Modullar (tartib bilan) | Taxminiy muddat (3.5 soat/kun) |
|---|---|---|
| **Data Engineer** (asosiy tavsiya) | sql → theory I–V → postgres I–IV, VII qisman → data-engineering → clickhouse → mongodb I–V → projects 8, 9, 10 | 13–15 oy |
| **Backend dasturchi, DB kuchli** | sql → theory I–VII → postgres → redis → mongodb → app → ops II–IV → projects 1, 5 | 9–10 oy |
| **DBA / DBRE** | sql → theory → postgres → mysql → mssql yoki oracle → ops → projects 12 | 14–16 oy |
| **Enterprise (bank, telekom)** | sql → theory I–VI → postgres I–IV → mssql → oracle → projects 3, 4, 2 | 12–14 oy |
| **DB internals** | sql → theory to'liq → postgres II–III → newsql → projects 11 | 7–8 oy |
| **Analytics engineer** | sql → data-engineering I–III, IV–V, X–XI → clickhouse → problems IV | 6–7 oy |

## Haftalik ritm

| Kun | Vaqt | Nima |
|---|---|---|
| Dushanba–Juma | 2–2.5 soat | Asosiy yo'nalish: nazariya o'qish, vazifalar, komment bilan tushuntirish |
| Dushanba–Juma | 1 soat | Parallel 1 |
| Shanba | 2–3 soat | Masalalar va loyiha, hafta bo'yi to'plangan savollarni menga berish |
| Yakshanba | – | Dam. Yoki hafta qarzini yopish, lekin yangi mavzu emas |

Har hafta oxirida: `make check` toza, bajarilgan vazifalar men tomondan tekshirilgan, `O'zini tekshirish savollari` ga og'zaki javob bera olasiz.

## Nazorat nuqtalari

| Hafta | Nima bo'lishi kerak |
|---|---|
| 11 | SQL: window function, rekursiv CTE, gaps-and-islands va top-N per group'ni yodaki yozasiz; `NULL` va 3VL tuzoqlarini tushuntirasiz; LeetCode SQL 50 tugagan |
| 23 | PL/pgSQL'da procedure, funksiya (volatility bilan), trigger, xato boshqaruvi va dynamic SQL injection'siz yozasiz, pgTAP bilan testlaysiz; isolation anomaliyalarini demo bilan ko'rsata olasiz |
| 30 | PostgreSQL: `EXPLAIN (ANALYZE, BUFFERS)` o'qib so'rovni tezlashtirasiz, VACUUM/bloat'ni tushuntirasiz, replication va PITR'ni qo'lda sozlagansiz. **Rezyume yangilash vaqti** |
| 36 | Mini-DB (B-tree + WAL + kichik SQL) Go yoki Python'da ishlaydi |
| 57 | Lokal lakehouse (MinIO + Iceberg + Spark/Trino + dbt + Airflow) va Kafka/Flink streaming pipeline ishlaydi, idempotent va backfill qilinadi. **DE sifatida ishga kirish** |
| 81 | To'rt RDBMS'da bir xil biznes logikani procedura/funksiya/paket bilan yoza olasiz va farqlarni tushuntirasiz |
| 92 | Har DB turi uchun "qachon tanlash" qarorini ADR bilan asoslay olasiz |
| 100 | 12 loyiha GitHub'da, har biri README, testlar, docker compose bilan |

## Agar vaqt yetmasa

Qisqartirish tartibi (birinchisi birinchi qisqaradi):
1. timeseries va vector (pgvector bilan postgres ichida yetarli), graph.
2. newsql (theory VII va postgres yetarli), dynamodb (cassandra yoki mongodb bilan g'oya o'tiladi).
3. elasticsearch VI–VII, clickhouse V, mongodb VII–VIII.
4. oracle yoki mssql dan bittasi (ish beruvchi stack'iga qarab).
5. projects: 12 dan 6 tasi (1, 2, 8, 9, 10 va yo'nalishga mos bittasi).

Qisqartirilmaydi: sql, theory I–V, postgres I–V, data-engineering (DE yo'li tanlansa), problems I–II.
