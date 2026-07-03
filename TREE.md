# TREE — Heirloom Darwin Port universe map

The Heirloom Darwin port comprises **twelve** repos under the GitHub
organisation `moonman81`. This document is the map.

> **Not authoritative.** Every repo carries its own `NOTICE.md`
> disclaiming authoritative-source status. This TREE is the
> orientation layer.

## Repo table

| Repo                                    | Kind          | Content                                                | Size    |
| :-------------------------------------- | :------------ | :----------------------------------------------------- | ------: |
| `moonman81/heirloom-sh-darwin`          | code          | Ritter's Bourne shell source + Darwin patches          | 5 MB    |
| `moonman81/heirloom-devtools-darwin`    | code          | make, sccs, yacc, lex, m4 + Darwin patches             | 40 MB   |
| `moonman81/heirloom-toolchest-darwin`   | code          | ~110 SVR4/POSIX utilities + Darwin patches             | 50 MB   |
| `moonman81/heirloom-doctools-darwin`    | code          | troff/eqn/tbl/pic/grap/refer + Darwin patches          | 20 MB   |
| `moonman81/heirloom-pkgtools-darwin`    | code          | pkgadd/pkgrm/pkgchk + OpenSSL 3.x + PQ ready           | 15 MB   |
| `moonman81/heirloom-workspace-darwin`   | workspace     | this repo — ALM, hardening, PORT.md, TREE, substrate   | 10 MB   |
| `moonman81/heirloom-vi-darwin`          | scaffold      | Ritter's ex/vi Darwin patches; source NOT bundled      | 1 MB    |
| `moonman81/heirloom-citations-darwin`   | reference     | CSTRs + BSTJ + K&R draft + papers + theses             | 355 MB  |
| `moonman81/heirloom-ancestors-darwin`   | reference     | 21 manifests: V7, 32V, DWB, PWB, PCC, 1-4BSD, MERT, etc | 1 MB   |
| `moonman81/heirloom-manuals-darwin`     | reference     | UNIX/32V bundled + MERT samples + Unix 4.0 index       | 250 MB  |
| `moonman81/heirloom-oralhistory-darwin` | reference     | 13 Bell Labs oral-history interviews (Mahoney)         | 1 MB    |
| `moonman81/heirloom-tests-darwin`       | scaffold      | Apout-driven live comparison harness (Apout deferred)  | 1 MB    |

## Dependency + reference graph

```
┌─────────────────────────────────────────────────────┐
│  heirloom-workspace-darwin                          │
│    ALM Makefile + top-level driver                  │
│    hardening/ coverage matrix                       │
│    PORT.md decision record                          │
│    substrate/ N3 ontology + SPARQL queries          │
└──┬───────┬──────────┬───────────┬─────────────┬──────┘
   │       │          │           │             │
   ▼       ▼          ▼           ▼             ▼
┌──┐  ┌────┐  ┌────────┐  ┌────────┐  ┌──────────┐
│sh│  │dev │  │toolchest│  │doctools│  │pkgtools │
│  │  │tools│  │        │  │        │  │         │
└──┘  └────┘  └────────┘  └────────┘  └──────────┘
  │      │        │            │            │
  └──────┴────────┴────────────┴────────────┘
                    │  cites (BIBLIOGRAPHY.md)
                    ▼
             ┌──────────────────────────┐    ┌──────────────────────┐
             │ heirloom-citations-darwin│───┤ heirloom-manuals-    │
             │  90 primary-source PDFs  │    │ darwin (~2.8 GB tree)│
             └──────────────────────────┘    └──────────────────────┘
                    │  descends from                │
                    ▼                                ▼
             ┌──────────────────────────┐    ┌──────────────────────┐
             │ heirloom-ancestors-      │───┤ heirloom-oralhistory-│
             │ darwin (21 manifests)    │    │ darwin (13 interviews)│
             └──────────────────────────┘    └──────────────────────┘
                                                    │
                                                    ▼
                                          ┌────────────────────┐
                                          │ heirloom-tests-    │
                                          │ darwin (harness)   │
                                          └────────────────────┘

    heirloom-vi-darwin (parallel scaffold — Ritter's ex/vi patches
                        only; source NOT bundled; related to but not
                        part of the five Heirloom code packages)
```

## Personality variants (the modality axis)

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

## Install layout under `$PREFIX` (default `/opt/heirloom`)

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
└── src/                       # (optional) source checkout of code repos
```

Total: 247 installed executables + 107 symlinks + 216 man pages + 1 info file.

## Machine-readable universe

The workspace ships a Notation3 substrate at `substrate/*.n3` that
models this whole tree as an ontology. Query with SPARQL:

```sh
cd substrate/
arq --data=00-ontology.n3 --data=01-signatures.n3 --data=02-models.n3 \
    --query=queries.sparql
```

See `substrate/README.md` for details.

## Future work (documented but not executed)

These are TIER-2 / TIER-3 opportunities from
`qa-reports/corpus-inspiration-2026-07-03.md` that were surveyed but
not executed in the initial extension pass:

- **AUUGN mirror** (577 MB Australian Unix Users Group Newsletter) —
  probably index-only via `heirloom-citations-darwin`.
- **V8/V9/V10 patches-only scaffolds** — each 3-5 days.
- **Taylor UUCP full Darwin port** — 3-4 days for a
  `heirloom-uucp-darwin` code repo.
- **Cards + Recordings mirrors** — cultural content, lower value/
  effort ratio.
- **UNSW AUSAM 22-tape series** — deeper ancestor-manifests pass.
- **Apout Darwin arm64 port itself** — enables `heirloom-tests-darwin`
  to actually run; 5-7 days.

Full inventory + rationale: `qa-reports/corpus-inspiration-2026-07-03.md`
in this repo.

## When something is not authoritative

Every one of the twelve repos disclaims authoritative-source status.
For a question of Heirloom canonical behaviour, cite:

- The upstream Heirloom Project tarballs: <http://heirloom.sourceforge.net>
- (Or, for a foundational Bell Labs / BSD tool the port descends from,
  the CSTR + book primary sources in `heirloom-citations-darwin`.)

For a question of Darwin-port-specific behaviour, cite the code repo
(`moonman81/heirloom-*-darwin`) that contains the fix.
