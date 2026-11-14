# GROOVE download statistics

Download counts of the [GROOVE releases on GitHub](https://github.com/nl-utwente-groove/code/releases),
sampled daily. GitHub keeps only a cumulative counter per release asset, with no history
and no breakdown by country or operating system, so a SourceForge-style time series has
to be reconstructed by sampling the counters and differencing the samples. The design is
recorded in the code repository, `claude/download-stats.md`.

Older releases are on [SourceForge](https://sourceforge.net/projects/groove/files/stats/timeline),
which keeps its own statistics, including the country breakdown that GitHub cannot give;
its monthly totals since 2007 are imported here as well. Both files are rendered as one
chart and one table on the [downloads page](https://groove.cs.utwente.nl/downloads.html)
of the GROOVE website (`downloads.md` and `js/downloads.js` in the website repository).

## Data

`snapshots.csv` has one row per asset per day: `date,tag,asset,count`, where `count` is
the asset's cumulative download counter on that day (UTC). The workflow
`.github/workflows/collect.yml` appends the rows every night by running `collect.sh`;
a manual run of the workflow replaces the rows of the same day.

`sourceforge-monthly.csv` has one row per month per SourceForge directory:
`month,path,count`, with `month` as `YYYY-MM`, `path` the directory under
`sourceforge.net/projects/groove/files/` (a `release-x_y_z` directory, a `groove/x.y.z`
version directory, or `groove-docs`, `groove-samples`, `OldFiles` and the loose README
files), and months without downloads left out. The same workflow regenerates the whole
file every night by running `sourceforge.sh`: SourceForge keeps the complete history and
revises nothing, so there is nothing to append to. The script warns when the directories
do not add up to SourceForge's project total; on 2026-09-14 they did not (23,372 against
23,871), and the disagreement goes both ways (the version directories under `groove/`
sum to 157 more than SourceForge's own total of `groove/`, the top-level entries to 656
less than the project total less `groove/`), presumably from files moved or deleted over
the years. The per-directory numbers are the ones used.

`releases.csv` has one row per version: `version,date,source`, the publication date of
the release on GitHub (`github`, from the releases API, test releases included) or, for
the versions before 6.8.1, the date of its folder under `groove/` on SourceForge
(`sourceforge`). The folder date is the last modification, which for 2.0.0 and 6.0.0
lies after the first downloads (a month and half a year, respectively); the rest agree
with the download data. `releases.sh` regenerates the file in the same workflow.

No field of any of the files contains a comma or a quote.

The downloads of an asset on a day are the difference between its counts on consecutive
snapshot days. A negative difference means the asset was re-uploaded (the counter
restarts at zero); count the new value as the increment. An asset that disappears from
the API, such as one of a deleted test release, simply stops. Draft releases are
invisible to the workflow's token and never appear.

The counters count every GET of the asset, including CI runs, mirrors and scanners; a
handful of downloads per asset in the first day of a release is such traffic. Nothing is
filtered.

## Totals per release

The table is rewritten by `totals.sh` after every snapshot. Test releases (versions 99.x)
and the READ-ME text asset are left out; both stay in the data.

<!-- totals -->

As of 2026-11-14, cumulative since each release was published on GitHub.

| Release | bin | bin+doc | installers | yFiles add-on | total |
|---|---:|---:|---:|---:|---:|
| 7.7.1 | 2 | 2 | 5 | 0 | **9** |
| 7.7.0 | 1 | 1 | 5 | 0 | **7** |
| 7.6.1 | 9 | 2 | 4 | 0 | **15** |
| 7.6.0 | 5 | 4 | 12 | 0 | **21** |
| 7.5.3 | 69 | 20 | 0 | 0 | **89** |
| 7.5.2 | 28 | 19 | 0 | 0 | **47** |
| 7.5.1 | 7 | 7 | 0 | 0 | **14** |
| 7.4.3 | 50 | 66 | 0 | 0 | **116** |
| 7.4.2 | 12 | 13 | 0 | 0 | **25** |
| 7.4.1 | 10 | 12 | 0 | 0 | **22** |
| 7.4.0 | 12 | 9 | 0 | 0 | **21** |
| 7.3.1 | 19 | 11 | 0 | 0 | **30** |
| 7.3.0 | 15 | 15 | 0 | 0 | **30** |
| 7.2.0 | 13 | 13 | 0 | 0 | **26** |
| 7.1.1 | 15 | 13 | 0 | 0 | **28** |
| 7.1.0 | 12 | 10 | 0 | 0 | **22** |
| 7.0.7 | 13 | 11 | 0 | 0 | **24** |
| 7.0.6 | 18 | 12 | 0 | 0 | **30** |
| 7.0.2 | 29 | 33 | 0 | 0 | **62** |
| 7.0.1 | 17 | 22 | 0 | 0 | **39** |
| 7.0.0 | 10 | 12 | 0 | 0 | **22** |
| 6.9.4 | 17 | 13 | 0 | 0 | **30** |
| 6.9.3 | 15 | 14 | 0 | 0 | **29** |
| 6.9.2 | 11 | 11 | 0 | 0 | **22** |
| 6.9.0 | 15 | 14 | 0 | 0 | **29** |
| 6.8.4 | 14 | 14 | 0 | 0 | **28** |
| 6.8.3 | 14 | 13 | 0 | 0 | **27** |
| 6.8.2 | 11 | 10 | 0 | 0 | **21** |
| 6.8.1 | 36 | 40 | 0 | 0 | **76** |
| 6.8.0 | 22 | 15 | 0 | 0 | **37** |
| **all** | 521 | 451 | 26 | 0 | **998** |

<!-- /totals -->

## Maintenance

GitHub disables scheduled workflows in a repository without activity for 60 days. The
workflow's own daily commits are expected to count as activity; if the schedule is found
disabled, re-enable it on the Actions tab and consider a `workflow_dispatch` from a cron
elsewhere.
