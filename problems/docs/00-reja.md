# Masalalar rejasi: SQL va DB masalalari, intervyu tayyorgarligi

Nima uchun alohida: darslarda tushuncha o'rganiladi, masalada esa uni tez va to'g'ri qo'llash mashq qilinadi. SQL intervyularining 80% i bir xil 10–12 pattern atrofida aylanadi (top-N per group, gaps-and-islands, running total, dedup, self-join, anti-join, pivot, median, retention/cohort, consecutive rows). Bu modul shu patternlarni "ko'rgan zahoti tanish" darajasiga olib chiqadi.

Boshlash: `sql/` I bosqichi (SELECT, JOIN, aggregatsiya) tugagach LeetCode Easy; `sql/` window function va CTE mavzularidan keyin Medium/Hard. NoSQL masalalari tegishli modul II bosqichidan keyin.

Ishlash tartibi: har masala alohida papka: `problems/<manba>/<raqam>-<qisqa-nom>/`. Ichida `main.sql` (yechim), kerak bo'lsa `schema.sql` (masaladagi jadval va namunaviy ma'lumot, siz o'zingiz masala matnidan ko'chirasiz) va `test.sql` (pgTAP: kutilgan natija bilan `results_eq`). Yechim PostgreSQL'da; har 5-masalada bir xil yechimni MySQL yoki MSSQL dialektida ham yozing (`main.mysql.sql`, `make lc n=0175 f=main.mysql.sql db=mysql`). Yangi papka: `make new d=problems/leetcode/0175-combine-two-tables`. Ishga tushirish: `make lc n=0175`, test: `make lc-test n=0175`.

Raqamlash: LeetCode'da masalaning asl raqami (4 xonali, `0175`), HackerRank, Codewars va interview'da o'zingiz ketma-ket beradigan raqam (`0001`). Har yechim faylining boshida kommentda: masala havolasi, pattern nomi, vaqt/murakkablik izohi (qaysi indeks yordam beradi), muqobil yechim (masalan window vs correlated subquery).

Ba'zi masalalar (masalan 1270, 1285 va streak masalalari) LeetCode Premium bo'lishi mumkin. Premium bo'lsa masala matnini nomidan va patternidan o'zingiz qayta tuzing (o'z `schema.sql` va kutilgan natija bilan), pattern muhim, sayt emas.

## Vaqt hisobi

| Bosqich | Masalalar | Vaqt (parallel, kuniga 30–45 daqiqa) |
|---|---|---|
| I: LeetCode SQL 50 (Easy/Medium) | 50 | 5–6 hafta |
| II: Klassik Database masalalari (Medium/Hard) | 25 | 3–4 hafta |
| III: HackerRank SQL va pgexercises | 40 | 3 hafta |
| IV: Analytics/intervyu (DataLemur, StrataScratch uslubi) | 30 | 4 hafta |
| V: NoSQL va DB system design | 15 | 3 hafta |
| **Jami** | **~160** | **18–20 hafta parallel** |

Siz uchun: SQL sintaksisi yangi bo'lsa ham mantiqiy fikrlash (set, map/filter/reduce) JS'dan tanish: `GROUP BY` = `reduce`, `WHERE` = `filter`, window function = "har elementga butun massivni ko'rib hisoblash". I bosqichni 4 haftada tugatish real.

## I bosqich: LeetCode "Top SQL 50" o'quv rejasi

Manba: https://leetcode.com/studyplan/top-sql-50/ . Tartib reja bo'yicha:

1. **Select**: 1757 Recyclable and Low Fat Products, 584 Find Customer Referee (`NULL` tuzog'i), 595 Big Countries, 1148 Article Views I, 1683 Invalid Tweets
2. **Basic Joins**: 1378 Replace Employee ID With The Unique Identifier, 1068 Product Sales Analysis I, 1581 Customer Who Visited but Did Not Make Any Transactions (anti-join), 197 Rising Temperature (self-join sana bilan), 1661 Average Time of Process per Machine, 577 Employee Bonus, 1280 Students and Examinations (`CROSS JOIN` + `LEFT JOIN`), 570 Managers with at Least 5 Direct Reports, 1934 Confirmation Rate
3. **Basic Aggregate Functions**: 620 Not Boring Movies, 1251 Average Selling Price (interval join), 1075 Project Employees I, 1633 Percentage of Users Attended a Contest, 1211 Queries Quality and Percentage, 1193 Monthly Transactions I (shartli aggregatsiya `FILTER`/`CASE`), 1174 Immediate Food Delivery II, 550 Game Play Analysis IV (retention)
4. **Sorting and Grouping**: 2356 Number of Unique Subjects Taught by Each Teacher, 1141 User Activity for the Past 30 Days I, 1070 Product Sales Analysis III, 596 Classes More Than 5 Students, 1729 Find Followers Count, 619 Biggest Single Number, 1045 Customers Who Bought All Products (relational division)
5. **Advanced Select and Joins**: 1731 The Number of Employees Which Report to Each Employee, 1789 Primary Department for Each Employee, 610 Triangle Judgement, 180 Consecutive Numbers (gaps-and-islands kirish), 1164 Product Price at a Given Date (as-of join), 1204 Last Person to Fit in the Bus (running total), 1907 Count Salary Categories (bo'sh guruhni ham chiqarish)
6. **Subqueries**: 1978 Employees Whose Manager Left the Company, 626 Exchange Seats, 1341 Movie Rating (`UNION ALL` bilan ikki natija), 1321 Restaurant Growth (moving average, `ROWS BETWEEN`), 602 Friend Requests II, 585 Investments in 2016, 185 Department Top Three Salaries (top-N per group, `DENSE_RANK`)
7. **Advanced String Functions / Regex / Clause**: 1667 Fix Names in a Table, 1527 Patients With a Condition (regex chegarasi), 196 Delete Duplicate Emails (`DELETE ... USING`, dedup), 176 Second Highest Salary (bo'sh natijada `NULL`), 1484 Group Sold Products By The Date (`STRING_AGG`), 1327 List the Products Ordered in a Period, 1517 Find Users With Valid E-Mails

## II bosqich: Klassik Database masalalari (Medium/Hard)

8. **Ranking va top-N**: 177 Nth Highest Salary (funksiya yozish: PL/pgSQL `RETURNS TABLE` va MySQL `CREATE FUNCTION`, ikkalasida), 178 Rank Scores, 184 Department Highest Salary, 586 Customer Placing the Largest Number of Orders (tie bilan va tie'siz)
9. **Self-join va ierarxiya**: 181 Employees Earning More Than Their Managers, 608 Tree Node (`CASE` bilan tugun turi), 1270 All People Report to the Given Manager (rekursiv CTE bilan qayta yeching), 607 Sales Person
10. **Gaps-and-islands va ketma-ketlik**: 601 Human Traffic of Stadium (`id - ROW_NUMBER()` usuli), 180 ni window bilan qayta yechish, 1285 Find the Start and End Number of Continuous Ranges, 2173 va shu kabi streak masalalari (bepul bo'lsa)
11. **Murakkab hisobot**: 262 Trips and Users (bekor qilish foizi, bir nechta filtr), 1158 Market Analysis I, 1393 Capital Gain/Loss, 1407 Top Travellers, 1179 Reformat Department Table (pivot: `CASE`/`FILTER`, MSSQL `PIVOT`, Oracle `PIVOT` uch dialektda)
12. **DML masalalari**: 627 Swap Salary (`UPDATE` + `CASE`), 196 ni MySQL'da (`DELETE` self-join cheklovi) va MSSQL'da (CTE orqali `DELETE`) qayta yechish, 182 Duplicate Emails, 183 Customers Who Never Order (`NOT IN` + `NULL` tuzog'ini isbotlang, `NOT EXISTS` bilan to'g'rilang)

Har masalada: kamida ikki yechim (masalan window va correlated subquery), `EXPLAIN ANALYZE` bilan 100k qatorli generatsiya qilingan ma'lumotda solishtirish (`generate_series`), qaysi indeks yordam berishi kommentda.

## III bosqich: HackerRank SQL va pgexercises

13. **HackerRank SQL (Basic Select, Aggregation)**: https://www.hackerrank.com/domains/sql . Revising the Select Query I/II, Weather Observation Station 1–20 (string, median WOS 20), Employee Salaries, The Blunder, Top Earners. Dialekt: MySQL yoki MS SQL Server tanlanadi, shu yerda MSSQL'ni mashq qiling
14. **HackerRank (Basic/Advanced Join, Advanced Select)**: Type of Triangle, The PADS, Occupations (pivot), Binary Tree Nodes, New Companies, Population Census, African Cities, The Report, Top Competitors, Ollivander's Inventory, Challenges, Contest Leaderboard, SQL Project Planning (gaps-and-islands), Placements, Symmetric Pairs, Interviews, 15 Days of Learning SQL (Hard)
15. **pgexercises.com**: https://pgexercises.com . Basic, Joins, Modifying data, Aggregates, Working with timestamps, String operations, Recursive queries bo'limlari to'liq (club ma'lumot bazasi `make up db=postgres` ga yuklanadi, schema saytdan)
16. **SQL Murder Mystery va SQL Island**: https://mystery.knightlab.com (SQLite: `make lite` bilan lokal), qiziqarli dam olish mashqi
17. **Codewars SQL kata**: https://www.codewars.com/kata/search/sql . 7–4 kyu, PostgreSQL dialekti, haftasiga 2–3 ta

## IV bosqich: Analytics va intervyu masalalari

Manbalar: DataLemur (https://datalemur.com, bepul qismi), StrataScratch (https://www.stratascratch.com, bepul qismi), "Ace the Data Science Interview" SQL bo'limi. Masalani saytdan ko'chirmasdan, patternni o'zingiz `problems/interview/` da qayta tuzasiz (o'z sxemangiz bilan).

18. **Funnel va conversion**: bosqichma-bosqich konversiya foizi, `COUNT(DISTINCT ...) FILTER`, funnel buzilish nuqtasi
19. **Retention va cohort**: D1/D7/D30 retention, oylik cohort jadvali, `date_trunc` va `generate_series` bilan bo'sh oylarni to'ldirish
20. **Sessionization**: 30 daqiqalik bo'shliq bilan sessiya chegarasi (`LAG` + running `SUM`), sessiya davomiyligi
21. **Median, percentile va statistika**: `PERCENTILE_CONT`, MySQL'da median (window bilan), MSSQL `PERCENTILE_CONT ... OVER`, mode, standart og'ish
22. **Year-over-year va moving metrics**: `LAG(.., 12)`, 7 kunlik moving average, cumulative share, Pareto (80/20)
23. **SCD va as-of join**: narx tarixidan sana bo'yicha qiymat, valid_from/valid_to oraliqlari, overlap aniqlash
24. **Graph va rekursiya SQL'da**: do'stlar tavsiyasi (friend-of-friend), eng qisqa yo'l rekursiv CTE bilan, sikl aniqlash
25. **Deduplication va data quality**: oxirgi versiyani olish (`DISTINCT ON`, `QUALIFY`-ga o'xshash), fuzzy dublikat (`pg_trgm`), orphan qatorlar
26. **Optimizatsiya masalalari**: berilgan sekin so'rovni (sizga Claude beradi) indeks, qayta yozish va statistika bilan 10x tezlashtirish, natijani `EXPLAIN (ANALYZE, BUFFERS)` bilan isbotlash
27. **Procedura masalalari**: bank o'tkazmasi procedurasi (PL/pgSQL, T-SQL, PL/SQL uchtasida, deadlock va idempotency bilan), inventar band qilish (`SKIP LOCKED`), audit trigger, rekursiv kategoriya daraxti funksiyasi

## V bosqich: NoSQL va DB system design

28. **MongoDB masalalari**: aggregation pipeline bilan top-N per group, `$lookup` + `$unwind` hisobot, `$setWindowFields` running total, schema dizayn masalasi (blog, e-commerce, chat), MongoDB University bepul labs
29. **Redis masalalari**: leaderboard (Sorted Set), sliding window rate limiter (Lua), unique visitors (HyperLogLog), distributed lock va uning tuzoqlari
30. **Cassandra/DynamoDB modellash**: access pattern ro'yxatidan jadval dizayni (messaging, IoT, URL shortener), single-table design mashqi
31. **DB system design**: URL shortener, Twitter timeline, ride-sharing geo, payment ledger, analytics pipeline: har biri uchun DB tanlash, sxema, indeks, sharding, replikatsiya va consistency qarori, `problems/interview/` da `design.md`. Manba: Alex Xu "System Design Interview" 1–2, "Designing Data-Intensive Applications"

## Mezon

Masala "yechildi" deyiladi, agar: `main.sql` LeetCode/HackerRank'da qabul qilingan, `test.sql` lokal o'tadi, kommentda pattern nomi va muqobil yechim bor, II bosqichdan boshlab `EXPLAIN` izohi bor. Shanba kuni haftalik masalalar menga tekshirishga beriladi.

## Manbalar

- LeetCode Top SQL 50: https://leetcode.com/studyplan/top-sql-50/ , Database bo'limi: https://leetcode.com/problemset/database/
- HackerRank SQL: https://www.hackerrank.com/domains/sql
- PostgreSQL Exercises: https://pgexercises.com
- SQLZoo: https://sqlzoo.net , SQLBolt: https://sqlbolt.com (I bosqichdan oldin isinish)
- DataLemur: https://datalemur.com , StrataScratch: https://www.stratascratch.com
- SQL Murder Mystery: https://mystery.knightlab.com
- Codewars SQL: https://www.codewars.com/kata/search/sql
- Anthony Molinaro, Robert de Graaf, "SQL Cookbook" (2-nashr, O'Reilly): patternlar to'plami
- Itzik Ben-Gan, "T-SQL Window Functions" (2-nashr): window patternlari (dialektdan qat'iy nazar foydali)
- Alex Xu, "System Design Interview" Vol. 1–2
