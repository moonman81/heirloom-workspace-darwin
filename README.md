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

## Modality — version, variant, dialect

Every installed binary in this port honours a shared help / version /
variant / dialect flag set:

- `--help`, `--usage`, `-H`  → invoke `man(1)` on this tool
- `--version`, `-V`          → port banner (built variant + active variant)
- `--variants`               → list installed personality variants
- `--describe-modality`      → full modality matrix
- `--variant=<name>`, `HEIRLOOM_VARIANT=<name>`, `HEIRLOOM_DIALECT=<name>`
  → re-exec the requested variant
- `HEIRLOOM_PORT_VERSION_REQ=<version>` → pin scripts to a port revision

Recognised variants: `default` (SVID3), `posix` (SUS), `posix2001`
(SUS3), `s42` (SVID4-subset), `ucb` (UCB/BSD), `ccs`.

Recognised dialects: `svid3`, `svr3`, `svr4`, `sysv`, `sysv3`, `posix`,
`sus`, `sus2`, `posix2001`, `sus3`, `s42`, `svid4`, `ucb`, `bsd`, `ccs`.

Full reference: `man 7 heirloom-modality`.

## Documentation entry points

| File               | Content                                                 |
| :----------------- | :------------------------------------------------------ |
| `README.md`        | this file                                               |
| `INSTALL.md`       | short-form install guide                                |
| `HOWTO.md`         | narrative install + use walkthrough                     |
| `PROVENANCE.md`    | chain of custody (Bell Labs → AT&T → Sun → Ritter → …)  |
| `BIBLIOGRAPHY.md`  | references (papers, standards, historical texts)        |
| `NOTICE.md`        | licence patchwork + non-authoritative disclaimer        |
| `AI-DISCLOSURE.md` | degree of AI involvement in port authorship             |
| `GRATITUDE.md`     | acknowledgements                                        |
| `CHANGELOG.md`     | port revision history                                   |
| `SECURITY.md`      | vulnerability reporting posture                         |
| `CONTRIBUTING.md`  | how to contribute a patch                               |
| `skills/`          | Heirloom-port skills authored from this work            |
| `patches/`         | git-format-patch series (code repos only)               |
| `man/man7/`        | port-specific man pages (`heirloom-port-*.7`)           |
| `qa-reports/`      | committed QA snapshots (in workspace repo)              |

Every directory in this repo also carries its own `README.md`
describing its purpose in one page.

## Info-format overview

The port ships an Info document at
`/opt/heirloom/share/info/heirloom.info`. Read it with:

```sh
info heirloom
```

## Related repos

- <https://github.com/moonman81/heirloom-sh-darwin>
- <https://github.com/moonman81/heirloom-devtools-darwin>
- <https://github.com/moonman81/heirloom-toolchest-darwin>
- <https://github.com/moonman81/heirloom-doctools-darwin>
- <https://github.com/moonman81/heirloom-pkgtools-darwin>
- <https://github.com/moonman81/heirloom-workspace-darwin>
