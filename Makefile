# learn-database: o'quv loyihasi Makefile
#
# Boshlash:
#   make doctor                    muhitni tekshirish (docker, compose, arm64/Rosetta, sqlite3, uv)
#   make setup                     .venv va asboblar (sqlfluff, pytest) bir marta
#   make up db=postgres            DB konteynerini ko'tarish (guruhlar: rdbms, nosql, de, newsql, all)
#   make up db=redis-cluster       laboratoriya profillari: docker/compose/<nom>.yml (dars bilan qo'shiladi)
#   make down                      hammasini to'xtatish (ma'lumot volume'da qoladi)
#   make reset db=postgres         konteyner va uning volume'ini o'chirib, toza qayta ko'tarish
#   make shell db=postgres         interaktiv klient (psql, mysql, sqlcmd, sqlplus, mongosh, cqlsh, redis-cli, ...)
#   make ps, make logs db=mssql    holat va loglar
#   make install-tests db=mysql    MyTAP / tSQLt / utPLSQL o'rnatish (pgTAP image ichida bor)
#   make seed s=shop [db=mysql]    namuna sxemani yuklash: */docs/schema/<s>.sql (yoki <s>.<db>.sql)
#
# Umumiy:
#   make run d=postgres/05-mvcc              papkadagi main.* faylni o'z DB'sida ishga tushirish
#   make run d=sql/03-joins db=mysql         boshqa dialektda: papkadagi barcha task_N.mysql.sql fayllar
#   make run d=oracle/20-plsql-cursors f=task_3.sql   aniq faylni
#   make test d=postgres/12-plpgsql-functions        test.* (pgTAP, MyTAP, tSQLt, utPLSQL, test.js, test.sh)
#
# Qisqa yo'llar (n = raqam prefiksi, papka nomining qolgani avtomatik topiladi; db= va f= ham ishlaydi):
#   make th n=01      theory/01-*/             make sql n=01     sql/01-*/  (db=mysql|mssql|oracle|sqlite)
#   make pg n=01      postgres/01-*/           make my n=01      mysql/01-*/
#   make ms n=01      mssql/01-*/              make ora n=01     oracle/01-*/
#   make lite n=01    sqlite/01-*/             make mongo n=01   mongodb/01-*/
#   make cass n=01    cassandra/01-*/          make rds n=01     redis/01-*/
#   make es n=01      elasticsearch/01-*/      make graph n=01   graph/01-*/
#   make ch n=01      clickhouse/01-*/         make ddb n=01     dynamodb/01-*/
#   make nsql n=01    newsql/01-*/ (db=cockroach|yugabyte|tidb)
#   make ts n=01      timeseries/01-*/         make vec n=01     vector/01-*/
#   make de n=01      data-engineering/01-*/   make ops n=01     ops/01-*/
#   make app n=01     app/01-*/{go,python,ts} (lang=go|python|ts, standart .app-lang)
#                 make proj n=01    projects/01-*/
#   make lc n=0175    problems/leetcode/0175-*/      make hr n=0001   problems/hackerrank/0001-*/
#   make cw n=0001    problems/codewars/0001-*/      make iv n=0001   problems/interview/0001-*/
#   Testlar: har biriga -test qo'shing: make pg-test n=12, make lc-test n=0175
#
# Yangi papka:
#   make new d=postgres/05-mvcc                 fayl turi modulga qarab (main.sql, main.js, main.cql, ...)
#   make new d=problems/leetcode/0175-combine-two-tables
#
# Sifat:
#   make lint                      sqlfluff lint (dialekt har modul .sqlfluff faylidan)
#   make fmt                       sqlfluff fix
#   make test-all                  test fayli bor barcha papkalar (konteyner ishlamasa o'tkazib yuboriladi)
#   make check                     lint + test-all (topshirishdan oldin toza bo'lishi shart)

.DEFAULT_GOAL := help
SHELL := /bin/bash

PY      ?= $(if $(wildcard .venv/bin/python),.venv/bin/python,python3)
# Asosiy compose + laboratoriya fayli (docker/compose/<db>.yml bo'lsa: klaster, replika, sentinel va h.k.)
LAB      = $(wildcard docker/compose/$(db).yml)
COMPOSE  = docker compose -f docker-compose.yml $(if $(LAB),-f $(LAB))


# ---- yordamchi ----
find_dir = $(patsubst %/,%,$(firstword $(wildcard $(1)/$(2)*/)))

define need_n
	@if [ -z "$(n)" ]; then echo "n=<raqam> bering, masalan: make $(1) n=01"; exit 1; fi
endef

.PHONY: help
help:
	@awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print; next} NR>1 {exit}' $(MAKEFILE_LIST) | sed 's/^# \{0,1\}//'

# ---- muhit ----
.PHONY: doctor setup
doctor: ## muhitni tekshirish
	@echo "Arxitektura: $$(uname -m)"
	@command -v docker >/dev/null && docker --version || echo "XATO: docker yo'q. O'rnating: OrbStack (brew install orbstack) yoki Docker Desktop"
	@docker compose version 2>/dev/null || echo "XATO: docker compose yo'q"
	@if [ "$$(uname -m)" = arm64 ]; then echo "Apple Silicon: MSSQL uchun Rosetta yoqilgan bo'lsin (OrbStack'da avtomatik; Docker Desktop: Settings > General > Use Rosetta)"; fi
	@command -v sqlite3 >/dev/null && echo "sqlite3 $$(sqlite3 --version | cut -d' ' -f1)" || echo "sqlite3 yo'q: brew install sqlite"
	@command -v uv >/dev/null && uv --version || echo "uv yo'q (ixtiyoriy, tavsiya): brew install uv"
	@test -x .venv/bin/sqlfluff && echo "sqlfluff: .venv ichida bor" || echo "sqlfluff yo'q: make setup"

setup: ## .venv va asboblar
	@if command -v uv >/dev/null 2>&1; then \
		uv venv .venv && uv pip install --python .venv/bin/python -r requirements/dev.txt; \
	else \
		python3 -m venv .venv && .venv/bin/pip install -U pip && .venv/bin/pip install -r requirements/dev.txt; \
	fi
	@echo "Tayyor. Keyingi qadam: make up db=postgres"

# ---- konteynerlar ----
.PHONY: up down reset shell ps logs install-tests
up: ## make up db=postgres
	@test -n "$(db)" || (echo "db=<nom> bering: postgres mysql mssql oracle mongodb cassandra redis dynamodb elasticsearch neo4j clickhouse timescale qdrant cockroach yugabyte tidb minio kafka cdc iceberg trino | rdbms nosql de newsql all"; exit 1)
	$(COMPOSE) --profile $(db) up -d --build --wait

down:
	$(COMPOSE) --profile all down

reset:
	@test -n "$(db)" || (echo "db=<nom> bering"; exit 1)
	$(COMPOSE) --profile $(db) down -v
	$(COMPOSE) --profile $(db) up -d --build --wait

shell:
	@test -n "$(db)" || (echo "db=<nom> bering"; exit 1)
	@scripts/shell.sh $(db)

ps:
	$(COMPOSE) --profile all ps

logs:
	@test -n "$(db)" || (echo "db=<nom> bering"; exit 1)
	$(COMPOSE) --profile all logs -f --tail=200 $(db)

install-tests:
	@test -n "$(db)" || (echo "db=mysql|mssql|oracle bering"; exit 1)
	@scripts/install-test-frameworks.sh $(db)

# ---- namuna sxemalar (seed) ----
.PHONY: seed
seed: ## make seed s=shop [db=postgres]; fayl: */docs/schema/<s>.sql yoki <s>.<db>.sql
	@test -n "$(s)" || (echo "s=<sxema> bering, masalan: make seed s=shop"; exit 1)
	@db="$(or $(db),postgres)"; \
	if [ "$$db" = postgres ]; then name="$(s).sql"; else name="$(s).$$db.sql"; fi; \
	p="$$(ls -1 */docs/schema/$$name 2>/dev/null | head -1)"; \
	test -n "$$p" || { echo "Topilmadi: */docs/schema/$$name"; exit 1; }; \
	echo "Yuklanmoqda: $$p ($$db)"; scripts/run.sh run "$$(dirname $$p)" "$$db" "$$(basename $$p)"

# ---- umumiy ishga tushirish ----
.PHONY: run test
run:
	@test -n "$(d)" || (echo "d=<papka> bering, masalan: make run d=postgres/01-architecture"; exit 1)
	@scripts/run.sh run $(d) "$(db)" "$(f)"

test:
	@test -n "$(d)" || (echo "d=<papka> bering"; exit 1)
	@scripts/run.sh test $(d) "$(db)" "$(f)"

# ---- qisqa yo'llar: <buyruq>:<papka> ----
SHORTCUTS = th:theory sql:sql pg:postgres my:mysql ms:mssql ora:oracle lite:sqlite \
	mongo:mongodb cass:cassandra rds:redis es:elasticsearch graph:graph ch:clickhouse \
	ddb:dynamodb nsql:newsql ts:timeseries vec:vector de:data-engineering ops:ops \
	app:app proj:projects lc:problems/leetcode hr:problems/hackerrank cw:problems/codewars \
	iv:problems/interview

define SHORTCUT
.PHONY: $(1) $(1)-test
$(1):
	$$(call need_n,$(1))
	@d="$$(call find_dir,$(2),$$(n))"; test -n "$$$$d" || { echo "Papka topilmadi: $(2)/$$(n)*"; exit 1; }; \
		LANG_SEL="$$(lang)" scripts/run.sh run "$$$$d" "$$(db)" "$$(f)"
$(1)-test:
	$$(call need_n,$(1)-test)
	@d="$$(call find_dir,$(2),$$(n))"; test -n "$$$$d" || { echo "Papka topilmadi: $(2)/$$(n)*"; exit 1; }; \
		LANG_SEL="$$(lang)" scripts/run.sh test "$$$$d" "$$(db)" "$$(f)"
endef
$(foreach s,$(SHORTCUTS),$(eval $(call SHORTCUT,$(word 1,$(subst :, ,$(s))),$(word 2,$(subst :, ,$(s))))))

# ---- yangi papka ----
.PHONY: new
new: ## make new d=postgres/05-mvcc
	@test -n "$(d)" || (echo "d=<modul>/<NN-nom> bering"; exit 1)
	@test ! -e "$(d)" || (echo "$(d) allaqachon bor"; exit 1)
	@mkdir -p "$(d)"
	@case "$(d)" in \
		mongodb/*) touch "$(d)/main.js" ;; \
		cassandra/*) touch "$(d)/main.cql" ;; \
		redis/*) touch "$(d)/main.redis" ;; \
		graph/*) touch "$(d)/main.cypher" ;; \
		elasticsearch/*|dynamodb/*) printf '#!/usr/bin/env bash\nset -euo pipefail\n' > "$(d)/main.sh" ;; \
		*) touch "$(d)/main.sql" ;; \
	esac
	@echo "Yaratildi: $(d)/"; ls "$(d)"

# ---- sifat ----
.PHONY: lint fmt test-all check
lint:
	@scripts/lint.sh lint

fmt:
	@scripts/lint.sh fix

test-all:
	@scripts/test-all.sh

check: lint test-all
	@echo "make check: toza"
