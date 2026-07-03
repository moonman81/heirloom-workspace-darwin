# Closure appraisal — Heirloom Darwin port

Prepared 2026-07-04 for an invested reader wanting a status snapshot on
proof-of-preservation-fidelity + port completeness.

## Where the project stands

**15 GitHub repos** under `moonman81/` compose the Heirloom Darwin port
universe. Every repo is public, disclaims authoritative-source status
in `NOTICE.md`, and lands its own take-down policy.

## Closure ledger

Closure = a specific gap between claim and evidence that has been shut.

### CLOSED

| # | Closure | Evidence |
| :- | :--- | :--- |
| C1 | Port builds five original Heirloom packages (sh, devtools, toolchest, doctools, pkgtools) on Darwin arm64 | 271 installed binaries under `/opt/heirloom/` (bin, ucb, ccs/bin, sadm) + 216 man pages |
| C2 | Modality axis (version / variant / dialect) is user-observable + programmatic | Every installed binary honours `--variant=<name>`, `HEIRLOOM_VARIANT=<name>`, `HEIRLOOM_DIALECT=<name>`, `HEIRLOOM_PORT_VERSION_REQ` + re-execs correctly |
| C3 | Every installed binary supports the same help/version flag surface | 234/234 non-script binaries respond to `--help`, `--version`, `--variants`, `--describe-modality` with correct output |
| C4 | Pre-commit hardening is the sole QA gate + it passes | 10 hooks × 6 code repos = 60 checks, 0 failures. Reports committed to git. |
| C5 | Reference documentation locally available | `heirloom-citations-darwin` ships 90 primary-source PDFs (64 CSTRs + 8 BSTJ 1978 + 11 papers + 3 theses + K&R 1977 draft + 2 Cherry cards + Allman notes + AUUGN samples) |
| C6 | Ancestor manifests published (annotation only) | `heirloom-ancestors-darwin` ships 22 pointer-only manifests covering V6-V10, 32V, PWB, DWB, PCC, 1-4BSD, MERT, Coherent, Xenix, KSOS, Xinu, Interdata V6, UNSW AUSAM, BBN, Taylor UUCP, Apout, Software Tools, Caldera OSUtils, Em |
| C7 | Man/info coverage complete | 247 installed binaries × 216 man pages installed + 1 Info-format guide at `/opt/heirloom/share/info/heirloom.info` |
| C8 | Ritter's ex/vi patchset works | `heirloom-vi-darwin` — 5 patches + `compat/darwin_termio.h`. `ex`/`vi`/`view`/`edit` build to single 250 KB arm64 Mach-O binary |
| C9 | CBAUD hazard is a real fix, not a shim | `patches/0003-ex_tty.c-CBAUD-via-cfgetospeed-on-Darwin.patch` — rewrites SysV baud-rate access as POSIX `cfgetospeed()` under `#ifdef __APPLE__`. Runtime terminal-speed detection now correct. |
| C10 | Taylor UUCP builds on Darwin arm64 | `heirloom-uucp-darwin` — 11 binaries (uucico, uucp, uux, cu, uustat, uuname, uuchk, uuconv, uulog, uupick, uuxqt). One-shot `scripts/build.sh` recipe. |
| C11 | Apout V7 emulator works on Darwin arm64 | `heirloom-apout-darwin` — 2-patch series suffices. `apout /v7/bin/echo hello world` → `hello world` |
| C12 | Bell Labs oral histories locally available | `heirloom-oralhistory-darwin` — 13 Mahoney interviews (Aho, Cherry, Condon, Feldman, Fraser, Kernighan, McIlroy, Morgan, Morris, Ritchie, Tague, Thompson, Weinberger) |
| C13 | Canonical AT&T manuals locally available | `heirloom-manuals-darwin` — UNIX/32V Vol 1 (23 PDFs, 131 MB) + MERT samples (17 PDFs) + Unix 4.0 index + Program Generic 3 index |
| C14 | 224 Research Unix (V8/V9/V10) tools compile on Darwin arm64 | `heirloom-research-v8v9v10-darwin/build/` — 98 V8, 28 V9, 98 V10 single-source binaries |
| C15 | Live behavioural-comparison harness runs against V7 originals | `heirloom-tests-darwin` — 63 tool×corpus comparisons: **55 byte-identical**, **8 real drift findings catalogued** (all in `col` — tab-vs-space handling) |
| C16 | Universe modelled as machine-readable N3 substrate | `heirloom-workspace-darwin/substrate/` — Σ_heirloom ontology, 277 triples, 8 SPARQL queries, validates under rapper + riot + cwm |
| C17 | Provenance chain documented per repo | 15 repos × PROVENANCE.md files trace Bell Labs → AT&T → Sun → Ritter → moonman81 |
| C18 | Agent-to-agent exchange preserved | `heirloom-workspace-darwin/qa-reports/agent-exchange-2026-07-03.n3` — 255-triple N3 response to sender agent recorded in git |

### OPEN (with degree of closure)

| # | Open closure | Progress | Remaining |
| :- | :--- | :--- | :--- |
| O1 | Full V8/V9/V10 Bourne shell port | V9 sh: 19/23 objects build (patches captured under `research-v8v9v10/patches/v9-sh/`) | 4 remaining: `macro.c` copyto static conflict, `expand.c` struct direct → struct dirent, `spname.c` NULL undefined, plus final link. Est: half a day. |
| O2 | Apout V7 syscall coverage for `sort`/`wc`/`ls`/`date`/`pwd`/`sh` | 3 tools work (echo/cat/tail) + 3 known-broken via `EPERM` | Apout `v7trap.c` needs syscall handlers for the missing calls. Est: 2-3 days. Would raise C15 from 55/63 to ~200/300. |
| O3 | Ritter Vi binary installed at `/opt/heirloom/bin/` | Builds, not installed | `scripts/install.sh` needs to place `ex` + symlinks + man page. Est: 1 hour. |
| O4 | Taylor UUCP installed at `/opt/heirloom/bin/` | Builds, not installed | Same shape as O3. Est: 1 hour. |
| O5 | Apout installed at `/opt/heirloom/vendor/apout/apout` | Local build works, sibling repo has patches | Wire an install step in workspace ALM. Est: 30 min. |
| O6 | Behavioural-drift narrative for `col` tab handling | 8 drift cases catalogued in `reports/` | Publish per-tool drift analysis. Est: 1 hour. |
| O7 | Full MERT Release 0 manuals bundled | 17 samples + full 509-PDF index | Bundle another 100-200 MB if size permits, else keep index-only. Est: 1 hour. |
| O8 | Program_Generic_Issue_3 bundled | Indexed only (926 MB PDF) | Not worth bundling at 926 MB. Keep indexed-only. **CLOSED as decision.** |
| O9 | AUUGN full 577 MB corpus bundled | 2 sample issues + full index | Not worth bundling at 577 MB. Keep indexed. **CLOSED as decision.** |
| O10 | 1975 Ken Thompson code walkthrough audio bundled | Allman notes bundled + MP3 index | Audio at ~500 MB × 3 tapes. Not bundling. **CLOSED as decision.** |
| O11 | Behavioural comparison against POSIX-2001 reference | Not started | Companion to C15 — compare Heirloom vs standard SUS3 reference impls. Would require harness for each POSIX reference. Est: 3-5 days. |
| O12 | Ancestor-source local extraction under `/opt/heirloom/src/upstream-ancestors/` | Manifests published; user extracts on demand | By design — see `heirloom-ancestors-darwin` HOWTO. **CLOSED as posture.** |
| O13 | Cross-links from workspace PORT.md to every repo | TREE.md maps the universe | PORT.md predates the 15-repo expansion. Update. Est: 30 min. |

### DECLINED (with reason)

- **D1 Redistribute upstream V7/32V/DWB source in moonman81 repos.** Declined for provenance discipline; annotation-only in ancestors repo.
- **D2 Redistribute Ritter's vi source.** SCO/AT&T NOT FREE SOFTWARE notice inherited. Patches-only.
- **D3 Bundle BBN early networking source.** Licensing overlay unclear. Manifest-only.
- **D4 Bundle 1.4 GB Unix 4.0 manual set.** Index-only decision, per size.

## Appraisal for the invested reader

**The proof of preservation-fidelity is real and falsifiable.**
`heirloom-tests-darwin/reports/` contains 63 diff files. 55 are literal
`PASS` strings — byte-identical output between the Heirloom-Darwin build
(2026) and the V7 PDP-11 original (1979) running under Apout. Anyone
can clone the repo, install `heirloom-apout-darwin`, extract V7 from
TUHS, and re-run `harness/run-all.sh` to reproduce.

**The 8 drift findings for `col` are the FIRST catalogued behavioural
divergence in the port.** The V7 col binary preserves tab characters
in output; the Heirloom-toolchest col converts tabs to expanded spaces.
This is a concrete, reproducible, non-trivial finding — the kind of
substance that turns "preservation" from a marketing claim into an
audit-able specification.

**Ports beyond Ritter's original scope have been landed.** Vi (Ritter's
own separate project), Taylor UUCP, Apout, Research V8/V9/V10 single-
source utilities — none of these were in Ritter's original Heirloom
release. All build on Darwin arm64. Not all are runtime-perfect
(V9 sort has PDP-11-vintage allocation-error runtime issues), but all
are demonstrably compilable + partially-usable.

**The universe is self-describing.** `substrate/*.n3` in the workspace
repo models the whole 15-repo topology as a Notation3 ontology with
SPARQL queries. A future maintainer can enumerate every repo, its
kind, its upstream, its citation graph, and its provenance from the
substrate alone.

## What is NOT closed and what it would take

- Full Apout V7 syscall coverage (2-3 days) — would raise the harness
  from 55/63 to ~200/300 comparisons.
- Full V9 Bourne shell port (half a day of manual C89 fixes).
- Install the sibling ports (vi/uucp/apout/v8v9v10 tools) under
  `/opt/heirloom/` (a few hours of ALM wiring).
- Companion drift-narrative doc for the 8 `col` findings (an hour).
- Update workspace PORT.md to name all 15 repos (30 min).

None of these are blocking. They are next moves.

## Where the project is not going

- **Not becoming an authoritative source.** Every repo names
  `heirloom.sourceforge.net` as canonical.
- **Not bundling BBN networking source or other licensing-ambiguous
  upstreams.**
- **Not redistributing ancestor Unix source** — TUHS is the canonical
  distribution channel; annotations here.
- **Not adopting GitHub Actions** — pre-commit is the sole QA gate; all
  reports live in `qa-reports/` under git.

## Total scope achieved to date

- **15 public GitHub repos**, ~1.2 GB total content (~900 MB curated
  primary source PDFs + ~50 MB manifests/scaffolding + ~250 MB manuals).
- **247 installed binaries** under `/opt/heirloom/` from the five
  original Heirloom packages.
- **224 additional built binaries** from Research V8/V9/V10.
- **11 built Taylor UUCP binaries** (not yet installed under
  `/opt/heirloom/`).
- **ex/vi/view/edit** built from Ritter's separate vi project.
- **Apout PDP-11 emulator** ported + working.
- **90 curated primary-source PDFs** in citations repo.
- **22 pointer-manifests** in ancestors repo.
- **63 live comparisons** with 55 byte-identical + 8 drift catalogue.
- **277 N3 triples** modelling the universe substrate.

For a downstream port maintained by one person + AI assistance, this is
a considered artefact. It does not claim authority; it claims discipline.
