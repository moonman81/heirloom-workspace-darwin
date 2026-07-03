# TREE — Heirloom Darwin Port universe map

The Heirloom Darwin port comprises **nine** repos under the GitHub
organisation `moonman81`. This document is the map.

> **Not authoritative.** Every repo carries its own `NOTICE.md`
> disclaiming authoritative-source status. This TREE is the
> orientation layer.

## Repo table

| Repo                                    | Kind          | Content                                                | Size  |
| :-------------------------------------- | :------------ | :----------------------------------------------------- | ----: |
| `moonman81/heirloom-sh-darwin`          | port + source | Ritter's Bourne shell source + Darwin patches          |  5 MB |
| `moonman81/heirloom-devtools-darwin`    | port + source | make, sccs, yacc, lex, m4 source + Darwin patches      | 40 MB |
| `moonman81/heirloom-toolchest-darwin`   | port + source | ~110 SVR4/POSIX utilities + Darwin patches             | 50 MB |
| `moonman81/heirloom-doctools-darwin`    | port + source | troff/eqn/tbl/pic/grap/refer source + Darwin patches   | 20 MB |
| `moonman81/heirloom-pkgtools-darwin`    | port + source | pkgadd/pkgrm/pkgchk source + Darwin patches            | 15 MB |
| `moonman81/heirloom-workspace-darwin`   | workspace     | this repo — ALM, hardening, cross-reports, TREE, PORT.md | 5 MB |
| `moonman81/heirloom-vi-darwin`          | scaffold      | Ritter's ex/vi Darwin patches; source NOT bundled      |  1 MB |
| `moonman81/heirloom-citations-darwin`   | reference     | Bell Labs CSTRs, BSTJ 1978, K&R 1977 draft, etc.       | 105 MB |
| `moonman81/heirloom-ancestors-darwin`   | reference     | Manifests + notes for V7, 32V, DWB 1.0, PWB, PCC, BSDs |  1 MB |

## Dependency + reference graph

```
┌─────────────────────────────────────────────────────┐
│  heirloom-workspace-darwin (this)                   │
│    ALM Makefile + top-level driver                  │
│    hardening/ coverage matrix                       │
│    PORT.md decision record                          │
└──┬───────┬──────────┬───────────┬─────────────┬──────┘
   │       │          │           │             │
   ▼       ▼          ▼           ▼             ▼
┌──┐  ┌────┐  ┌────────┐  ┌────────┐  ┌──────────┐
│sh│  │dev │  │toolchest│  │doctools│  │pkgtools │
│  │  │tools│  │        │  │        │  │         │
└──┘  └────┘  └────────┘  └────────┘  └──────────┘
  │      │        │            │            │
  └──────┴────────┴────────────┴────────────┘
                    │  cites (via BIBLIOGRAPHY.md)
                    ▼
             ┌──────────────────────────┐
             │ heirloom-citations-darwin│
             │  CSTRs, BSTJ, books      │
             └──────────────────────────┘
                    │  descends from (via PROVENANCE.md)
                    ▼
             ┌──────────────────────────┐
             │ heirloom-ancestors-darwin│
             │  Manifests for V7, 32V,  │
             │  DWB, PWB, PCC, BSDs     │
             └──────────────────────────┘

                    heirloom-vi-darwin
                    (parallel scaffold — Ritter's ex/vi
                     patches-only; source NOT bundled;
                     related to but not part of the five
                     Heirloom packages)
```

## Package personalities (the modality axis)

Each installed binary in the five code repos supports six personality
variants:

| Directory                      | Variant name    | Behaviour       |
| :----------------------------- | :-------------- | :-------------- |
| `$PREFIX/bin/<tool>`           | `default`       | SVID3           |
| `$PREFIX/bin/posix/<tool>`     | `posix`         | POSIX/SUS       |
| `$PREFIX/bin/posix2001/<tool>` | `posix2001`     | POSIX-2001/SUS3 |
| `$PREFIX/bin/s42/<tool>`       | `s42`           | SVID4 subset    |
| `$PREFIX/ucb/<tool>`           | `ucb`           | UCB / BSD       |
| `$PREFIX/ccs/bin/<tool>`       | `ccs`           | Compiler Suite  |

Every binary honours `--variant=<name>`, `HEIRLOOM_VARIANT=<name>`,
`HEIRLOOM_DIALECT=<name>` at invocation time; see
`man 7 heirloom-modality` after install.

## Install layout under $PREFIX (default /opt/heirloom)

```
/opt/heirloom/
├── bin/                       # 157 default (SVID3) binaries + symlinks
│   ├── posix/                 #  34 POSIX/SUS variants
│   ├── posix2001/             #  12 POSIX-2001/SUS3 variants
│   └── s42/                   #   7 SVID4-subset variants
├── ucb/                       #  15 UCB/BSD variants + 18 symlinks
├── ccs/bin/                   #  19 CCS binaries (make, yacc, m4, sccs)
├── sadm/install/bin/          #   3 pkg admin helpers
├── share/
│   ├── man/5man/              # 216 man pages
│   └── info/heirloom.info     # Info-format guide
└── src/                       # (optional) source checkout of the 6 code repos
```

Total: 247 installed executables + 107 symlinks + 216 man pages + 1 info file.

## Contribution flow

1. Fork the specific repo you want to touch (each is independent).
2. Follow that repo's `CONTRIBUTING.md`.
3. Local QA via `.pre-commit-config.yaml`; no GitHub Actions budget.
4. Submit PR to `main`; maintainer merges after human review.

## When something is not authoritative

Every one of the nine repos disclaims authoritative-source status.
For a question of Heirloom canonical behaviour, cite:

- The upstream Heirloom Project tarballs: <http://heirloom.sourceforge.net>
- (Or, for a foundational Bell Labs / BSD tool the port descends from,
  the CSTR + book primary sources in `heirloom-citations-darwin`.)

For a question of Darwin-port-specific behaviour, cite the code repo
(`moonman81/heirloom-*-darwin`) that contains the fix.
