#!/usr/bin/env bash
# Appends today's download count of every asset of every release of
# nl-utwente-groove/code to snapshots.csv, one row per asset. Rows of an
# earlier run on the same day are replaced, so a manual run refreshes the
# day instead of duplicating it. Needs the gh CLI, authenticated or not.
set -euo pipefail

REPO=nl-utwente-groove/code
FILE=snapshots.csv
TODAY=$(date -u +%F)

[ -f "$FILE" ] || echo "date,tag,asset,count" > "$FILE"
grep -v "^$TODAY," "$FILE" > "$FILE.tmp"
# no field contains a comma, so a plain join beats @csv's quoting; the date
# is spliced into the filter as a literal, since gh's --jq takes no --arg
gh api "repos/$REPO/releases?per_page=100" --paginate \
  --jq ".[] | .tag_name as \$t | .assets[] | [\"$TODAY\", \$t, .name, (.download_count | tostring)] | join(\",\")" \
  >> "$FILE.tmp"
mv "$FILE.tmp" "$FILE"
