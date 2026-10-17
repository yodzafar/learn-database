# SQL: progress

Belgilar: `[ ]` boshlanmagan, `[~]` yozilgan, tekshirishga yuborilmagan, `[!]` tekshirildi, qayta ishlash kerak, `[x]` tekshirildi va qabul qilindi.
Yangilash: siz `[ ]` → `[~]`, Claude tekshirgach `[x]` yoki `[!]`.

## Yozilgan darslar (vazifa darajasida)

### 1-dars: SQL asoslari (`sql/01-sql-basics/`)

**A. Muhit va katalog**

- [ ] 1. Version and client
- [ ] 2. psql meta-commands
- [ ] 3. Load the shop schema
- [ ] 4. Catalog exploration

**B. DDL**

- [ ] 5. First table
- [ ] 6. Constraints violated
- [ ] 7. ALTER TABLE
- [ ] 8. Drop and idempotency
- [ ] 9. DDL in a transaction

**C. DML**

- [ ] 10. Multi-row insert
- [ ] 11. Safe UPDATE
- [ ] 12. DELETE vs TRUNCATE
- [ ] 13. RETURNING preview

**D. SELECT va logical order**

- [ ] 14. Projection and alias
- [ ] 15. Logical order proof
- [ ] 16. Bag, not set
- [ ] 17. ORDER BY determinism
- [ ] 18. LIMIT and FETCH FIRST

**E. Tiplar**

- [ ] 19. Integer division
- [ ] 20. Money is numeric
- [ ] 21. Character types
- [ ] 22. Timestamps first look

**F. NULL va 3VL**

- [ ] 23. Equals NULL
- [ ] 24. Truth tables
- [ ] 25. NULL in filters
- [ ] 26. NOT IN trap
- [ ] 27. Aggregates and NULL
- [ ] 28. COALESCE and NULLIF

**G. Dialektlar va uslub**

- [ ] 29. Same query, other databases
- [ ] 30. Empty string and integer division across dialects
- [ ] 31. sqlfluff
- [ ] Topshirish: make lint toza, make sql n=01 idempotent, o'zini tekshirish savollari

## Reja bo'yicha qolgan mavzular (dars yozilgach vazifa ro'yxati qo'shiladi)

**I bosqich: Asoslar**

- [ ] 2. DDL: sxema va jadvallar
- [ ] 3. Ma'lumot tiplari
- [ ] 4. Constraintlar va yaxlitlik
- [ ] 5. DML: INSERT, UPDATE, DELETE
- [ ] 6. SELECT, filtr va NULL
- [ ] 7. Ifodalar va skalyar funksiyalar

**II bosqich: So'rov yozish**

- [ ] 8. JOIN turlari va semantikasi
- [ ] 9. Aggregatsiya va GROUP BY
- [ ] 10. GROUPING SETS, ROLLUP, CUBE
- [ ] 11. Subquery
- [ ] 12. Set amallar
- [ ] 13. CTE (WITH)
- [ ] 14. Rekursiv CTE

**III bosqich: Analitik SQL**

- [ ] 15. Window functions I: asoslar va ranking
- [ ] 16. Window functions II: offset va aggregat
- [ ] 17. Window functions III: frame chuqur
- [ ] 18. Pivot va unpivot
- [ ] 19. Sana, vaqt va timezone
- [ ] 20. String, pattern va regex

**IV bosqich: Ma'lumot o'zgartirish va obyektlar**

- [ ] 21. Upsert, MERGE va RETURNING
- [ ] 22. View va materialized view
- [ ] 23. Sequence, identity va kalit generatsiyasi
- [ ] 24. Tranzaksiya buyruqlari (TCL)
- [ ] 25. DCL: foydalanuvchi, rol va ruxsatlar
- [ ] 26. Indeks DDL va EXPLAIN kirish

**V bosqich: Pattern'lar va sifat**

- [ ] 27. JSON va semi-strukturali ma'lumot
- [ ] 28. Gaps-and-islands
- [ ] 29. Top-N, running total va dedup pattern'lari
- [ ] 30. Sessionization va vaqt qatori pattern'lari
- [ ] 31. SQL anti-patternlar
- [ ] 32. SQL uslubi, o'qilishi va sqlfluff

**VI bosqich: Yakun**

- [ ] 33. Procedural SQL'ga kirish
- [ ] 34. Dialektlar ko'prigi: bir so'rov, besh DB
- [ ] 35. Intervyu tayyorgarligi va yakuniy amaliyot
