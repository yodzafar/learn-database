# PostgreSQL 18 + o'quv uchun kerakli kengaytmalar (PGDG apt repozitoriyasidan).
FROM postgres:18

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      postgresql-18-pgtap \
      libtap-parser-sourcehandler-pgtap-perl \
      postgresql-18-pgvector \
      postgresql-18-cron \
      postgresql-18-postgis-3 \
      postgresql-18-plpgsql-check \
      postgresql-18-partman \
      postgresql-18-hypopg \
      postgresql-plpython3-18 \
 && rm -rf /var/lib/apt/lists/*

# Birinchi ishga tushishda ldb bazasida kengaytmalar yaratiladi.
COPY init/ /docker-entrypoint-initdb.d/
