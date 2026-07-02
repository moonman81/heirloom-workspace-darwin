# Changelog

All notable changes to this Heirloom Darwin port **workspace** repository
are documented here, per [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
v1.1.0 with dates in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)
(`YYYY-MM-DD`).

The workspace repo carries the **top-level Makefile driver**, the
**PORT.md decisions record**, and the **hardening/ quality-gate suite**.
Per-package source lives in the 5 companion repos linked in `README.md`.

The hardening/ directory tracks pre-commit-generated QA reports **in git**
so that `git diff v0.1.0..v0.2.0 -- hardening/` shows the QA delta
between releases. Filenames are predictable
(`report-<tool>.txt`, `summary.txt`) — re-running
`pre-commit run --hook-stage manual --all-files` overwrites in place.

## [Unreleased]

_No changes since 0.1.0._

## [0.1.0] — 2026-07-02

Initial public release of the Heirloom Darwin port workspace.

### Added

- Top-level `Makefile` — phase-driven build (phase1..phase5, world,
  clean) across the 5 per-package repos.
- `PORT.md` — decisions record, project-wide constraints
  (legacy-proof + future-proof + no-CI QA discipline), per-package
  deviation register, future-configurability register.
- `hardening/` — 6-slice quality-gate suite:
  - `roundtrip/` — cpio × 3 formats, tar × 2 formats, SCCS
    admin/get/prs, SVR4 pkgparam, awk, ISO 8601 date. 10/10 pass.
  - `format-string-audit/` — clang `-Wformat-security` scan.
    Post-fix report is clean.
  - `setuid-audit/` — enumerate suid/sgid, cross-check intent,
    verify dependency trust + @rpath entries.
  - `static-analysis/` — ASan+UBSan build of cpio + round-trip.
    Zero runtime findings.
  - `fuzz-seeds/` — 20+ seed inputs across nawk, oawk, bc, dc, ed,
    sed, calendar, expr, cpio-headers, tar-headers.
  - `lint-sweep/` — 17-tool sweep (cppcheck, splint, flawfinder,
    clang-tidy, clang-format, iwyu, uncrustify, astyle, codespell,
    cpplint, shellcheck, shfmt, sloccount, tokei, bear, cscope,
    ccache).
- `hardening/COVERAGE-MATRIX.md` — maps each check to concrete
  CWE Top 25 / OWASP Top 10 / MITRE ATT&CK v14 / CAPEC 3.9 entries.

### Documentation

- `README.md`, `NOTICE.md`, `AI-DISCLOSURE.md` — upstream
  attribution, non-authoritative-source disclaimer, warranty
  disclaimer, honest AI-involvement account.
- `SECURITY.md`, `CONTRIBUTING.md` — reporting posture, PR
  discipline, pre-commit expectations, licence terms.
- `.pre-commit-config.yaml` — three-tier QA gate (pre-commit /
  pre-push / manual). No CI budget; local pre-commit is the enforcement
  point.

### Companion repos

- <https://github.com/moonman81/heirloom-sh-darwin>
- <https://github.com/moonman81/heirloom-devtools-darwin>
- <https://github.com/moonman81/heirloom-toolchest-darwin>
- <https://github.com/moonman81/heirloom-doctools-darwin>
- <https://github.com/moonman81/heirloom-pkgtools-darwin>

Each companion repo carries its own `CHANGELOG.md` with the per-package
change history.

## Links

- Upstream (authoritative): <http://heirloom.sourceforge.net>
- This workspace: <https://github.com/moonman81/heirloom-workspace-darwin>

<!--
Format:
  ## [X.Y.Z] — YYYY-MM-DD

  ### Added / Changed / Deprecated / Removed / Fixed / Security

Rules:
  * Newest release at top (below Unreleased).
  * Categories per Keep a Changelog.
  * Dates ISO 8601.
  * Reference git short-SHAs where useful.
-->
