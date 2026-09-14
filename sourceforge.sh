#!/usr/bin/env bash
# Rewrites sourceforge-monthly.csv from the SourceForge download statistics
# of the groove project: one row per month per directory, months with no
# downloads left out. The directories are the entries of the top-level file
# listing, with groove/ (which holds one directory per version) expanded one
# level. SourceForge keeps the whole history and revises nothing, so the file
# is regenerated in full on every run rather than appended to. Needs curl
# and GNU sed/grep/sort; no JSON tool, since Git Bash on Windows has none.
set -euo pipefail

BASE=https://sourceforge.net/projects/groove/files
FILE=sourceforge-monthly.csv
TODAY=$(date -u +%F)

# prints the entries of a directory listing, folders and files alike
entries() {
  curl -sSf "$BASE/$1" | grep -o '<tr title="[^"]*" class="\(folder\|file\)' | sed 's/^<tr title="//; s/" class=.*//'
}

# prints the monthly rows of one path as month,path,count
monthly() {
  local path=$1 url
  url="$BASE/${path// /%20}"; url="${url//+/%2B}"
  curl -sSf "$url/stats/json?start_date=2007-01-01&end_date=$TODAY" \
    | grep -o '"downloads": \[[^]]*\(\][^]]*\)*\]\]' \
    | grep -o '\["[0-9]\{4\}-[0-9]\{2\}-01 00:00:00", [0-9]*\]' \
    | awk -v path="$path" -F'[", ]+' '$4 + 0 > 0 { print substr($2, 1, 7) "," path "," $4 + 0 }'
}

{
  echo "month,path,count"
  {
    entries "" | grep -vx groove | while read -r e; do monthly "$e"; done
    entries "groove/" | while read -r e; do monthly "groove/$e"; done
  } | sort -t, -k1,1 -k2,2
} > "$FILE.tmp"
mv "$FILE.tmp" "$FILE"

# the per-directory rows are expected to add up to the project total; report
# the difference, since SourceForge may count files that no longer exist
TOTAL=$(curl -sSf "$BASE/stats/json?start_date=2007-01-01&end_date=$TODAY" | grep -o '"total": [0-9]*' | grep -o '[0-9]*')
SUM=$(awk -F, 'NR > 1 { s += $3 } END { print s + 0 }' "$FILE")
[ "$TOTAL" = "$SUM" ] || echo "sourceforge.sh: project total $TOTAL, sum of directories $SUM" >&2
