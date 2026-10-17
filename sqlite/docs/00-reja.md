# SQLite rejasi: embedded baza, ichki tuzilish va edge/mobil ekotizimi

Nima uchun alohida: SQLite dunyodagi eng ko'p o'rnatilgan baza (har telefon, brauzer, OS, ko'p desktop ilova ichida). U server emas, kutubxona: ilova jarayoni ichida ishlaydi, butun baza bitta fayl. Shuning uchun uning qarorlari (dynamic typing, bitta yozuvchi, fayl lock'lari) server bazalardan butunlay farq qiladi va ko'pchilik dasturchi uni "o'yinchoq" deb noto'g'ri baholaydi. Aslida to'g'ri sozlangan SQLite (WAL, `STRICT`, PRAGMA'lar) kichik va o'rta veb-ilovalar, CLI asboblar, test muhiti, edge va mobil uchun production darajasidagi tanlov. Frontend fonida bu modul alohida foydali: brauzerda SQLite (WASM, OPFS), Electron/Tauri, React Native.

Boshlash: `sql/` I–II bosqich (DDL/DML, join, aggregatsiya). `theory/` dagi B-tree va WAL nazariyasi II bosqichdan oldin tanish bo'lsa yaxshi. `postgres/` dan oldin ham, keyin ham o'tish mumkin; keyin o'tilsa farqlar jadvali tezroq tushuniladi.

Ishlash tartibi: dars `sqlite/docs/NN-slug.md`, kod `sqlite/NN-slug/main.sql`, test `sqlite/NN-slug/test.sql` (SQLite'da tayyor TAP freymvork yo'q, shuning uchun test `SELECT CASE WHEN ... THEN 'ok' ELSE raise(ABORT, '...') END` uslubida yoki Python/Go testi orqali, dars aytadi). Ishga tushirish: `make lite n=03` (`sqlite3 -bail` bilan `sqlite/NN-slug/db.sqlite` faylida, fayl git'ga kirmaydi), testlar `make lite-test n=03`, interaktiv `make shell db=sqlite`. SQLite konteyner talab qilmaydi (lokal `sqlite3` CLI yoki `ldb-sqlite` yordamchi konteyner, Makefile qaysi biri borligini o'zi tanlaydi). UDF va backup API mavzularida Go (`../learn-golang`) yoki Python (`../learn-python`) kodi ham yoziladi.

## Vaqt hisobi

| Bosqich | Mavzular | Umumiy (2–3 soat/kun) | Siz uchun | Sabab |
|---|---|---|---|---|
| I: Asoslar va tiplar | 4 | 1.5 hafta | 1 hafta | SQL tanish; type affinity va CLI farqlari yangi |
| II: Ichki tuzilish va concurrency | 4 | 2 hafta | 2 hafta | Fayl lock'lari, journal/WAL, bitta yozuvchi modeli: server bazalardan boshqacha |
| III: Kengaytmalar va dasturlash | 4 | 2 hafta | 1.5 hafta | JSON, FTS5 tanish g'oyalar; UDF va virtual table yangi |
| IV: Ekotizim va loyiha | 3 | 1.5–2 hafta | 1.5 hafta | Brauzer (WASM) va mobil tajribangizga yaqin |
| **Jami** | **15** | **7–8 hafta** | **6 hafta** (2–3 soat/kun), **3 hafta** (5–6 soat/kun) | |

## Boshqa DBlar bilan solishtirish

| Mavzu | SQLite | PostgreSQL | MySQL |
|---|---|---|---|
| Model | kutubxona, ilova jarayoni ichida | client-server | client-server |
| Saqlash | bitta fayl (+ `-wal`, `-shm`) | katalog, ko'p fayl | katalog, tablespace fayllari |
| Tiplash | dynamic, type affinity (`STRICT` bilan qat'iy) | statik, qat'iy | statik, `sql_mode` ga qarab yumshoq |
| Concurrency | ko'p o'quvchi, bitta yozuvchi (WAL'da o'quvchi yozuvchini bloklamaydi) | MVCC, ko'p yozuvchi | MVCC, row lock |
| Foydalanuvchi va huquq | yo'q (fayl tizimi huquqi) | rollar, GRANT, RLS | user, GRANT |
| Stored procedure | yo'q, o'rniga ilova tilida UDF | PL/pgSQL | stored program |
| Trigger | bor (`BEFORE`/`AFTER`/`INSTEAD OF`, faqat `FOR EACH ROW`) | bor, to'liq | bor |
| `ALTER TABLE` | cheklangan (12 qadamli "yangi jadval yasash" usuli) | to'liq | to'liq |
| Replikatsiya | ichida yo'q (Litestream, LiteFS, libSQL) | streaming, logical | binlog |
| Qachon | embedded, edge, mobil, test, bitta server ilova | umumiy maqsadli server | veb, OLTP |

## I bosqich: Asoslar va tiplar
1. **Arxitektura va qachon SQLite**: kutubxona sifatidagi baza (serverless, zero-config), tarkibiy qismlar (tokenizer, parser, code generator, VDBE bytecode mashinasi, B-tree qatlami, pager, OS interfeysi VFS), `EXPLAIN` bilan VDBE opcode'larini ko'rish, bitta fayl formati (barqaror, 2050 gacha kafolatlangan, kross-platforma), "SQLite `fopen()` bilan raqobatlashadi, Oracle bilan emas" falsafasi, rasmiy "Appropriate Uses For SQLite" sahifasi, cheklovlar (bir vaqtda bitta yozuvchi, tarmoq fayl tizimi (NFS) ustida xavf), test qamrovi va ishonchlilik (100% MC/DC), litsenziya (public domain)
2. **sqlite3 CLI va asosiy ish**: dot-buyruqlar (`.open`, `.tables`, `.schema`, `.indexes`, `.mode` (box, table, csv, json, markdown, line), `.headers`, `.timer`, `.import --csv`, `.output`, `.once`, `.read`, `.dump`, `.backup`, `.recover`, `.expert` (indeks tavsiyasi), `.eqp on`, `.parameter set`, `.bail on`), `-cmd` va skript rejimi, `sqlite_schema` (`sqlite_master`) jadvali, `ATTACH DATABASE` va bir nechta faylga so'rov, `:memory:` baza va testlarda ishlatish, GUI (DB Browser for SQLite, Datasette), `sqlite-utils` qisqa
3. **Dynamic typing va type affinity**: storage class'lar (`NULL`, `INTEGER`, `REAL`, `TEXT`, `BLOB`), qiymat tipi vs ustun affinity (`TEXT`, `NUMERIC`, `INTEGER`, `REAL`, `BLOB`), affinity'ni tip nomidan aniqlash qoidalari (`VARCHAR(10)` uzunlikni cheklamaydi, `"STRING"` NUMERIC bo'lib qoladi tuzog'i), `typeof()`, taqqoslashda affinity, sana va vaqt tipi yo'qligi (`TEXT` ISO-8601, `REAL` Julian, `INTEGER` Unix vaqt) va funksiyalar (`date`, `time`, `datetime`, `julianday`, `unixepoch`, `strftime`, modifikatorlar), `BOOLEAN` yo'qligi, `STRICT` jadvallar (3.37+: `INT`, `INTEGER`, `REAL`, `TEXT`, `BLOB`, `ANY`), `WITHOUT ROWID` jadvallar va qachon foydali, `rowid` va `INTEGER PRIMARY KEY` alias, `AUTOINCREMENT` nima qiladi va nega odatda kerak emas
4. **SQL dialekt xususiyatlari va schema o'zgartirish**: `UPSERT` (`ON CONFLICT DO UPDATE`), `RETURNING` (3.35+), window functions va CTE (rekursiv ham), `FILTER`, generated columns (`VIRTUAL` va `STORED`), partial va expression index, `CHECK`, foreign key'lar default o'chiq (`PRAGMA foreign_keys = ON` har ulanishda), `ALTER TABLE` imkoniyatlari (`RENAME`, `ADD COLUMN`, `DROP COLUMN` 3.35+) va qolgan hamma narsa uchun rasmiy 12 qadamli usul (yangi jadval, nusxa, almashtirish, `PRAGMA foreign_key_check`), `REPLACE` ning yashirin `DELETE` + `INSERT` ekanligi, `LIMIT` `UPDATE`/`DELETE` da (compile flag), `NULL` va `UNIQUE`, SQLite'da yo'q narsalar ro'yxati (`RIGHT JOIN` 3.39 gacha, `FULL JOIN` 3.39 gacha, stored procedure, `GRANT`)

## II bosqich: Ichki tuzilish va concurrency
5. **Fayl formati, B-tree va pager**: database header (100 bayt), page o'lchami (`PRAGMA page_size`, default 4096), table B-tree (rowid bo'yicha, ma'lumot leaf'da) vs index B-tree, overflow page'lar, freelist va `VACUUM`/`auto_vacuum` (`FULL`, `INCREMENTAL`), `PRAGMA page_count`, `freelist_count`, `sqlite3_analyzer` bilan jadval o'lchamini tahlil qilish, page cache (`PRAGMA cache_size`), `mmap_size`, `dbstat` virtual jadvali, `sqlite3 .dbinfo`
6. **Rollback journal, WAL va durability**: rollback journal rejimlari (`DELETE`, `TRUNCATE`, `PERSIST`, `MEMORY`, `OFF`) qanday atomik commit qiladi, WAL rejimi (`PRAGMA journal_mode = WAL`, `-wal` va `-shm` fayllar, checkpoint: `PASSIVE`/`FULL`/`RESTART`/`TRUNCATE`, `wal_autocheckpoint`), WAL'ning afzalligi (o'quvchi yozuvchini bloklamaydi) va cheklovlari (bitta xostda, tarmoq FS'da yo'q), `PRAGMA synchronous` (`OFF`, `NORMAL`, `FULL`, `EXTRA`) va WAL bilan `NORMAL` nega yetarli, crash'da nima yo'qoladi, `wal2` va `BEGIN CONCURRENT` branch'lari (asosiy relizda emas), fsync va SSD
7. **Tranzaksiyalar va locking**: lock holatlari (`UNLOCKED`, `SHARED`, `RESERVED`, `PENDING`, `EXCLUSIVE`), `BEGIN DEFERRED` vs `IMMEDIATE` vs `EXCLUSIVE`, `SQLITE_BUSY` va `busy_timeout` (`PRAGMA busy_timeout`), read-dan-write'ga ko'tarilishda deadlock va nega `BEGIN IMMEDIATE` ni yozuvchi tranzaksiyalarda ishlatish kerak, autocommit, `SAVEPOINT`/`RELEASE`, isolation (aslida serializable, chunki bitta yozuvchi), bitta ulanish ichidagi isolation tuzoqlari, ko'p jarayonli va ko'p thread'li ilova (`SQLITE_THREADSAFE`, ulanishni thread'lar orasida bo'lishmaslik), veb-serverda yozish navbati (bitta writer ulanish + ko'p reader pool) pattern'i
8. **PRAGMA'lar, query planner va optimizatsiya**: production uchun tavsiya etilgan PRAGMA to'plami (`journal_mode=WAL`, `synchronous=NORMAL`, `foreign_keys=ON`, `busy_timeout`, `cache_size`, `temp_store=MEMORY`), `PRAGMA optimize` va `ANALYZE` (`sqlite_stat1`, `sqlite_stat4`), `EXPLAIN QUERY PLAN` o'qish (`SCAN`, `SEARCH`, `USING INDEX`, `USING COVERING INDEX`, `USE TEMP B-TREE FOR ORDER BY`), next-generation query planner, `.expert` indeks tavsiyalari, `INDEXED BY` va `NOT INDEXED`, `likelihood()`, skip-scan, bulk insert tezligi (bitta tranzaksiya, prepared statement, `PRAGMA` lar), `PRAGMA integrity_check` va `quick_check`, `VACUUM INTO`

## III bosqich: Kengaytmalar va dasturlash
9. **JSON va JSONB**: JSON1 funksiyalari endi ichki (`json`, `json_extract`, `->` va `->>` operatorlari 3.38+, `json_set`, `json_insert`, `json_replace`, `json_remove`, `json_patch`, `json_array`, `json_object`, `json_group_array`, `json_group_object`, `json_each`, `json_tree`, `json_valid`), JSONB binar format (3.45+, `jsonb()` va `jsonb_*` funksiyalar, matn bilan farqi va qachon tezroq), JSON yo'lga expression index, generated column orqali JSON maydonni indekslash, PG JSONB bilan solishtirish
10. **FTS5 va R*Tree**: FTS5 virtual jadval (`CREATE VIRTUAL TABLE ... USING fts5`), `MATCH` sintaksisi (prefix, phrase, `NEAR`, `AND/OR/NOT`, ustun filtri), `bm25()` ranking, `highlight()`, `snippet()`, tokenizer'lar (`unicode61` va `remove_diacritics`, `porter`, `trigram` fuzzy/substring uchun), external content jadval va trigger bilan sinxronlash, `optimize` va `merge` buyruqlari, FTS4 dan farqi; R*Tree moduli (bounding box, geo qidiruv), Geopoly qisqa, SpatiaLite qisqa
11. **Application-defined functions (UDF) va trigger'lar**: stored procedure o'rniga ilova tilida funksiya, `sqlite3_create_function` g'oyasi, Python (`sqlite3.Connection.create_function`, `create_aggregate`, `create_window_function`, `deterministic=True` va indekslarda ishlatish) va Go (`mattn/go-sqlite3` `RegisterFunc`, `modernc.org/sqlite` cgo'siz variant), collation yaratish (`create_collation`, o'zbek alifbosi bo'yicha tartiblash misoli), trigger'lar (`BEFORE`/`AFTER`/`INSTEAD OF`, `WHEN`, `NEW`/`OLD`, `RAISE(ABORT/FAIL/IGNORE/ROLLBACK, msg)`, `recursive_triggers`), trigger + UDF bilan audit va validatsiya, run-time loadable extension'lar (`load_extension`, `sqlean` to'plami)
12. **Virtual table'lar va kengaytmalar**: virtual table tushunchasi (`xBestIndex`, `xFilter` g'oyasi), ichki modullar (`generate_series`, `dbstat`, `json_each`, `csv` extension, `sqlite_dbpage`), table-valued function, Python'da `apsw` bilan virtual table yozish, `sqlite-vec` (vektor qidiruv, `../vector/` ga havola), `sqlean` (regexp, math, stats, uuid, crypto), `carray`, SQLite'ni CSV/JSON ustidan so'rov dvigateli sifatida ishlatish, xavfsizlik (`load_extension` ni o'chirish, `SQLITE_DBCONFIG_DEFENSIVE`)

## IV bosqich: Ekotizim va loyiha
13. **Backup, replikatsiya va server rejimidagi SQLite**: online backup API (`sqlite3.Connection.backup`, `.backup` buyrug'i), `VACUUM INTO` bilan snapshot, fayl nusxalash nega xavfli (WAL holatida), Litestream (WAL'ni S3 ga uzluksiz stream qilish, restore, `minio` bilan lab), LiteFS (FUSE asosidagi replikatsiya, Fly.io), libSQL va Turso (fork, server rejimi, embedded replica, `ALTER` kengaytmalari), rqlite va dqlite (Raft ustida SQLite, `../theory/` consensus mavzusiga havola), Cloudflare D1 va Durable Objects, "bitta server + SQLite" arxitekturasi (Rails 8, Pocketbase) va uning chegaralari
14. **Brauzer, mobil va desktop'da SQLite**: SQLite WASM (rasmiy build, OPFS VFS va doimiy saqlash, Web Worker'da ishlatish), `sql.js` va farqi, IndexedDB bilan solishtirish, local-first ilovalar va sinxronizatsiya (CRDT g'oyasi, ElectricSQL, PowerSync, `cr-sqlite`), React Native (`expo-sqlite`, `op-sqlite`), Android `Room` va iOS Core Data ichida SQLite, Electron/Tauri'da `better-sqlite3`, shifrlash (SQLCipher, SEE), ORM'lar (Drizzle, Prisma SQLite) qisqa, frontend tajribangiz bilan bog'lash
15. **Loyiha: local-first CLI/veb ilova**: Go yoki Python'da kichik ilova (masalan, shaxsiy bilim bazasi yoki vazifa menejeri): `STRICT` sxema, WAL va PRAGMA to'plami, FTS5 bilan qidiruv (`bm25`, `snippet`), JSONB atributlar, UDF (o'z collation'ingiz yoki deterministik funksiya), trigger bilan audit, bitta writer + reader pool, Litestream bilan `minio` ga backup va restore mashqi, `EXPLAIN QUERY PLAN` bilan har so'rovni tekshirish, `pytest`/`go test` bilan `:memory:` testlar, README'da "nega SQLite yetarli" asoslash

## Ataylab kiritilmagan
SQLite manba kodi va VFS'ni C'da yozish, SQLite'ni o'zingiz kompilyatsiya qilish chuqur (faqat compile-time flag'lar haqida tushuncha), SpatiaLite chuqur, SQLCipher ichki tuzilishi. Standart SQL `../sql/` da, umumiy B-tree va WAL nazariyasi `../theory/` da, ilovadan drayver bilan ishlash umumiy qismi `../app/` da.

## Mezon
Har mavzu: `main.sql` `make lite n=NN` bilan `-bail` rejimida xatosiz, qayta ishga tushirilsa natija bir xil (fayl qayta yaratiladi), `sqlfluff lint` (`sqlite` dialekti) toza, test fayli o'tadi. II bosqich vazifalarida ikki terminal (ikki ulanish) bilan lock xatti-harakati amalda ko'rsatilgan va natija kommentga yozilgan. UDF mavzusida Go yoki Python kodi o'sha loyihaning `make check` qoidalariga mos.

## Manbalar
- Rasmiy hujjat: https://www.sqlite.org/docs.html (ayniqsa "Datatypes In SQLite", "Write-Ahead Logging", "File Locking And Concurrency", "Query Planner", "The SQLite Bytecode Engine", "Appropriate Uses For SQLite", "How SQLite Is Tested")
- Database file format: https://www.sqlite.org/fileformat2.html
- FTS5: https://www.sqlite.org/fts5.html, JSON: https://www.sqlite.org/json1.html
- Jay A. Kreibich, "Using SQLite" (O'Reilly)
- Ben Johnson (Litestream) bloglari: https://litestream.io/ va https://fly.io/blog/
- SQLite WASM: https://sqlite.org/wasm/doc/trunk/index.md
- Simon Willison bloglari va Datasette/sqlite-utils: https://simonwillison.net/
- sqlean: https://github.com/nalgeon/sqlean, sqlite-vec: https://github.com/asg017/sqlite-vec
- libSQL/Turso: https://docs.turso.tech/
