#!/usr/bin/env bash
# Rewrites the totals table in README.md (between the totals markers) from
# the latest snapshot of every asset in snapshots.csv: one row per release,
# one column per asset kind. Test releases (versions 99.x) and the READ-ME
# text asset are left out; both stay in the data.
set -euo pipefail

TABLE=$(awk -F, '
  NR > 1 && $2 !~ /^release-99_/ {
    # later rows overwrite earlier ones; the file is chronological
    count[$2, $3] = $4
    tag[$2] = 1
    if ($3 ~ /-bin\.zip$/)               kind[$2, $3] = "bin"
    else if ($3 ~ /-bin\+doc\.zip$/)     kind[$2, $3] = "doc"
    else if ($3 ~ /\.(msi|dmg|deb)$/)    kind[$2, $3] = "inst"
    else if ($3 ~ /-yfiles-addon\.zip$/) kind[$2, $3] = "addon"
    else                                 kind[$2, $3] = "other"
  }
  END {
    for (k in count) {
      split(k, p, SUBSEP)
      if (kind[k] != "other") {
        sum[p[1], kind[k]] += count[k]
        total[p[1]] += count[k]
        all[kind[k]] += count[k]
        grand += count[k]
      }
    }
    for (t in tag) {
      v = t; sub(/^release-/, "", v); gsub(/_/, ".", v)
      printf "| %s | %d | %d | %d | %d | **%d** |\n", v, sum[t,"bin"], sum[t,"doc"], sum[t,"inst"], sum[t,"addon"], total[t]
    }
    # the rows are version-sorted below, descending; the leading 0 sorts the
    # grand total last and is stripped again
    printf "| 0**all** | %d | %d | %d | %d | **%d** |\n", all["bin"], all["doc"], all["inst"], all["addon"], grand
  }' snapshots.csv | sort -t'|' -k2,2Vr | sed 's/^| 0\*\*all/| **all/')

LATEST=$(tail -1 snapshots.csv | cut -d, -f1)
{
  sed -n '1,/^<!-- totals -->$/p' README.md
  echo
  echo "As of $LATEST, cumulative since each release was published on GitHub."
  echo
  echo "| Release | bin | bin+doc | installers | yFiles add-on | total |"
  echo "|---|---:|---:|---:|---:|---:|"
  echo "$TABLE"
  echo
  sed -n '/^<!-- \/totals -->$/,$p' README.md
} > README.md.tmp
mv README.md.tmp README.md
