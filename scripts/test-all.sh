#!/usr/bin/env bash
# Test fayli bor barcha papkalarni ishga tushiradi. Kerakli konteyner ishlamasa o'tkazib yuboradi.
set -uo pipefail
cd "$(dirname "$0")/.."
running="$(docker ps --format '{{.Names}}' 2>/dev/null || true)"
fail=0; ran=0; skipped=0
while IFS= read -r t; do
  d="$(dirname "$t")"; f="$(basename "$t")"; m="${d%%/*}"
  case "$f" in
    test.js) c=mongodb ;;
    test.cypher) c=neo4j ;;
    test.sh|test_main.py) c="" ;;
    *) case "$m" in
         mysql) c=mysql ;; mssql) c=mssql ;; oracle) c=oracle ;; clickhouse) c=clickhouse ;;
         timeseries) c=timescale ;; newsql) c=cockroach ;; sqlite) c="" ;; *) c=postgres ;;
       esac ;;
  esac
  if [ -n "$c" ] && ! grep -qx "ldb-$c" <<<"$running"; then
    echo "skip  $d (ldb-$c ishlamayapti)"; skipped=$((skipped+1)); continue
  fi
  echo "==> $d/$f"
  if scripts/run.sh test "$d" "" "$f"; then ran=$((ran+1)); else echo "FAIL  $d"; fail=$((fail+1)); fi
done < <(find . \( -name docs -o -name docker -o -name scripts -o -name .venv -o -name node_modules \) -prune -o \
          \( -name test.sql -o -name test.js -o -name test.cypher -o -name test.sh -o -name test_main.py \) -print | sed 's|^\./||' | sort)
echo "Natija: $ran o'tdi, $fail yiqildi, $skipped o'tkazib yuborildi"
[ "$fail" -eq 0 ]
