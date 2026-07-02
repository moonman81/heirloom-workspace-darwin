# Heirloom Darwin port — workspace

Top-level driver + decisions record + hardening suite for a
downstream Darwin (macOS 26 arm64) port of Gunnar Ritter's Heirloom
Project. **Not** an original work; **not** an authoritative source.

See `NOTICE.md` + `AI-DISCLOSURE.md` for full disclosure.

## Companion per-package repos

Each Heirloom package is published as its own repo, with the pristine
upstream tarball as commit 1 and the Darwin port patches as subsequent
commits:

- **sh** (Bourne shell) — <https://github.com/moonman81/heirloom-sh-darwin>
- **devtools** (yacc, lex, m4, make, sccs) — <https://github.com/moonman81/heirloom-devtools-darwin>
- **toolchest** (~110 core utilities) — <https://github.com/moonman81/heirloom-toolchest-darwin>
- **doctools** (troff family) — <https://github.com/moonman81/heirloom-doctools-darwin>
- **pkgtools** (SVR4 pkg cmds) — <https://github.com/moonman81/heirloom-pkgtools-darwin>

## What this workspace contains

- `Makefile` — top-level phase-driver (`make phase1..phase5`, `make world`)
- `PORT.md` — decisions record, project-wide constraints, and per-package deviation register
- `hardening/` — Phase 6 + Phase 7 quality gates: legacy round-trip tests
  (cpio × 3 formats, tar × 2 formats, SCCS admin/get/prs, SVR4 pkgparam,
  awk, ISO 8601 date), format-string audit, setuid audit, ASan+UBSan
  static analysis, fuzz seed corpora + smoke runner, and a 17-tool
  lint sweep (cppcheck, splint, flawfinder, clang-tidy, clang-format,
  iwyu, uncrustify, astyle, codespell, cpplint, shellcheck, shfmt,
  sloccount, tokei, bear, cscope, ccache).
- `.cppcheck-suppress` — suppression rules for K&R-idiomatic warnings

## Building

```
make world      # builds + installs all 5 packages in phase order
make phase1     # sh only; likewise phase2..phase5
make -C hardening all   # run every quality gate
```

Prerequisites: Xcode 15+, Homebrew, openssl@3 via brew, all lint tools
via brew (see `hardening/lint-sweep/run.sh` for the exact list).

## Upstream (authoritative)

<http://heirloom.sourceforge.net> — Gunnar Ritter, `<gunnarr@acm.org>`.
Upstream unmaintained since 2008; SourceForge tarballs remain the
canonical reference.

## Warranty

**None.** As-is. No guarantee of originality, fitness, or safety. See
`NOTICE.md`.
