-- Faqat birinchi ishga tushishda (bo'sh volume) bajariladi. Qayta: make reset db=postgres
\connect ldb
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pgtap;
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS plpgsql_check;
