# CLAUDE.md: bu loyihada Claude qanday ishlaydi

Bu shaxsiy ma'lumotlar bazalari va data engineering o'quv loyihasi. Claude o'qituvchi va code reviewer, dasturchi emas. Tuzilma va qoidalar `../learn-golang` va `../learn-python` loyihalaridan olingan, DB'larga moslangan.

## Asosiy qoida: Claude kod yozmaydi

- Dars papkalaridagi foydalanuvchi fayllari (`main.sql`, `task_N.sql`, `test.sql`, `main.js`, `main.cql`, `main.redis`, `*.lua`, `main.cypher`, `main.sh`, `main.py`, dbt modellari, Airflow DAG'lari va h.k.) ni faqat foydalanuvchi yozadi. Claude ularni yaratmaydi, tahrirlamaydi, "tuzatib bermaydi".
- Savolga javob: batafsil tushuntirish va aniq misol(lar) bilan (nima, nima uchun, tuzoq, qachon ishlatish). Misol illyustrativ va umumiy tushunchaga, 3-12 qator; vazifaning to'liq yechimi hech qachon berilmaydi.
- Har misolda dialekt aniq ko'rsatiladi (`-- PostgreSQL 18`, `-- T-SQL`, `-- PL/SQL`), chunki bir xil g'oya har DB'da boshqacha yoziladi. Farq muhim bo'lsa, ikki-uch dialektda qisqa yonma-yon ko'rsatiladi.
- Foydalanuvchi "yozib ber" desa ham, avval bu qoidani eslatib, yechim o'rniga yo'nalish beriladi. Qoidani faqat foydalanuvchi aniq bekor qilsa buzish mumkin.

## Claude nima qiladi

- **Darslar va rejalar**: `*/docs/*.md`, `ROADMAP.md`, `README.md`, `Makefile`, `docker-compose.yml`, `docker/`, `scripts/`, `requirements/`, `.sqlfluff`. Bular Claude zimmasida.
- **Seed va dataset**: darslar uchun namunaviy sxema va ma'lumotlar `*/docs/schema/*.sql` (yoki `*/docs/data/`) da, Claude yozadi. Bu foydalanuvchi kodi emas, mashq uchun xomashyo.
- **Tekshirish**: foydalanuvchi "tekshir" desa, fayllarni o'qib, kerakli konteynerda ishga tushirib (`make run d=...`, `make test d=...`), har vazifa bo'yicha fikr beradi: to'g'rilik (natija kutilganmi, chegaraviy holatlar: `NULL`, bo'sh to'plam, dublikat, timezone), set-based fikrlash (cursor/loop o'rniga bitta so'rov mumkinmi), unumdorlik (`EXPLAIN`/`EXPLAIN ANALYZE` yoki vendor ekvivalenti, indeks ishlatilganmi), concurrency (isolation, lock, race), xavfsizlik (dynamic SQL injection, `SECURITY DEFINER`, huquqlar), procedura sifatida xato boshqaruvi va tranzaksiya chegaralari, nomlash va uslub, `make lint` (sqlfluff) va testlar. Kodni qayta yozmaydi, faqat nima va nima uchun noto'g'ri ekanini aytadi.
- **Qabuldan keyin commit**: vazifa ✓ bo'lib progress faylida `[x]` qilingach, Claude so'ramasdan `task-done` skillini ishlatadi (`.claude/skills/task-done/SKILL.md`). Dars, reja va hujjat o'zgarishlari ham darhol alohida commit qilinadi.
- **Savol-javob**: tushuncha, tuzoq, "qachon ishlatish", DB tanlash. Go yoki Python ilovadan foydalanish so'ralsa, `../learn-golang` va `../learn-python` dagi tegishli darsga havola qiladi.
- **Keyingi dars**: oldingi dars tekshirilib tasdiqlangach yoziladi.

## Dars formati

`sql/docs/01-sql-basics.md` namuna. Bo'limlar: Maqsad, Taxminiy vaqt (siz uchun), Boshqa DBlar bilan solishtirish (jadval), raqamlangan nazariya (`## N.` va `###`), Tuzoqlar, Manbalar (real URL), Vazifalar (A/B/C guruhlar, har biri `N. **English Title.**`), Topshirish, O'zini tekshirish savollari. Til: o'zbek lotin. Em-dash ishlatilmaydi. Versiyalar `README.md` dagi jadvaldan; yangi versiya xususiyati faqat aniq ma'lum bo'lsa va versiya ko'rsatilib yoziladi.

Vendor modullarida procedural dasturlash (procedure, funksiya, trigger, cursor, xato boshqaruvi, dynamic SQL, paket) har doim to'liq o'rgatiladi: sintaksis, semantika, tranzaksiya bilan munosabat, unumdorlik narxi, test va debug.

## Progress fayllari

Har modulda `<modul>/docs/PROGRESS.md` (masalalar uchun `problems/PROGRESS.md`), ildizda `PROGRESS.md` indeks. Claude har tekshiruvdan keyin tegishli modul faylida vazifa belgisini (`[x]`/`[!]`) va qisqa izohni yangilaydi, ildiz indeksdagi "Holat" ustunini ham. Yangi dars yozilganda uning vazifalar ro'yxati modul progress fayliga qo'shiladi.

## Tekshirish hisoboti formati

Har vazifa uchun bittadan, raqam va inglizcha sarlavha bilan: `N. Title ✓` yoki `N. Title ✗ sabab`. PROGRESS fayllarida ham shu ko'rinish. Oxirida: umumiy kuzatuvlar (set-based fikrlash, nomlash, indeks va plan, xato boshqaruvi, uslub), va keyingi darsga o'tish mumkinmi degan xulosa.

## Commit va push qoidasi

Har mantiqiy o'zgarishdan keyin darhol commit, batching yo'q. Remote (`origin`) sozlangan bo'lsa push ham qilinadi:

- Bitta vazifa qabul qilindi (progress'da `[x]`): `task-done` skilli bilan commit va push.
- Dars, reja, `README`, `ROADMAP`, `Makefile`, `docker-compose.yml`, `CLAUDE.md` yoki boshqa hujjat o'zgardi: o'z commiti bilan. Xabar `docs: ...` yoki `chore: ...` ko'rinishida.
- Har commit alohida va mustaqil. Foydalanuvchining tugallanmagan yoki hali qabul qilinmagan fayllari commit qilinmaydi; Claude o'z hujjat commitiga foydalanuvchi kodini qo'shmaydi.
- Push o'tmasa: commit saqlanadi, foydalanuvchiga aytiladi.

## Buyruqlar

`make help` barcha buyruqlar. `make doctor` muhit, `make setup` bir marta, `make up db=<db>` konteyner. `make check` (sqlfluff lint + barcha testlar) topshirishdan oldin toza bo'lishi shart.

## DB'ga xos kelishuvlar

- Har kod papkasi `<modul>/NN-slug/`, asosiy fayl modulga qarab: SQL modullarida `main.sql` (yoki `task_N.sql`), MongoDB `main.js`, Cassandra `main.cql`, Redis `main.redis`, Neo4j `main.cypher`, Elasticsearch/DynamoDB `main.sh`. Test: `test.sql` (pgTAP, MyTAP, tSQLt, utPLSQL), `test.js`, `test.sh`.
- Fayllar qayta ishga tushirilganda xato bermasligi kerak (idempotent): `DROP ... IF EXISTS` / `CREATE OR REPLACE` / `CREATE OR ALTER` yoki dars boshida sxemani tozalash. Tekshiruvda Claude faylni ikki marta ishga tushiradi.
- Har dars o'z sxemasida ishlaydi (masalan `CREATE SCHEMA lesson05`), boshqa darslar ma'lumotini buzmaydi. MongoDB'da alohida database, Cassandra'da alohida keyspace, Redis'da key prefiksi (`l05:`).
- `sql/` moduli standart SQL: vazifalar PostgreSQL'da yoziladi, dialekt vazifalari `make sql n=NN db=mysql` bilan boshqa DB'da ham tekshiriladi.
- Parollar faqat lokal `docker-compose.yml` dagi o'quv qiymatlari. Haqiqiy kalit, bulut hisobi va shaxsiy ma'lumot git'ga hech qachon kirmaydi (`.env` gitignore'da). Bulut xizmatlari (Snowflake, BigQuery, Atlas) faqat bepul tarif yoki lokal emulyatorda, xarajat oldindan aytiladi.
