---
name: qa-reports-in-git-for-diffable-audit
description: "Commit QA / lint / hardening tool output files to git with predictable filenames so 'git diff <old>..<new> -- reports/' surfaces the QA delta between two states. Lets git handle the change-detection work; no external report store; audit trail travels with the code. Requires deterministic output (strip timestamps, absolute paths, machine-specific noise) so the diff is meaningful."
gate: 3
version: "1.0.0"
author: moonman81
tags: [qa, reports, git, audit-trail, hardening, deterministic-output, no-external-store]
depends_on:
  - pre-commit-as-sole-qa-gate
allowed-tools:
  - Read
  - Write
  - Bash
when_to_use: "Invoke when scoping how to record QA output for a project that has no external report store (S3, artefact server, CI-attached storage). Triggers: 'commit reports to git', 'diffable audit trail', 'predictable report filenames', 'no external storage', 'reports as data'."
---

# QA reports in git for diffable audit

## The idea

QA tools (cppcheck, flawfinder, clang-tidy, shellcheck, tokei,
sloccount, roundtrip test suites) produce text output. That output
is typically discarded after CI displays it, or stored in a
proprietary CI-artefact system, or dumped to an S3 bucket.

**Alternative:** commit the reports to git under predictable
filenames. Then:

```sh
git diff v0.1.0..v0.2.0 -- hardening/
```

shows exactly what QA differences occurred between releases. Git's
diff engine does the hard work; no external storage; the audit
trail travels with the code and can be reviewed offline.

## The layout

```
hardening/
├── COVERAGE-MATRIX.md            (curated — mapping to CWE/OWASP/etc)
├── README.md
├── format-string-audit/
│   ├── audit.sh
│   ├── clang-scan.sh
│   ├── report.txt                  ← generated, committed
│   └── clang-scan-report.txt       ← generated, committed
├── fuzz-seeds/
│   ├── smoke-run.sh
│   ├── smoke-report.txt            ← generated, committed
│   └── <corpus dirs>/
├── lint-sweep/
│   ├── run.sh
│   ├── report-cppcheck.txt          ← generated, committed
│   ├── report-flawfinder.txt       ← generated, committed
│   ├── report-clang-tidy.txt       ← generated, committed
│   ├── report-splint.txt           ← generated, committed
│   ├── report-shellcheck.txt       ← generated, committed
│   ├── report-tokei.txt            ← generated, committed
│   ├── report-sloccount.txt        ← generated, committed
│   ├── report-codespell.txt        ← generated, committed
│   ├── report-shfmt.txt            ← generated, committed
│   ├── report-iwyu.txt             ← generated, committed
│   └── summary.txt                 ← generated, committed
├── roundtrip/
│   ├── roundtrip.sh
│   └── report.txt                  ← generated, committed
├── setuid-audit/
│   ├── audit.sh
│   └── report.txt                  ← generated, committed
└── static-analysis/
    ├── scan.sh
    └── scan-report.txt             ← generated, committed
```

## Predictable filenames

The rule is: **one canonical filename per report**. When the tool
re-runs, it overwrites in place. Never append a timestamp to the
filename. Never `report-2026-07-02.txt` — that produces N files
over time and defeats the diffable-audit purpose.

Filenames used in the Heirloom port:

- `report-<tool>.txt` — output from tool `<tool>`.
- `report.txt` — sole output when only one report per directory.
- `summary.txt` — cross-tool summary.

Filenames are documented once at the top of the wrapper script.

## Determinism discipline

For `git diff` to be **meaningful** between two runs, the output
must be **deterministic** — free of timestamps, absolute paths,
line numbers that depend on machine state, and other noise.

Rules for the wrapper scripts:

1. **Strip timestamps.** Do not embed `Date: ...` in the report
   header. If you must record when a run happened, record it in
   the commit message, not the report body.
2. **Use relative paths.** Not `/Users/moonman/Projects/...`. Use
   paths relative to the repo root.
3. **Sort where semantics allow.** cppcheck's output ordering can
   vary run-to-run; pipe through `sort -u` if the tool doesn't
   guarantee stable ordering.
4. **Fix seed for randomised tools.** For fuzz-seed corpora or
   randomised static analysers, pin the seed.
5. **Do not embed machine-specific version strings.** "compiler
   version 21.0.0..." is a semantic version fine; "on macOS
   26.4.1" is machine-specific and out of place.

## Workflow

```sh
# 1. Contributor edits code
$ git commit -m "fix ..."          # pre-commit fast tier runs

# 2. Before tag / release
$ pre-commit run --hook-stage manual --all-files   # regenerates all reports

# 3. Reports have changed → commit them alongside code changes
$ git add hardening/
$ git commit -m "qa: regenerate hardening reports for v0.2.0"

# 4. Tag
$ git tag -a v0.2.0 -m "..."
```

Now `git diff v0.1.0..v0.2.0 -- hardening/` shows precisely what
changed in the QA posture between the two releases.

## What NOT to commit

- **Binaries.** Never commit sanitiser-instrumented `.o` files or
  built binaries. Reports only.
- **Machine-specific paths.** If a report contains
  `/Users/<name>/`, sanitise before committing.
- **Very large binary reports.** Some flawfinder runs produce
  large output (1-2 MB). That's fine to commit — git handles
  text well.

## Anti-pattern: `git ignore` reports

The most common failure mode: someone adds `hardening/**/*.txt` to
`.gitignore` because "generated files shouldn't be in git". This
throws away the entire diffable-audit story. Add a comment in
`.gitignore` telling future readers **not** to add these files.

Example from the Heirloom workspace repo:

```gitignore
# ... build artefacts ...

# NOTE: hardening/**/report-*.txt are DELIBERATELY tracked. Do not
# add them to this .gitignore. Their point is that `git diff` between
# release tags surfaces the QA delta.
```

## When the reports diverge

If two contributors regenerate reports and get different output:

1. Investigate the cause (different tool versions? machine state?
   non-determinism in the tool?).
2. Pin the tool versions via `pre-commit`'s `rev:` field.
3. If the tool is inherently non-deterministic, document that
   the report is a "best-effort audit" not a "reproducible
   witness".

## References

- `heirloom-workspace-darwin/hardening/` — worked example.
- <https://pre-commit.com> — enforcement mechanism.
