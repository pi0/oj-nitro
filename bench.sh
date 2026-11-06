#!/usr/bin/env bash
# Build benchmark: oj vs vite on this app, Nitro `vercel` preset.
#
#   ./bench.sh [app-dir]        (default: this script's directory)
#   RUNS=10 ./bench.sh
#
# Linux only: needs GNU time at /usr/bin/time (user/sys/maxRSS of the whole
# reaped process tree; oj's helper processes are waited for, so they count).
# maxRSS is the peak of the largest single process, not a sum; for both tools
# the peak process is the main one (checked by sampling the process tree).
#
# Modes (each tool's build is preceded by the same preparation):
#   cold  no build caches at all: .oj-cache, node_modules/.nitro, .vite, and
#         Node's compile cache (vite's bin enables it; by default it lives in
#         $TMPDIR/node-compile-cache, outside the app, and would stay warm).
#   warm  rebuild with nothing changed: every tool keeps its own caches.
#   edit  rebuild after a content change in a route file: caches kept, but
#         route-keyed caches miss. Closest to an everyday local rebuild.
# OS page cache is warm in every mode (a warmup run precedes each mode).
set -euo pipefail

APP=$(cd "${1:-$(dirname "$0")}" && pwd)
RUNS=${RUNS:-10}
cd "$APP"

[ -x /usr/bin/time ] && /usr/bin/time --version 2>&1 | grep -q GNU \
  || { echo "needs GNU time at /usr/bin/time" >&2; exit 1; }
node bin/oj.mjs --version >/dev/null # unpack bin/oj from bin/oj.br if needed

WORK=$(mktemp -d)
EDIT_FILE=src/routes/about.tsx
cp "$EDIT_FILE" "$WORK/edit.orig"
trap 'cp "$WORK/edit.orig" "$APP/$EDIT_FILE"; rm -rf "$WORK"' EXIT
RAW="$WORK/raw.txt"

# Same environment for both tools.
unset VERCEL VERCEL_ENV CI NODE_ENV NODE_OPTIONS NITRO_PRESET NODE_DISABLE_COMPILE_CACHE
export NITRO_PRESET=vercel
export NODE_COMPILE_CACHE="$WORK/node-compile-cache"

OJ=(bin/oj build .)
VITE=(node node_modules/vite/bin/vite.js build) # skip the pnpm sh shim

clean_out() { rm -rf .vercel/output .output node_modules/.nitro; }
clean_all() {
  clean_out
  rm -rf .oj-cache .nitro .tanstack node_modules/.vite node_modules/.vite-temp \
    node_modules/.cache "$NODE_COMPILE_CACHE"
}

run() { # tool mode record(0|1)
  local tool=$1 mode=$2 rec=$3 cmd
  if [ "$tool" = oj ]; then cmd=("${OJ[@]}"); else cmd=("${VITE[@]}"); fi
  case $mode in
    cold) clean_all ;;
    warm) clean_out ;;
    edit) clean_out
          sed -i "s|<h1>About[^<]*</h1>|<h1>About $tool $RANDOM$RANDOM</h1>|" "$EDIT_FILE" ;;
  esac
  if ! /usr/bin/time -f "$tool $mode %e %U %S %M" -o "$WORK/t" "${cmd[@]}" >"$WORK/log" 2>&1 \
     || [ ! -f .vercel/output/config.json ]; then
    echo "$tool $mode build failed:" >&2; tail -20 "$WORK/log" >&2; exit 1
  fi
  [ "$rec" = 1 ] && tail -1 "$WORK/t" >>"$RAW"
  return 0
}

echo "# $(date -u +%FT%TZ) $(uname -sr), $(nproc) cpus, $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
echo "# $(bin/oj --version), vite $(node -p 'require("./node_modules/vite/package.json").version'), node $(node -v), nitro $(node -p 'require("./node_modules/nitro/package.json").version'), runs=$RUNS"

for mode in cold warm edit; do
  run vite $mode 0; run oj $mode 0 # warmup, discarded
  for ((i = 0; i < RUNS; i++)); do # alternate order: vite,oj then oj,vite
    if ((i % 2)); then run oj $mode 1; run vite $mode 1; else run vite $mode 1; run oj $mode 1; fi
  done
done

echo
echo "| tool | mode | wall (median, min-max) | cpu user+sys | max RSS |"
echo "|---|---|---|---|---|"
col() { awk -v t="$1" -v m="$2" -v e="$3" '$1 == t && $2 == m { print (e == "cpu" ? $4 + $5 : $e) }' "$RAW" | sort -n; }
summ() { awk '{ a[NR] = $1 } END { printf "%s %s %s\n", (NR % 2 ? a[(NR + 1) / 2] : (a[NR / 2] + a[NR / 2 + 1]) / 2), a[1], a[NR] }'; }
for mode in cold warm edit; do for tool in vite oj; do
  read -r w wmin wmax < <(col $tool $mode 3 | summ)
  read -r c _ _ < <(col $tool $mode cpu | summ)
  read -r r _ _ < <(col $tool $mode 6 | summ)
  printf "| %s | %s | %.2fs (%.2f-%.2f) | %.2fs | %d MiB |\n" $tool $mode "$w" "$wmin" "$wmax" "$c" "$((${r%.*} / 1024))"
done; done
echo; echo "raw (tool mode wall user sys maxrss_kb):"; cat "$RAW"
