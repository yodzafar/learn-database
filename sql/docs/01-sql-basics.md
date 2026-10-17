# 1-dars: SQL asoslari

Maqsad: SQL nima ekanini, qayerdan kelganini va standart bilan dialekt farqini tushunish; ish muhitini (konteyner, `psql`, DBeaver, sqlfluff) sozlash; jadval yaratish, ma'lumot kiritish va o'qishning eng kichik to'liq siklini yozish; SELECT'ning yozilish tartibi va bajarilish (logical processing) tartibi farqini, asosiy tiplarni va NULL bilan uch qiymatli mantiqni (3VL) professional darajada bilish. Bu dars keyingi barcha SQL va vendor darslarining poydevori.

Taxminiy vaqt: 3–4 kun (siz uchun). `SELECT * FROM ...` darajasidagi SQL sizga tanish bo'lishi mumkin, unga vaqt sarflamang. Diqqatni quyidagilarga qarating: SQL bag (multiset) bilan ishlaydi, to'plam bilan emas; `WHERE` da alias nega ko'rinmaydi, `ORDER BY` da nega ko'rinadi; `ORDER BY` siz qatorlar tartibi kafolatlanmaydi; `5/2 = 2`; pul uchun `NUMERIC`; `NULL = NULL` TRUE emas; `NOT IN` + NULL bo'sh natija beradi; Oracle'da `''` NULL ga teng.

---

## Boshqa DBlar bilan solishtirish

| Mavzu | Standart | PostgreSQL 18 | MySQL 8.4 | SQL Server 2022 | Oracle 23ai | SQLite 3.4x |
|---|---|---|---|---|---|---|
| Klient | – | `psql` | `mysql`, `mysqlsh` | `sqlcmd` | `sqlplus`, SQLcl | `sqlite3` |
| Versiya | – | `SELECT version();` | `SELECT VERSION();` | `SELECT @@VERSION;` | `SELECT banner_full FROM v$version;` | `SELECT sqlite_version();` |
| Birinchi N qator | `FETCH FIRST n ROWS ONLY` | `LIMIT n`, `FETCH FIRST` | `LIMIT n` | `TOP (n)`, `OFFSET ... FETCH` | `FETCH FIRST` | `LIMIT n` |
| `SELECT` `FROM` siz | yo'q | `SELECT 1;` | `SELECT 1;` | `SELECT 1;` | `SELECT 1;` (23ai), oldin `FROM dual` | `SELECT 1;` |
| String birlashtirish | `\|\|` | `\|\|` | `CONCAT()` | `+`, `CONCAT()` | `\|\|` | `\|\|` |
| Bo'sh string `''` | NULL emas | NULL emas | NULL emas | NULL emas | **NULL** | NULL emas |
| `5/2` | implementation-defined | `2` | `2.5000` | `2` | `2.5` | `2` |
| Boolean | `BOOLEAN` | bor | `TINYINT(1)` alias | yo'q, `BIT` | bor (23ai) | yo'q, 0/1 |
| DDL tranzaksiyada | – | ha, `ROLLBACK` qila oladi | yo'q, implicit commit | ha (ko'pi) | yo'q, implicit commit | ha |
| Nomsiz identifikator registri | katta harfga fold | kichik harfga fold | jadval nomi OS/`lower_case_table_names` | collation'ga bog'liq | katta harfga fold | registrsiz |
| Qo'shtirnoqli identifikator | `"Name"` | `"Name"` | `` `Name` `` (yoki `ANSI_QUOTES`) | `[Name]`, `"Name"` | `"NAME"` | `"Name"`, `` ` ``, `[ ]` |

## 1. SQL nima va qayerdan keldi

SQL (Structured Query Language) relational ma'lumotlar bazasi bilan ishlashning **deklarativ** tili: siz *qanday natija kerakligini* yozasiz, *qanday topishni* emas. Qanday topish (qaysi indeks, qaysi join algoritmi, qaysi tartib) optimizer ishi. Bu frontend'dagi farqqa o'xshaydi: CSS'da "element markazda bo'lsin" deysiz, brauzer layout'ni o'zi hisoblaydi.

Qisqa tarix:
- **1970**: Edgar F. Codd (IBM) "A Relational Model of Data for Large Shared Data Banks" maqolasi. G'oya: ma'lumot jadvallar (relation) sifatida, fizik saqlanish usulidan mustaqil.
- **1974**: Chamberlin va Boyce IBM System R loyihasida SEQUEL tilini yaratadi, keyin nomi SQL ga o'zgaradi (savdo belgisi sababli). Hozir ham "sequel" deb o'qiladi.
- **1979**: Oracle V2: birinchi tijoriy SQL DB. Keyin IBM DB2, Sybase (SQL Server shundan chiqqan), Ingres (PostgreSQL shundan chiqqan).
- **Standartlar** (ANSI, keyin ISO/IEC 9075): SQL-86, SQL-89, **SQL-92** (asosiy, ko'p darsliklar shunga tayanadi), SQL:1999 (rekursiv CTE, trigger, boolean), SQL:2003 (window function, `MERGE`, XML), SQL:2008 (`TRUNCATE`, `FETCH FIRST`), SQL:2011 (temporal jadvallar), SQL:2016 (JSON, row pattern recognition), **SQL:2023** (`JSON` tipi, `ANY_VALUE`, SQL/PGQ property graph so'rovlari).

**Standart va dialekt.** Hech bir DB standartni to'liq bajarmaydi va har biri o'z kengaytmalarini qo'shadi. Natijada "SQL" aslida oila: PostgreSQL SQL, T-SQL (SQL Server), PL/SQL bilan Oracle SQL, MySQL SQL, SQLite SQL. PostgreSQL standartga eng yaqinlaridan biri, shuning uchun bu modulda asosiy DB. https://modern-sql.com saytida har bir standart xususiyat uchun "qaysi DB qo'llaydi" jadvali bor: shubhada shunga qarang.

**SQL bo'limlari:**

| Bo'lim | Ma'nosi | Buyruqlar |
|---|---|---|
| DDL | Data Definition | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| DML | Data Manipulation | `INSERT`, `UPDATE`, `DELETE`, `MERGE` |
| DQL | Data Query | `SELECT` (ko'pincha DML ga kiritiladi) |
| DCL | Data Control | `GRANT`, `REVOKE` |
| TCL | Transaction Control | `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

## 2. Relational asos: jadval, qator, kalit

Nazariya chuqur `../theory/docs/00-reja.md` I bosqichda; bu yerda SQL yozish uchun kerakli minimum.

- **Jadval** (table, nazariyada relation): bir xil tuzilishdagi qatorlar to'plami. **Ustun** (column, attribute): nom + tip. **Qator** (row, tuple): har ustun uchun bitta qiymat.
- **Primary key**: qatorni yagona aniqlaydigan ustun(lar), `NOT NULL` va `UNIQUE`. **Foreign key**: boshqa jadvalning kalitiga havola, "yetim" qatorlarga yo'l qo'ymaydi.
- **Tartib yo'q.** Jadvaldagi qatorlarning "birinchi", "oxirgi" tushunchasi yo'q. `SELECT` natijasi tartibi faqat `ORDER BY` bilan kafolatlanadi. Bugun tartibli chiqqani ertaga (parallel scan, `VACUUM`, yangi indeks, boshqa plan) o'zgarishi mumkin.
- **Bag, to'plam emas.** Relational modelda relation to'plam (dublikat yo'q). SQL esa **bag** (multiset) bilan ishlaydi: PK bo'lmagan jadvalda ikki bir xil qator bo'lishi mumkin, `SELECT city FROM customers` dublikatlarni qaytaradi. Dublikatni olib tashlash uchun `DISTINCT` aniq yoziladi va u bepul emas (saralash yoki hash kerak).
- **Har amal natijasi yana jadval** (closure). Shuning uchun `SELECT` natijasini `FROM` ichida yana jadval sifatida ishlatish mumkin (subquery, CTE: 11 va 13-mavzular).

## 3. Muhit va asboblar

Barcha DB'lar docker compose'da. Bu darsda faqat PostgreSQL (va G guruhida qolganlari).

| Buyruq | Vazifasi |
|---|---|
| `make up db=postgres` | `ldb-postgres` konteynerini ishga tushirish |
| `make shell db=postgres` | konteyner ichida interaktiv `psql` |
| `make seed s=shop` | `sql/docs/schema/shop.sql` namuna sxemasini yuklash (qayta yuklash ham shu) |
| `make sql n=01` | `sql/01-sql-basics/main.sql` ni PostgreSQL'da ishga tushirish |
| `make sql n=01 db=sqlite` | `task_N.sqlite.sql` fayllarini SQLite'da ishga tushirish (G guruhi) |
| `make lint` | sqlfluff bilan tekshirish |
| `make reset db=postgres` | konteynerni va ma'lumotni noldan tiklash |
| `make down` | hamma konteynerlarni to'xtatish |

**psql meta-buyruqlari** (backslash bilan boshlanadi, SQL emas, faqat `psql` tushunadi):

| Buyruq | Nima qiladi |
|---|---|
| `\?`, `\h CREATE TABLE` | meta-buyruqlar yordami, SQL buyrug'i sintaksisi |
| `\l`, `\c dbname` | bazalar ro'yxati, ulanish |
| `\dn`, `\dt shop.*`, `\d shop.orders`, `\d+` | sxemalar, jadvallar, jadval tuzilishi (constraint va indekslar bilan) |
| `\df`, `\dv`, `\di`, `\du` | funksiyalar, view'lar, indekslar, rollar |
| `\x`, `\x auto` | keng natijani vertikal ko'rsatish |
| `\timing on` | har so'rov vaqti |
| `\i fayl.sql`, `\e` | faylni bajarish, oxirgi so'rovni muharrirda ochish |
| `\echo matn` | matn chop etish (vazifa sarlavhalari uchun) |
| `\set ON_ERROR_STOP on` | birinchi xatoda to'xtash (skriptlarda) |
| `\pset null '∅'` | NULL'ni ko'rinadigan qilish (bu darsda juda foydali) |
| `\q` | chiqish |

`search_path`: nomsiz jadval qaysi sxemada qidirilishi. `SET search_path = shop, public;` dan keyin `shop.orders` o'rniga `orders` yozish mumkin. `main.sql` ning boshida bir marta yozing.

**DBeaver** (yoki DataGrip, VS Code + SQLTools): GUI klient. ER diagramma, natijani jadval ko'rinishida ko'rish, plan vizualizatsiyasi uchun qulay. Ulanish: host `localhost`, port va parol `docker-compose.yml` va `.env` da. Lekin vazifalar fayl sifatida yoziladi va `make` bilan ishga tushadi: GUI faqat yordamchi.

## 4. DDL kirish: jadval yaratish

```sql
CREATE TABLE notes (
    note_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title      text        NOT NULL,
    body       text,
    priority   smallint    NOT NULL DEFAULT 3 CHECK (priority BETWEEN 1 AND 5),
    created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE notes ADD COLUMN archived boolean NOT NULL DEFAULT false;
ALTER TABLE notes RENAME COLUMN body TO content;
DROP TABLE IF EXISTS notes;
```

- `GENERATED ALWAYS AS IDENTITY` standart avtoinkrement (`serial` eski PostgreSQL uslubi, 23-mavzu).
- Constraint (`NOT NULL`, `CHECK`, `UNIQUE`, `PRIMARY KEY`, `REFERENCES`) DB darajasidagi qoida: ilova xato qilsa ham buzib bo'lmaydi. Batafsil 4-mavzuda.
- PostgreSQL'da DDL tranzaksiyaviy: `BEGIN; DROP TABLE x; ROLLBACK;` dan keyin jadval joyida. MySQL va Oracle'da DDL oldingi tranzaksiyani avtomatik commit qiladi va qaytarib bo'lmaydi. Bu migratsiyalar uchun katta farq.
- `DROP TABLE` qaytarib bo'lmaydi (backup bo'lmasa). `IF EXISTS` skriptni qayta ishga tushirishga chidamli (idempotent) qiladi.

## 5. DML kirish: INSERT, UPDATE, DELETE

```sql
INSERT INTO notes (title, priority) VALUES
    ('SQL o''rganish', 1),
    ('Go darsi', 2);

UPDATE notes SET priority = priority - 1 WHERE note_id = 2;
DELETE FROM notes WHERE archived;
```

- **Ustun ro'yxatini doim yozing.** `INSERT INTO notes VALUES (...)` jadvalga ustun qo'shilganda yoki tartib o'zgarganda jim buziladi.
- String literal bitta qo'shtirnoqda, ichidagi qo'shtirnoq ikkilanadi: `'O''tkan kunlar'`. Ikki qo'shtirnoq `"..."` string emas, identifikator (9-bo'lim).
- `UPDATE`/`DELETE` dan `WHERE` ni unutish eng qimmat xato. Odat: avval xuddi shu `WHERE` bilan `SELECT` yozib natijani ko'ring, keyin `BEGIN; UPDATE ...; SELECT ...; COMMIT/ROLLBACK;`.
- `DELETE FROM t` vs `TRUNCATE t`: `DELETE` qatorma-qator (trigger, WAL, sekin, `WHERE` bilan), `TRUNCATE` butun jadvalni bir zumda tozalaydi (PostgreSQL'da tranzaksiyaviy, MySQL/Oracle'da emas).
- `RETURNING` (PostgreSQL, SQLite, Oracle'da `RETURNING INTO`, SQL Server'da `OUTPUT`): o'zgargan qatorlarni darhol qaytaradi, keyingi `SELECT` kerak emas. Chuqur 21-mavzuda.

## 6. SELECT: yozilish tartibi va bajarilish tartibi

Yozilish tartibi:

```sql
SELECT DISTINCT c.city, count(*) AS n
FROM customers AS c
WHERE c.country = 'UZ'
GROUP BY c.city
HAVING count(*) > 1
ORDER BY n DESC
FETCH FIRST 3 ROWS ONLY;
```

Mantiqiy bajarilish tartibi (logical processing order): optimizer jismonan boshqacha qilishi mumkin, lekin **natija** shu tartibda bajarilgandek bo'lishi kafolatlanadi:

| # | Bosqich | Nima bo'ladi | Shu bosqichda nima ko'rinadi |
|---|---|---|---|
| 1 | `FROM` (+ `JOIN`) | manba jadval(lar), alias'lar `c` | jadval ustunlari |
| 2 | `WHERE` | qatorlarni filtrlash (faqat TRUE o'tadi) | ustunlar, `SELECT` alias'lari **yo'q** |
| 3 | `GROUP BY` | qatorlarni guruhlash | |
| 4 | `HAVING` | guruhlarni filtrlash | aggregatlar |
| 5 | `SELECT` | ifodalarni hisoblash, alias berish (`AS n`) | |
| 6 | `DISTINCT` | dublikatlarni olib tashlash | |
| 7 | `ORDER BY` | saralash | `SELECT` alias'lari **bor** |
| 8 | `OFFSET` / `FETCH` (`LIMIT`) | qatorlarni kesish | |

Shundan kelib chiqadigan qoidalar:
- `WHERE n > 1` ishlamaydi (`column "n" does not exist`): `WHERE` alias berilishidan oldin bajariladi. `ORDER BY n` esa ishlaydi.
- Aggregat (`count(*)`) `WHERE` da bo'lmaydi, `HAVING` da bo'ladi.
- PostgreSQL va MySQL `GROUP BY` da `SELECT` alias'ini qabul qiladi: bu standartdan chekinish, SQL Server va Oracle (23ai dan oldin) qabul qilmaydi. Portativ kod uchun ifodani takrorlang.
- `ORDER BY` siz `LIMIT` "tasodifiy" N qator beradi. `ORDER BY` bo'lsa ham, saralash kaliti unikal bo'lmasa (`ORDER BY price`) teng qiymatlilar orasida tartib kafolatlanmaydi: tie-breaker qo'shing (`ORDER BY price, product_id`).
- `FETCH FIRST 3 ROWS WITH TIES` 3-qator bilan teng qiymatlilarni ham qo'shadi (`ORDER BY` majburiy).

## 7. Asosiy tiplar

Batafsil 3-mavzuda. Hozircha kerakli minimum:

| Toifa | PostgreSQL | Izoh |
|---|---|---|
| Butun son | `smallint` (2 B), `integer` (4 B), `bigint` (8 B) | overflow xato beradi, jim aylanmaydi |
| Aniq o'nlik | `numeric(p, s)` | pul, miqdor: **faqat shu** |
| Taqribiy | `real`, `double precision` | IEEE 754: `0.1 + 0.2 <> 0.3` |
| Matn | `text`, `varchar(n)`, `char(n)` | PostgreSQL'da `text` va `varchar` bir xil tez; `char(n)` bo'shliq bilan to'ldiradi |
| Mantiqiy | `boolean` | `true`/`false`/NULL |
| Sana-vaqt | `date`, `timestamp`, `timestamptz`, `interval` | deyarli doim `timestamptz` (19-mavzu) |
| Boshqa | `uuid`, `bytea`, `jsonb` | keyingi darslarda |

Tip bilan bog'liq hayratlar:
- `5 / 2 = 2`: ikki butun son bo'linmasi butun, kasr qismi **kesiladi** (`-7 / 2 = -3`, Python'dagi `-7 // 2 == -4` dan farqli). `5 / 2.0 = 2.5`, yoki `5::numeric / 2`.
- `'Salom'::varchar(3)` explicit cast'da jim `'Sal'` ga qisqaradi, `INSERT` da esa `value too long` xatosi. Standart shunday talab qiladi.
- `char(5)` da `'abc'` aslida `'abc  '` saqlanadi, solishtirish va `||` da oxirgi bo'shliqlar e'tiborsiz. Deyarli hech qachon kerak emas.
- `CAST(x AS type)` standart, `x::type` PostgreSQL qisqartmasi.

## 8. NULL va uch qiymatli mantiq (3VL)

NULL qiymat emas, "qiymat noma'lum yoki yo'q" belgisi. Shuning uchun NULL bilan har qanday solishtirish natijasi TRUE ham, FALSE ham emas, balki **UNKNOWN** (SQL'da boolean NULL).

| `a` | `b` | `a AND b` | `a OR b` | `NOT a` |
|---|---|---|---|---|
| TRUE | UNKNOWN | UNKNOWN | TRUE | FALSE |
| FALSE | UNKNOWN | FALSE | UNKNOWN | TRUE |
| UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |

Asosiy qoidalar:
- `x = NULL` hech qachon TRUE emas, hatto `NULL = NULL` ham UNKNOWN. To'g'ri: `x IS NULL`, `x IS NOT NULL`.
- `WHERE` faqat **TRUE** bo'lgan qatorni o'tkazadi; UNKNOWN ham FALSE ham tashlanadi. Shuning uchun `WHERE city <> 'Toshkent'` shahri NULL bo'lgan mijozni **qaytarmaydi**. NULL'larni ham olish uchun: `WHERE city IS DISTINCT FROM 'Toshkent'` (NULL'ni oddiy qiymat kabi solishtiradi).
- `CHECK` constraint esa aksincha: UNKNOWN ni **o'tkazadi**. `CHECK (discount_pct BETWEEN 0 AND 100)` NULL'ga ruxsat beradi.
- `NOT IN` tuzog'i: `x NOT IN (1, 2, NULL)` = `x <> 1 AND x <> 2 AND x <> NULL` = `... AND UNKNOWN` = hech qachon TRUE emas. Subquery bitta NULL qaytarsa butun natija bo'sh. Yechim: `NOT EXISTS` (11-mavzu).
- Aggregatlar NULL'ni o'tkazib yuboradi: `count(*)` qatorlarni, `count(email)` NULL bo'lmagan email'larni sanaydi. `avg(discount_pct)` NULL'larni hisobga olmaydi (0 deb emas).
- Arifmetika va `||`: `5 + NULL` = NULL, `'x' || NULL` = NULL (Oracle'da `'x'`, chunki u yerda `''` va NULL bir narsa). `concat('x', NULL)` = `'x'`.
- `COALESCE(a, b, c)`: birinchi NULL bo'lmagan qiymat. `NULLIF(a, b)`: `a = b` bo'lsa NULL, aks holda `a` (masalan nolga bo'lishdan himoya: `x / NULLIF(y, 0)`).
- NULL va 0, NULL va `''` bir narsa emas: `discount_pct = 0` "chegirma yo'q, bu aniq", `discount_pct IS NULL` "chegirma haqida ma'lumot yo'q". Ma'nosini sxema dizaynida aniq belgilang.

## 9. Identifikatorlar, registr va kommentlar

- Kalit so'zlar registrsiz: `select` = `SELECT`. Bu loyihada kalit so'zlar KATTA, identifikatorlar kichik (`snake_case`): sqlfluff shunday tekshiradi.
- Qo'shtirnoqsiz identifikator PostgreSQL'da **kichik harfga** aylantiriladi: `CREATE TABLE Orders` aslida `orders` yaratadi. Qo'shtirnoqli `"Orders"` esa aynan shu registrda saqlanadi va keyin doim `"Orders"` deb yozishga majbur qiladi. Qoida: identifikatorni hech qachon qo'shtirnoqqa olmang, faqat kichik harf va `_`.
- Oracle aksincha katta harfga aylantiradi (`orders` → `ORDERS`), shuning uchun Oracle katalogida jadval nomlari katta harfda ko'rinadi.
- Kommentlar: `-- bir qator` va `/* ko'p qator */` (standart). MySQL'da `--` dan keyin bo'shliq majburiy, `#` ham ishlaydi.
- Har buyruq `;` bilan tugaydi. SQL Server'da ixtiyoriy (lekin CTE va `MERGE` oldidan kerak), qolganlarida skriptda majburiy.

## 10. Uslub va sqlfluff

sqlfluff SQL uchun linter va formatter (`ruff`/`gofmt` analogi). Sozlamasi ildizdagi `.sqlfluff` da, dialekt fayl nomi bo'yicha tanlanadi (`*.sql` → postgres, `*.mysql.sql` → mysql, ...).

```
make lint                          barcha SQL fayllarni tekshirish
sqlfluff lint sql/01-sql-basics    bitta papka
sqlfluff fix sql/01-sql-basics     avtomatik tuzatish (keyin diff'ni ko'ring)
```

Asosiy qoida guruhlari: `LT` (layout: indentatsiya, bo'shliq, qator uzunligi), `CP` (capitalisation: kalit so'z va identifikator registri), `AL` (aliasing: `AS` majburiy, aniq alias), `AM` (ambiguous: `SELECT *` bilan `UNION`, `ORDER BY` ustun raqami), `RF` (references: qaysi jadval ustuni ekani aniq), `ST` (structure: keraksiz `CASE`, `ELSE NULL`). Xato kodi (masalan `CP01`) kommentda yozilsa, keyin tez topasiz.

## Tuzoqlar

- `ORDER BY` siz natija tartibi kafolatlanmaydi, `LIMIT` bilan ham.
- `WHERE` da `SELECT` alias'i ko'rinmaydi; `ORDER BY` da ko'rinadi.
- `5 / 2 = 2`, `-7 / 2 = -3`: butun bo'linma kesiladi.
- `0.1::float8 + 0.2 <> 0.3`: pul va miqdor uchun faqat `numeric`.
- `x = NULL` doim UNKNOWN; `WHERE col <> 'a'` NULL qatorlarni tashlab yuboradi.
- `NOT IN (subquery)` subquery'da bitta NULL bo'lsa bo'sh natija beradi.
- `count(col)` NULL'larni sanamaydi; `count(*)` sanaydi.
- `CHECK` UNKNOWN'ni o'tkazadi: `CHECK (x > 0)` NULL'ga ruxsat beradi, `NOT NULL` alohida kerak.
- `'...'` string, `"..."` identifikator. `WHERE name = "Aziz"` PostgreSQL'da `column "Aziz" does not exist`.
- `CREATE TABLE Orders` PostgreSQL'da `orders`, Oracle'da `ORDERS` yaratadi.
- Oracle'da `''` NULL: `WHERE note = ''` hech narsa topmaydi.
- MySQL va Oracle'da DDL implicit commit qiladi: oldingi tugallanmagan tranzaksiya ham commit bo'lib ketadi.
- `UPDATE`/`DELETE` dan `WHERE` unutilsa butun jadval o'zgaradi.

## Manbalar

- https://www.postgresql.org/docs/current/tutorial-sql.html (rasmiy tutorial, 2-bob: SQL tili; majburiy)
- https://www.postgresql.org/docs/current/sql-syntax.html (leksik tuzilish, identifikator, konstanta, operator ustunligi)
- https://www.postgresql.org/docs/current/app-psql.html (psql to'liq ma'lumotnoma, meta-buyruqlar)
- https://www.postgresql.org/docs/current/datatype.html (tiplar bo'limi, 8.1 Numeric va 8.3 Character qismlari)
- https://www.postgresql.org/docs/current/functions-comparison.html (`IS DISTINCT FROM`, `IS NULL`)
- https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql#logical-processing-order-of-the-select-statement (logical processing order, rasmiy jadval)
- https://modern-sql.com (standart xususiyatlar va DB qo'llab-quvvatlash jadvallari), https://modern-sql.com/concept/three-valued-logic (3VL)
- Codd, "A Relational Model of Data for Large Shared Data Banks" (CACM, 1970), https://www.seas.upenn.edu/~zives/03f/cis550/codd.pdf
- Chamberlin, "Early History of SQL" (IEEE Annals of the History of Computing, 2012)
- https://docs.sqlfluff.com/en/stable/rules.html (sqlfluff qoidalari)
- Beaulieu, "Learning SQL" (3-nashr), 1–3 boblar

---

## Vazifalar

Barchasini `../01-sql-basics/main.sql` da yozing (G guruhidagi dialekt vazifalari alohida `task_N.<db>.sql` fayllarda). Ishga tushirish: `make up db=postgres`, `make seed s=shop`, keyin `make sql n=01`. Faylning boshida:

```sql
\set ON_ERROR_STOP on
\pset null '∅'
SET search_path = shop, public;
```

Har vazifa oldidan `\echo '== N. Title'` bilan sarlavha chop eting. Har vazifada so'ralgan tushuntirish, bashorat va xato matnlarini SQL kommentida (`--`) yozing: bu sizning tushunganingizni tekshirish uchun. Ataylab xato beradigan buyruqlarni xatoni ko'rib, matnini kommentga yozgach o'chiring yoki kommentga oling: tayyor `main.sql` boshidan oxirigacha xatosiz ishlashi kerak. O'z jadvallaringizni `shop` sxemasida emas, `lab` sxemasida yarating (`CREATE SCHEMA IF NOT EXISTS lab;`), skript qayta ishga tushirilganda buzilmasligi uchun `DROP ... IF EXISTS` dan foydalaning. Bashorat so'ralgan joyda avval kommentga bashoratni yozing, keyin so'rovni ishga tushiring va natija bilan solishtiring.

### A. Muhit va katalog

1. **Version and client.** `SELECT version();`, `SHOW server_version;`, `SELECT current_database(), current_user, current_schema();` ni chop eting. `psql --version` ni terminalda ishga tushirib klient versiyasini kommentga yozing. Server va klient versiyasi farq qilishi mumkinmi va nimaga ta'sir qiladi? Kommentda PostgreSQL versiyalash siyosatini (major versiya har yili, 5 yil qo'llab-quvvatlash) bir gapda yozing.

2. **psql meta-commands.** `make shell db=postgres` da quyidagilarni interaktiv bajaring va har birining natijasini bir gapda kommentga yozing: `\l`, `\dn`, `\dt shop.*`, `\d shop.orders`, `\d+ shop.order_items`, `\du`, `\timing on` keyin istalgan so'rov, `\x` keyin `SELECT * FROM shop.customers LIMIT 1;`. `\d shop.orders` chiqishidagi "Check constraints" va "Foreign-key constraints" bo'limlarini o'qib, `orders` jadvalidagi barcha qoidalarni o'z so'zingiz bilan kommentga yozing. Meta-buyruq va SQL buyrug'i farqini (kim bajaradi: klient yoki server) izohlang.

3. **Load the shop schema.** `make seed s=shop` ni ikki marta ketma-ket ishga tushiring va ikkinchisi ham xatosiz o'tganini tasdiqlang. `sql/docs/schema/shop.sql` faylini o'qib, uni idempotent qilayotgan qatorni topib kommentga yozing. Fayl oxiridagi `setval(...)` qatorlari nima uchun kerakligini taxmin qiling (23-mavzuda tasdiqlanadi). `main.sql` da har jadvaldagi qatorlar sonini bitta so'rovda chop eting (`SELECT (SELECT count(*) FROM customers) AS customers, ...`).

4. **Catalog exploration.** `information_schema.columns` dan `shop.products` ning barcha ustunlarini `ordinal_position` tartibida `column_name`, `data_type`, `is_nullable`, `column_default` bilan chop eting. Xuddi shu ma'lumotni `\d shop.products` bilan solishtiring. `information_schema.table_constraints` dan `shop` sxemasidagi barcha constraintlarni turi bilan chop eting. `information_schema` standart, `pg_catalog` esa PostgreSQL'ga xos: qaysi birini qachon ishlatishni kommentda izohlang (portativlik vs to'liqlik).

### B. DDL

5. **First table.** `lab.books` jadvalini yarating: `book_id` (identity, PK), `isbn` (13 belgi, unikal, majburiy), `title` (majburiy), `author`, `published_year` (`smallint`, 1450 dan joriy yilgacha `CHECK`), `price` (`numeric(10, 2)`, manfiy emas), `in_stock` (`boolean`, default `true`), `created_at` (`timestamptz`, default `now()`). Constraintlarga nom bering (`CONSTRAINT books_price_chk CHECK (...)`). `\d lab.books` chiqishini kommentga ko'chiring. Har tip tanloviga bir qatorlik izoh yozing (nega `numeric`, nega `smallint`, nega `char(13)` emas `text` + `CHECK (length(isbn) = 13)`).

6. **Constraints violated.** `lab.books` ga har bir constraint'ni buzadigan bittadan `INSERT` yozing: `NULL` title, takror `isbn`, manfiy `price`, 1400-yil. Har birining xato matnini va SQLSTATE kodini (`\set VERBOSITY verbose` bilan ko'rinadi: `23502`, `23505`, `23514`) kommentga yozing, so'ng buyruqni o'chiring. Nomlangan constraint xato matnini qanday tushunarliroq qilganini izohlang. Keyin `price` NULL bo'lgan qatorni kiriting: nima uchun `CHECK (price >= 0)` uni o'tkazib yubordi? (8-bo'lim.)

7. **ALTER TABLE.** `lab.books` ga `pages integer` ustunini qo'shing, `author` ni `author_name` ga o'zgartiring, `in_stock` default'ini `false` ga o'zgartiring, `pages > 0` `CHECK` ini qo'shing, keyin `pages` ni o'chiring. Har qadamdan keyin `\d` ni ko'rish shart emas, lekin oxirgi holatni kommentga yozing. `NOT NULL` ustunni allaqachon qatorlari bor jadvalga default'siz qo'shib ko'ring: xato matnini yozing va default bilan qanday hal bo'lishini ko'rsating.

8. **Drop and idempotency.** `main.sql` ni ketma-ket ikki marta ishga tushiring: ikkinchi marta xato bermasligi uchun nima qilish kerakligini (`DROP TABLE IF EXISTS`, `CREATE SCHEMA IF NOT EXISTS`) qo'llang. `DROP TABLE shop.customers;` ni `BEGIN; ... ROLLBACK;` ichida sinab ko'ring: xato matnini kommentga yozing (nega o'chmadi?). `DROP ... CASCADE` nima qilishini va nima uchun xavfli ekanini izohlang (bajarmang!).

9. **DDL in a transaction.** `BEGIN; CREATE TABLE lab.tmp_x (id int); INSERT INTO lab.tmp_x VALUES (1); ROLLBACK;` dan keyin `lab.tmp_x` mavjudligini tekshiring (`to_regclass('lab.tmp_x')`). Natijani izohlang. MySQL va Oracle'da xuddi shu ketma-ketlik qanday tugashini (implicit commit) va bu migratsiya yozishga qanday ta'sir qilishini 2–3 gapda kommentga yozing.

### C. DML

10. **Multi-row insert.** `lab.books` ga bitta `INSERT` bilan 5 ta kitob kiriting (kamida bittasining nomida apostrof bo'lsin: `'O''tkan kunlar'`). Ustun ro'yxatini yozing, `book_id` va `created_at` ni bermang. Keyin ustun ro'yxatisiz `INSERT INTO lab.books VALUES (...)` yozib ko'ring: qanday xato chiqdi yoki qanday noto'g'ri ishladi? Nega ustun ro'yxati majburiy odat ekanini izohlang.

11. **Safe UPDATE.** Barcha 2000-yildan oldingi kitoblar narxini 10% ga kamaytiring. Avval xuddi shu `WHERE` bilan `SELECT` yozing (nechta qator o'zgarishini bashorat qilish uchun), keyin `BEGIN; UPDATE ...; SELECT ...; COMMIT;`. `psql` chiqaradigan `UPDATE n` dagi `n` ni kommentga yozing. Narx `numeric(10, 2)` da `* 0.9` dan keyin qanday yaxlitlanganini ko'rsating. `WHERE` siz `UPDATE` ni `BEGIN ... ROLLBACK` ichida bajarib, nechta qator o'zgarganini yozing.

12. **DELETE vs TRUNCATE.** `lab.books` dan bitta qatorni `DELETE` bilan o'chiring, keyin yangi qator kiritib `book_id` ni ko'ring: o'chirilgan ID qayta ishlatildimi? Keyin `TRUNCATE lab.books RESTART IDENTITY;` va yana kiriting. `DELETE FROM t` bilan `TRUNCATE t` ning beshta farqini (tezlik, `WHERE`, trigger, identity, tranzaksiyaviylik vendorlarda) kommentda jadval qilib yozing.

13. **RETURNING preview.** `INSERT ... RETURNING book_id, created_at`, `UPDATE ... RETURNING book_id, price` va `DELETE ... RETURNING *` ni yozing. `RETURNING` siz qanday qilib yangi `book_id` ni olish kerak bo'lardi va nega u race condition'ga moyil (`SELECT max(book_id)`)? Kommentda izohlang.

### D. SELECT va logical order

14. **Projection and alias.** `shop.products` dan `sku`, `name`, `price`, `price * 12000 AS price_uzs` (taxminiy kurs), `price * stock AS stock_value` ni chop eting. Alias'ni `AS` bilan va `AS` siz yozib ko'ring (ikkalasi ishlaydi), sqlfluff qaysi birini talab qilishini (`AL02`) kommentga yozing. Alias'da bo'shliq kerak bo'lsa nima qilinadi va nima uchun bunga yo'l qo'ymaslik kerak?

15. **Logical order proof.** `SELECT price * stock AS stock_value FROM shop.products WHERE stock_value > 1000;` ni ishga tushiring, xato matnini kommentga yozing va 6-bo'lim jadvali bilan izohlang. Xuddi shu filtrni ikki to'g'ri usulda yozing: ifodani `WHERE` da takrorlab va subquery (`FROM (SELECT ...) AS t WHERE t.stock_value > 1000`) bilan. Keyin `ORDER BY stock_value DESC` alias bilan ishlashini ko'rsating. Bajarilish tartibini (8 bosqich) kommentga o'z so'zingiz bilan yozing.

16. **Bag, not set.** `SELECT city FROM shop.customers;` va `SELECT DISTINCT city FROM shop.customers;` qatorlar sonini bashorat qiling, keyin tekshiring. `DISTINCT` natijasida NULL nechta marta chiqdi va nima uchun (DISTINCT uchun NULL'lar "teng")? `count(*)`, `count(city)`, `count(DISTINCT city)` ni bitta so'rovda chop eting va uchala sonning farqini izohlang. `DISTINCT` ning narxi (saralash yoki hash) haqida bir gap yozing.

17. **ORDER BY determinism.** Mahsulotlarni `price` bo'yicha kamayish tartibida chop eting. `stock = 0` bo'lgan mahsulotlarni `ORDER BY stock` bilan chop eting: teng qiymatlilar orasida tartib kafolatlanganmi? Tie-breaker (`product_id`) qo'shing. `ORDER BY 3` (ustun raqami) ishlashini ko'rsating va nega yomon uslub ekanini (`AM06`) yozing. `NULLS FIRST`/`NULLS LAST` bilan `customers` ni `birth_date` bo'yicha saralang; PostgreSQL'da `ASC` da NULL default qayerda turadi?

18. **LIMIT and FETCH FIRST.** Eng qimmat 3 mahsulotni `LIMIT 3` va standart `FETCH FIRST 3 ROWS ONLY` bilan chop eting. Ombordagi qoldig'i (`stock`) eng kam mahsulotni `ORDER BY stock FETCH FIRST 1 ROW ONLY` bilan, keyin `FETCH FIRST 1 ROW WITH TIES` bilan chop eting (har birida nechta qator chiqdi va nega?). `OFFSET 5 LIMIT 5` bilan "2-sahifa" ni chop eting. `ORDER BY` siz `LIMIT` nima uchun xato ekanini va offset pagination katta sahifalarda nega sekinlashishini bir gapda yozing (29-mavzuda chuqur).

### E. Tiplar

19. **Integer division.** `5 / 2`, `5 / 2.0`, `5::numeric / 2`, `-7 / 2`, `-7 % 2`, `7 / 0` (xatoni ushlamay, matnini kommentga yozing va o'chiring) natijalarini bashorat qiling va tekshiring. Python (`-7 // 2`, `-7 % 2`) va Go (`-7 / 2`, `-7 % 2`) natijalari bilan solishtirib kommentda jadval qiling. `order_items` dagi o'rtacha mahsulot soni (`avg(quantity)`) va `sum(quantity) / count(*)` ni chop eting: nega farqli?

20. **Money is numeric.** `0.1::float8 + 0.2::float8 = 0.3::float8` va `0.1::numeric + 0.2 = 0.3` ni chop eting. `SELECT sum(0.1::float8) FROM generate_series(1, 10);` va xuddi shuni `numeric` bilan chop eting. `shop.order_items` da har buyurtma summasini (`sum(quantity * unit_price)`) hisoblab, natija tipini `pg_typeof(...)` bilan ko'rsating. Nega pul uchun `float`, `real`, `money` tiplari ishlatilmasligini izohlang (`money` ning lokalga bog'liqligi).

21. **Character types.** `'abc'::char(5) || 'x'`, `length('abc'::char(5))`, `octet_length('abc'::char(5))`, `'Salom'::varchar(3)` va `octet_length('Дунё')`, `length('Дунё')` ni chop eting. `lab` da `varchar(3)` ustunli jadvalga `'Salom'` kiritib xatoni kommentga yozing: nega cast'da qisqardi, `INSERT` da esa xato? PostgreSQL'da nega `text` va `varchar` unumdorlikda farq qilmasligini va `varchar(n)` qachon baribir foydali ekanini (biznes qoidasi sifatida) izohlang.

22. **Timestamps first look.** `SELECT now(), current_timestamp, localtimestamp, current_date, now()::date, pg_typeof(now());` ni chop eting. `SHOW timezone;` ni yozing, keyin `SET timezone = 'UTC';` va `shop.orders` ning birinchi 3 ta `ordered_at` ini chop eting, so'ng `'Asia/Tashkent'` da qayta chop eting. Qiymat o'zgardimi yoki faqat ko'rinish? `BEGIN; SELECT now(); SELECT pg_sleep(1); SELECT now(), clock_timestamp(); COMMIT;` natijasini izohlang. (Chuqur: 19-mavzu.)

### F. NULL va 3VL

23. **Equals NULL.** Email'i yo'q mijozlarni `WHERE email = NULL` bilan va `WHERE email IS NULL` bilan sanang. Natijalarni bashorat qiling va izohlang. `SELECT NULL = NULL, NULL <> NULL, NULL IS NULL, NULL IS DISTINCT FROM NULL;` ni chop eting. `\pset null` qilinmaganda natijada NULL qanday ko'rinadi va nega `\pset null '∅'` foydali?

24. **Truth tables.** Bitta so'rovda (`VALUES` va `CROSS JOIN` bilan, yoki qo'lda) `a`, `b` ∈ {`true`, `false`, `NULL`} ning barcha 9 kombinatsiyasi uchun `a AND b`, `a OR b`, `NOT a` jadvalini chop eting. Natijani 8-bo'lim jadvali bilan solishtiring. `WHERE` faqat TRUE ni o'tkazishini `SELECT 1 WHERE NULL;` va `SELECT 1 WHERE NOT NULL;` bilan ko'rsating.

25. **NULL in filters.** Shahri Toshkent bo'lmagan mijozlarni `city <> 'Toshkent'` bilan sanang, keyin `city IS DISTINCT FROM 'Toshkent'` bilan. Farq nechta qator va qaysi mijoz? `discount_pct` haqida: chegirma berilmagan (`= 0`), ma'lumot yo'q (`IS NULL`) va chegirma bor (`> 0`) buyurtmalar sonini bitta so'rovda chop eting (`count(*) FILTER (WHERE ...)` yoki `sum(CASE ...)`). NULL va 0 farqini bu jadval ma'nosida izohlang.

26. **NOT IN trap.** Birorta ham buyurtma bermagan mijozlarni `customer_id NOT IN (SELECT customer_id FROM orders)` bilan toping (nechta?). Endi subquery'ga ataylab NULL qo'shing: `NOT IN (SELECT customer_id FROM orders UNION ALL SELECT NULL)`. Natija nechta va nima uchun? 3VL bilan qadamma-qadam isbotlang (`x <> a AND x <> b AND x <> NULL`). Xuddi shu so'rovni `NOT EXISTS` bilan yozing va NULL qo'shilganda ham to'g'ri ishlashini ko'rsating.

27. **Aggregates and NULL.** `shop.orders` uchun `count(*)`, `count(discount_pct)`, `avg(discount_pct)`, `avg(COALESCE(discount_pct, 0))`, `sum(discount_pct)`, `max(shipped_at)` ni chop eting. Ikki `avg` nega farqli va biznes nuqtai nazaridan qaysi biri to'g'ri? `SELECT sum(x) FROM (SELECT 1 AS x WHERE false) AS t;` ni chop eting: bo'sh to'plamda `sum` nima qaytaradi va `count` nima qaytaradi?

28. **COALESCE and NULLIF.** Mijozlar ro'yxatini `COALESCE(email, phone, '(aloqa yo''q)') AS contact` bilan chop eting. `'x' || NULL`, `concat('x', NULL)`, `5 + NULL` ni chop eting. Har buyurtma uchun "jo'natishgacha soat" ni hisoblang, jo'natilmaganlar uchun NULL qolsin. `NULLIF` bilan nolga bo'lishdan himoya qiling: har mahsulot uchun `price / NULLIF(stock, 0)` ni chop eting. `COALESCE` argumentlari tipi har xil bo'lsa (`COALESCE(birth_date, 'yo''q')`) nima bo'ladi va qanday tuzatiladi?

### G. Dialektlar va uslub

29. **Same query, other databases.** Quyidagi so'rovni yozing: "Eng qimmat 3 mahsulot: nomi, narxi va `name || ' (' || sku || ')'` ko'rinishidagi label". Uni `task_29.sqlite.sql`, `task_29.mysql.sql`, `task_29.mssql.sql`, `task_29.oracle.sql` fayllarida har dialektga moslab yozing (avval kerakli jadvalni o'sha DB'da `CREATE TABLE` + 5 qator `INSERT` bilan yarating), har birini `make sql n=01 db=<db>` bilan ishga tushiring. Har faylda kommentga farqlarni yozing: pagination (`LIMIT`/`TOP`/`FETCH FIRST`), string birlashtirish (`||`/`CONCAT`/`+`), versiyani olish, identifikator registri (Oracle katalogida jadval nomi qanday ko'rinadi: `SELECT table_name FROM user_tables;`).

30. **Empty string and integer division across dialects.** To'rt DB'da (`task_30.<db>.sql`, PostgreSQL esa `main.sql` da): `SELECT 5 / 2`, `''` NULL'mi (`CASE WHEN '' IS NULL THEN 'null' ELSE 'not null' END`), `'x' || NULL` (yoki dialekt ekvivalenti) natijalarini chop eting. Natijalarni `main.sql` da kommentda jadval qilib yozing. Oracle'dagi `''` = NULL xulqi ilovani boshqa DB'dan Oracle'ga ko'chirishda qanday xatolarga olib kelishini 2–3 gapda izohlang.

31. **sqlfluff.** `main.sql` ga ataylab yomon formatlangan so'rov qo'shing (kichik harfli kalit so'zlar, alias'siz ifoda, `SELECT *`, uzun qator, aralash indentatsiya). `make lint` chiqishidagi qoida kodlarini (`CP01`, `AL03`, `AM04`, `LT05` va boshqalar) kommentga yozing va har birini bir gapda izohlang. `sqlfluff fix` bilan tuzating, diff'ni ko'ring, keyin qolgan xatolarni qo'lda tuzating. Oxirida `make lint` toza bo'lsin.

### Topshirish

Tayyor bo'lgach:
1. `make lint` toza.
2. `make seed s=shop` dan keyin `make sql n=01` boshidan oxirigacha xatosiz ishlaydi va barcha 31 vazifa sarlavhasini chop etadi; ikkinchi marta ishga tushirilganda ham xatosiz (idempotent).
3. G guruhidagi fayllar tegishli DB'da (`make sql n=01 db=sqlite|mysql|mssql|oracle`) xatosiz ishlaydi.
4. Menga xabar bering, kodingizni o'qib chiqaman va har vazifa bo'yicha fikr beraman.

### O'zini tekshirish savollari (kodsiz, o'z so'zingiz bilan javob bering)

- SQL standarti va dialekt nima? Nima uchun "SQL bilaman" degan gap to'liq emas?
- SQL nima uchun bag bilan ishlaydi va bu `SELECT city FROM customers` natijasiga qanday ta'sir qiladi?
- SELECT'ning mantiqiy bajarilish tartibi qanday? `WHERE` da alias nega ishlamaydi, `ORDER BY` da nega ishlaydi?
- `ORDER BY` siz natija tartibi nima uchun kafolatlanmaydi? Tie-breaker nima?
- `5 / 2` PostgreSQL'da, MySQL'da va Oracle'da nima beradi?
- Pul uchun nega `numeric`? `0.1 + 0.2` float'da nima uchun `0.3` emas?
- `NULL = NULL` nima qaytaradi? `WHERE` va `CHECK` UNKNOWN bilan qanday farqli ishlaydi?
- `NOT IN` subquery'da bitta NULL bo'lsa nima bo'ladi va nega? To'g'ri yechim qaysi?
- `count(*)`, `count(col)`, `count(DISTINCT col)` farqi nima?
- PostgreSQL'da DDL tranzaksiyaviy bo'lishi migratsiya yozishda qanday afzallik beradi? MySQL va Oracle'da-chi?
- `CREATE TABLE Orders` PostgreSQL'da va Oracle'da qanday nom bilan yaratiladi? Qo'shtirnoqli identifikator nima uchun yomon odat?
- Oracle'da `''` NULL bo'lishi qanday xatolarga olib keladi?
