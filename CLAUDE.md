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
releases, re-uploaded assets). The design record is `claude/download-stats.md` in the code
repository (on branch `download-stats-design` until merged).

The scripts run under bash with the `gh` CLI and GNU awk/sed/sort; they must keep working
on `ubuntu-latest` and on Windows Git Bash. Run them locally before changing them:
`bash collect.sh && bash totals.sh` on a clean tree, then inspect `git diff`. A local run
uses the developer's token and therefore sees draft releases that the workflow's token
does not; do not commit such a snapshot.

## Open work

- One-off import of the SourceForge monthly totals since 2007 into
  `sourceforge-monthly.csv` (SourceForge stats JSON:
  `https://sourceforge.net/projects/groove/files/stats/json?start_date=…&end_date=…`,
  per-directory under `files/<path>/stats/json`), with the script kept next to the
  collector so it can be rerun.
- A page on the website (`nl-utwente-groove/nl-utwente-groove.github.io`, Jekyll) that
  fetches `snapshots.csv` from `raw.githubusercontent.com` and renders a monthly chart
  stacked by asset kind plus the per-release table. Needs a checkout of the website
  repository; there is none locally yet.
- After 60 days: check that GitHub has not disabled the schedule for inactivity.

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
