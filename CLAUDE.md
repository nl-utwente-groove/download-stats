# CLAUDE.md

Guidance for Claude Code sessions in this repository. It is the companion of the GROOVE
code repository (`nl-utwente-groove/code`, checked out at `../code`); the working
practices below are the subset of that repository's `claude/CLAUDE.md` that applies to a
repository of scripts and data.

## What this repository is

Download statistics of the GROOVE releases on GitHub, reconstructed SourceForge-style:
GitHub keeps only a cumulative `download_count` per release asset, so the workflow
`.github/workflows/collect.yml` runs `collect.sh` once a day (03:17 UTC, also on manual
dispatch) to append one row per asset to `snapshots.csv`, and `totals.sh` rewrites the
per-release table in `README.md`. The time series is derived by differencing consecutive
snapshots at render time; the README explains the data and its caveats (bot traffic, draft
releases, re-uploaded assets). The same workflow runs `sourceforge.sh`, which regenerates
`sourceforge-monthly.csv` from the SourceForge statistics (monthly totals per directory
since 2007) and `releases.sh`, which regenerates `releases.csv` (publication date per
version, from the GitHub API and the SourceForge folder dates). The design record is `claude/download-stats.md` in the code repository (on
branch `download-stats-design` until merged).

The presentation is the page `downloads.md` plus `js/downloads.js` of the website
repository (`nl-utwente-groove/nl-utwente-groove.github.io`, Jekyll, checked out at
`../nl-utwente-groove.github.io`): Chart.js from cdnjs, both CSV files fetched from
`raw.githubusercontent.com`, the series derived in the browser. There is no local Jekyll;
test the script with a plain HTML harness that has the same markup as the page and a
`data-base` attribute on `#downloads` pointing at local copies of the CSV files.

The scripts run under bash with the `gh` CLI, curl and GNU awk/sed/grep/sort (no `jq`:
Windows Git Bash has none); they must keep working on `ubuntu-latest` and on Windows Git
Bash. Run them locally before changing them: `bash collect.sh && bash totals.sh` on a
clean tree, then inspect `git diff`. A local run uses the developer's token and therefore
sees draft releases that the workflow's token does not; do not commit such a snapshot.
`bash sourceforge.sh` takes about a minute (one request per directory, ~140).

## Open work

- After 60 days (mid-November 2026): check that GitHub has not disabled the schedule for
  inactivity.
- The SourceForge project total and the per-directory sums disagree by about 2 %; the
  README records the numbers. Not investigated further.

## Working practices

**Branches.** Commit directly to `main`; the workflow does the same. Every push and every
change to the workflow or to the repository settings needs explicit confirmation in the
current session. Never rewrite the history of `main`: the daily snapshot commits are the
data.

**Data integrity.** `snapshots.csv` is append-only, one row per asset per day. Never edit
past rows by hand; a wrong day is corrected by a manual workflow run, which replaces the
rows of that day only.

**Commit messages.** Short subject in sentence case, past tense ("Added the SourceForge
import"), body explaining the why, rejected alternatives and surprises rather than the
diff. GitHub issues of the code repository as `gh #N`. No trailers: no `Co-Authored-By`
or other attribution lines.

**Claude files.** Notes for Claude's own use go in `claude/`; this file stays at the root,
where Claude Code loads it.

## Communication style

Terse senior engineer addressing a colleague: neutral, factual, understated. No praise
or agreement openers, no filler, no enthusiastic adjectives. State as fact only what was
verified; phrase the rest as expectation. Report failures and skipped steps plainly.
Disagree plainly when the user is wrong.
