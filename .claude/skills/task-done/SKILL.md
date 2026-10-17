---
name: task-done
description: Qabul qilingan (✓) vazifani alohida commit qilib push qiladi. Tekshiruvda vazifa ✓ bo'lgach avtomatik chaqiriladi, yoki qo'lda `/task-done <modul-yo'li> <N>`.
---

# task-done

Har bir qabul qilingan vazifa uchun bitta commit, keyin (remote bo'lsa) push. Bir tekshiruvda bir nechta vazifa qabul qilinsa, har biriga alohida commit, raqam tartibida.

## Kirish ma'lumotlari

- Modul yo'li: masalan `sql/01-sql-basics`, `postgres/14-plpgsql-functions`, `problems/leetcode/0175-combine-two-tables`.
- Vazifa raqami `N` va inglizcha sarlavhasi. Sarlavha modul `docs/PROGRESS.md` (masalalar uchun `problems/PROGRESS.md`) dagi `N. Title` qatoridan olinadi, o'zgartirilmaydi.
- Argument berilmasa, shu suhbatda oxirgi marta ✓ qilingan vazifa(lar) olinadi.

## Shartlar

1. Vazifa modul progress faylida `[x]` bo'lishi shart. `[!]` yoki `[~]` bo'lsa commit qilinmaydi.
2. Papkadagi `.sql` fayllar uchun `sqlfluff lint <fayllar>` toza bo'lishi, test fayli bo'lsa `make test d=<papka>` o'tishi kerak. Toza bo'lmasa to'xta va sababini ayt.

## Qadamlar

1. `git status --short` bilan o'zgargan fayllarni ko'r.
2. Faqat shu vazifaga tegishli fayllarni stage qil:
   - vazifa fayli (`task_N.sql`, `main.*` yoki masala papkasidagi fayllar);
   - shu vazifa uchun o'zgargan umumiy fayllar (`test.sql`, `test.js` va shu kabi);
   - modul progress fayli va ildiz `PROGRESS.md`.
   `README.md`, `ROADMAP.md`, `*/docs/*.md` kabi darsga oid fayllar bu commitga kirmaydi.
3. Bir nechta vazifa bitta faylda bo'lsa (`main.sql`), har commitda faylni faqat o'sha vazifagacha bo'lgan holatda stage qil (`git hash-object -w` + `git update-index --cacheinfo`), ishchi daraxtga tegma.
4. Commit xabari, aynan shu ko'rinishda:

   ```
   task-done: <modul-yo'li> <N>. <Title>
   ```

   Sessiyada belgilangan attribution qatorlari (Co-Authored-By) xabar oxiriga qo'shiladi.
5. `git remote get-url origin` bo'lsa `git push origin main`.
6. Hisobotda commit hash va push natijasini ayt. Push o'tmasa commit saqlanib qoladi, foydalanuvchiga `git push` ni o'zi ishlatishini ayt.
