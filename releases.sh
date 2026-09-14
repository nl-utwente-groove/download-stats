#!/usr/bin/env bash
# Rewrites releases.csv: the publication date of every release, one row
# per version as version,date,source. The GitHub releases come from the
# releases API (all of them, test releases included; the presentation
# filters); the other versions from the folder dates on SourceForge, which
# are the upload dates: groove/<version> for the versions before the move
# to GitHub, release-<version> for the few later ones that GitHub no longer
# has. A version on both sites takes the GitHub date. Needs the gh CLI,
# curl and GNU sed/sort.
set -euo pipefail

REPO=nl-utwente-groove/code
SF=https://sourceforge.net/projects/groove/files
FILE=releases.csv

# prints version,date,sourceforge for the version folders of a SourceForge
# listing; a folder row is followed by its date cell, folder names such as
# release-7_5_0 and 6.8.0-go-to-github are reduced to the version
folders() {
  curl -sSf "$SF/$1" | sed -n '
    s/^.*<tr title="\(release-\)\{0,1\}\([0-9]*\)[._]\([0-9]*\)[._]\([0-9]*\)[^"]*" class="folder.*$/\2.\3.\4/p
    s/^.*headers="files_date_h"[^<]*<abbr title="\([0-9-]*\) .*$/\1/p' \
    | sed -n 'N; s/\n/,/; s/$/,sourceforge/p'
}

{
  echo "version,date,source"
  {
    gh api "repos/$REPO/releases?per_page=100" --paginate \
      --jq '.[] | select(.draft | not) | [.tag_name, .published_at[:10], "github"] | join(",")' \
      | sed 's/^release-//; s/^\([0-9]*\)_\([0-9]*\)_\([0-9]*\),/\1.\2.\3,/'
    folders ""
    folders "groove/"
  } | awk -F, '!seen[$1]++' | sort -t, -k1,1Vr
} > "$FILE.tmp"
mv "$FILE.tmp" "$FILE"
