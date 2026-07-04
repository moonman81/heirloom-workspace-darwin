# Further inspiration — a systematic survey of the reduxed-sunsite corpus

An audit of what remains valuable in
`/Volumes/mirrors-reduxed/sunsite.icm.edu.pl` after the initial nine-repo
Heirloom Darwin universe was built.

Written for the `moonman81/heirloom-workspace-darwin` maintainer as a
menu of extension opportunities; each item is scoped, sized, and
scored for value-vs-effort so it can be picked up in isolation.

Compiled 2026-07-03 by the Heirloom port agent.

---

## Overall shape of what remains

The corpus is 12 GB. The initial extension covered:
- Applications: `Ritter_Vi`, `Documenters_Workbench`, `Awk_Grep`,
  `Typesetting`, `Portable_CC`, `Early_C_Compilers`, `Software_Tools`
  (Georgia Tech), `Em_Editor`, `TaylorUUCP`.
- Documentation: `TechReports/Bell_Labs/CSTRs` (64 PDFs bundled),
  selected `Papers/BSTJ/`, `Books+BookCDs/Draft-KandR-C-Book1977.pdf`,
  index-only for USG Library.
- Distributions: manifests for `Research/Henry_Spencer_v7`,
  `USDL/32V`, `USDL/bostic_pwb.tar.gz`, `UCB/{1BSD,2BSD,3BSD,4BSD}`,
  `Applications/Documenters_Workbench/dwb_1.0.tar.gz`.
- Tools: `Emulators/Apout` manifest.

The corpus is **48 UnixRelease instances** modelled in the substrate
(see `family_tree.md`). We covered ≈ 8–10 of them directly. **~40
remain**. Below is what to do with the rest.

---

# TIER-1 — high-value opportunities

## OPP-1  moonman81/heirloom-manuals-darwin — manual-page collection

**Size**: 2.8 GB (Documentation/Manuals/)
- `UNIX_32V_Version_1.0/` (131 MB, 23 PDFs) — 32V manual pages
- `Unix_4.0/` (1.4 GB, 66 PDFs) — SVR2/SVR3 vintage
- `MERT_Release_0/` (375 MB, 509 PDFs) — Multi-Environment Real-Time Unix
- `Program_Generic_Issue_3/` (926 MB, 1 PDF) — USG PG3 monolith

**What to build**: A companion repo that houses the CANONICAL
Bell Labs / AT&T manual-page PDFs at each Unix vintage, cross-
referenced against which `heirloom-*-darwin` tool inherits which
man page. E.g., the 32V Vol.1 `sh(1)` entry directly informs
`heirloom-sh-darwin/src/sh/sh.1`.

**Value: 85/100** — closes a huge citation gap; every code repo can
cite specific man-page pages.
**Effort**: 1 day (extraction + INDEX.md + cross-reference tables).
**Repo size**: 100–500 MB (curated subset) or 2.8 GB (full).
**Licensing**: PDF scans of AT&T-published manuals; TUHS takes them
down without argument on request.

## OPP-2  moonman81/heirloom-oralhistory-darwin — Bell Labs oral histories

**Size**: 21 MB (Documentation/OralHistory/)
- Interviews with **Aho, Cherry, Condon, Feldman, Fraser, Kernighan,
  McIlroy, Morgan** (transcripts + audio/EPUB).
- `unix_oral_history.mp3`, `unix_oral_history.epub`.

**What to build**: A small, tightly-curated repo that mirrors the
Computer History Museum's Unix oral-history transcripts. Every one
of these is quoted by name in `heirloom-workspace-darwin/GRATITUDE.md`.

**Value: 78/100** — deeply important primary source; not currently
locally available for the port's users.
**Effort**: 2 hours (verbatim mirror + INDEX with hyperlinks).
**Repo size**: ~25 MB.
**Licensing**: transcripts are CHM-copyright; ask CHM for permission
or link-only. Prefer the link-only shape.

## OPP-3  Extend heirloom-citations-darwin with the AUUGN back-issues

**Size**: 577 MB (Documentation/AUUGN/)
- Volumes 01.1 through 15.4+ of the Australian Unix Users Group
  Newsletter. Historically a primary community source, particularly
  for the ex/vi lineage and the UNSW AUSAM series.

**What to build**: `tech-reports/auugn/` under
`heirloom-citations-darwin`. Add a top-level `INDEX.md` naming which
tools each issue documents.

**Value: 72/100** — high for anyone tracing the AT&T→BSD→Australian
Unix branch; particularly important for `heirloom-vi-darwin`.
**Effort**: half a day.
**Repo size**: adds 577 MB — probably better indexed-only than bundled
(citations-darwin already at 105 MB).

## OPP-4  moonman81/heirloom-tests-darwin — live-comparison harness

**Size**: 20 MB (Tools/Emulators/Apout/) + harness code.
**Uses**: Apout (from `heirloom-ancestors-darwin` manifests) + V7 tape
(from user's own extraction).

**What to build**: A new companion repo containing a shell-driven
harness that:
```
for tool in ls cat sort tr uniq wc; do
  produce test-corpus > /tmp/in
  /opt/heirloom/bin/$tool < /tmp/in > /tmp/heirloom-out
  apout /opt/heirloom/upstream-ancestors/v7/usr/bin/$tool < /tmp/in > /tmp/v7-out
  diff -u /tmp/heirloom-out /tmp/v7-out > /tmp/reports/$tool.diff
done
publish /tmp/reports as behavioural-drift catalogue
```

Directly demonstrates the preservation-fidelity claim that Ritter's
Heirloom Project made in the first place.

**Value: 88/100** — novel research angle; the ONE artefact that
turns Heirloom's "preservation" claim from marketing into
falsifiable science.
**Effort**: **5-7 days** (Apout Darwin port is the crux; sender
agent estimated 3-5, my re-estimate is higher after seeing the K&R
vintage code).
**Repo size**: ~50 MB with a curated corpus.

---

# TIER-2 — meaningful opportunities

## OPP-5  Extend heirloom-ancestors-darwin with the missing V6 tapes

**Size**: modest — Distributions/Research/{Collinson_v6, Ken_Wellsch_v6,
Tim_Shoppa_v6, Utah_v4}/ (~50 MB total).

Currently ancestors-darwin has V7 manifest. V6 (1975) is the direct
ancestor of V7 and has FOUR independent donor tapes on TUHS. Adding
V6 manifests would close a lineage gap.

**Value: 60/100** — completes the Research V0-V10 ancestor coverage.
**Effort**: 2 hours (write 4 manifests analogous to V7.md).

## OPP-6  moonman81/heirloom-v8-v9-v10-darwin — later Research Unix ports

**Size**: modest — Distributions/Research/{Dan_Cross_v8, Dan_Cross_v10,
Norman_v9, Norman_v10}/.

Research Unix V8, V9, V10 were AT&T's post-V7 experimental branches
where **streams, sfio, WMc's shell (rc), and network transparency**
were prototyped. Bell Labs never publicly released them, but Warren
Toomey's TUHS-hosted tapes preserve them.

**What to build**: A patches-only-scaffold repo (same posture as
`heirloom-vi-darwin`) that lets users obtain the tape from TUHS
under their own reading and build V8-lineage tools on Darwin.

**Value: 65/100** — deep in research-Unix scholarship. Not
production-relevant.
**Effort**: 3-5 days per Unix version.

## OPP-7  moonman81/heirloom-mert-darwin — MERT preservation

**Size**: 375 MB (Documentation/Manuals/MERT_Release_0/, 509 PDFs).

MERT — Multi-Environment Real-Time — was Bell Labs' realtime port
of V6/V7 (early 1980s). Historically important; direct ancestor
of some SVR2 realtime work. The Manual Release 0 documentation is
comprehensive.

**What to build**: A documentation-only companion (like
`heirloom-citations-darwin`) that bundles or indexes the MERT
manuals. Genuinely rare — this material is only preserved at TUHS
and (partially) Bit Savers.

**Value: 55/100** — niche but genuinely rare.
**Effort**: 1 day (INDEX + naming + selection).

## OPP-8  Extend heirloom-citations-darwin with the specialised Papers/

Non-BSTJ papers currently NOT in citations-darwin (11 PDFs, ~10 MB):
- `Four_Generations_of_Portable_C_Compiler_DM_Kristol_19860609.pdf`
  — direct reference for the PCC lineage cited in devtools BIBLIOGRAPHY.
- `Interprocess_Communications_in_the_8th_Edition_Unix_Ritchie+Presotto_USENIX_SUMMER_19850612.pdf`
  — foundational IPC history.
- `Unix_Users_Talk_Notes_Jan73.pdf` — 1973 Bell Labs internal talk.
- `unix_cacm74.pdf` — Ritchie + Thompson CACM 1974 landmark paper.
- `lions_PCCpass2_jun1979.pdf` — Lions on PCC internals.
- `1eUnix_creation_restoration.pdf` — Reid Kellogg's V1 restoration
  writeup.

**Value: 70/100** — every one of these is directly cited by name
somewhere in the port's bibliography.
**Effort**: 30 minutes (`cp` into citations-darwin, extend INDEX.md).

## OPP-9  Extend heirloom-ancestors-darwin with alternative Unix implementations

Distributions/Other/ contains:
- `Coherent/` (220 MB) — Mark Williams' commercial V7 clone, later
  released open-source.
- `Xenix/` (small) — Microsoft/SCO's Unix.
- `KSOS/` — Kernelized Secure OS (Ford Aerospace, 1980s).
- `Xinu/` — Douglas Comer's teaching Unix.
- `V6on286/` — V6 port to Intel 286.
- `Interdata/` — V6 Interdata 7/32 port (Wollongong).

Plus DEC/Fred-Ultrix3, Sun (SunOS artefacts), IBM, UNSW (22 AUSAM tapes).

**Value: 55/100** — completes the ancestor-family map.
**Effort**: 1 day (10-15 short manifests).

## OPP-10  moonman81/heirloom-uucp-darwin — Taylor UUCP Darwin port

**Size**: 2.7 MB source (Applications/TaylorUUCP/).

Ian Taylor's free UUCP is a real port project (not scaffold-only).
GPL-covered so no licensing concerns. Would give Heirloom a full
historical Unix mail+news stack.

**Value: 60/100** — genuinely extends what Heirloom offers.
**Effort**: 3-4 days full Darwin port.

---

# TIER-3 — nice-to-have opportunities

## OPP-11  moonman81/heirloom-cards-darwin — reference cards + posters

**Size**: 98 MB (Documentation/Cards/).

Reference cards, quick-reference posters, teaching material —
much of it iconically Bell Labs typography.

**Value: 35/100** — cultural/aesthetic value; useful for teaching.
**Effort**: half a day.

## OPP-12  Extend heirloom-citations-darwin with theses

Documentation/Theses/:
- `LefflerSamuel_ImplementationOfCProgrammingLanguage_1981_thesis.pdf`
- `ShannonWilliam_DemandPagedUNIXSystem_1981_thesis.pdf`
- `Shamim_Sharfuddin_Pirzada-1988-PhD-Thesis.pdf`

Leffler's thesis (1981) — foundation of 4.1BSD C compiler; Shannon's
thesis (1981) — foundation of 4.2BSD paged VM.

**Value: 55/100** — significant primary sources for the C evolution
narrative.
**Effort**: 30 minutes.

## OPP-13  Extend heirloom-ancestors-darwin with Australian UNSW AUSAM

Distributions/UNSW/ contains 22 numbered AUSAM tapes (63 MB) — the
Australian University of New South Wales' extended Unix distribution
of the late 1970s/early 1980s. Historically important for early
regional Unix community formation and for the `sfio` predecessors.

**Value: 45/100** — niche.
**Effort**: half a day (22 short manifests + narrative).

## OPP-14  moonman81/heirloom-recordings-darwin — audio-video

Recordings/1975_Unix_Code_Walkthru/ — Eric Allman's own V6 tape +
notes from the CODE walkthrough. Ken Thompson's talks and other
audio recordings across the corpus.

**Value: 40/100** — rare artefact but not source material.
**Effort**: half a day (mirror + INDEX; audio files stay linked).

## OPP-15  Extend heirloom-workspace-darwin with a Σ_content-style N3 substrate

Model the whole 9-repo universe as an N3 ontology in the workspace.
Every code repo gets predicates for `derivedFrom`, `portOf`,
`citedBy`, `ancestorOf`, in the style of
`sunsite.icm.edu.pl/01-signatures.n3`. Then publish SPARQL queries
and a rendered TREE that the current TREE.md only sketches.

**Value: 80/100** — enables genuine machine-readable provenance,
matches the mirror's own discipline.
**Effort**: 2-3 days.

---

# TIER-4 — declined for principled reasons

## OPP-16  Redistribute upstream ancestor source (V7, 32V) in moonman81 repos

**Value: N/A** — declined. Rationale documented in
`heirloom-ancestors-darwin/README.md`: the provenance discipline
argues for annotation-only + pointer-to-TUHS, not bundling. Caldera
2002 grant covers this but the discipline of "point, do not bundle"
scales better across the ancestor universe (V6, V8-V10, MERT,
Coherent, etc. have different licensing situations).

## OPP-17  Redistribute Ritter's ritter_vi.tar.gz source

**Value: N/A** — declined. SCO/AT&T "NOT FREE SOFTWARE" notice
inherited from 2.11BSD ex/vi. Handled via patches-only
`heirloom-vi-darwin` scaffold.

## OPP-18  Redistribute BBN early-networking source (jnc_bbn.tar.gz)

**Value: N/A** — declined. BBN's TCP/IP work has its own licensing
overlay; unclear grant status. Point-at-TUHS is the safer discipline.

---

# Summary: menu of next moves

If picking exactly ONE next move, the ranked recommendations:

1. **OPP-1  heirloom-manuals-darwin** — closes the biggest citation
   gap in the whole universe (2.8 GB corpus, but a curated 500 MB
   subset is the sweet spot).
2. **OPP-4  heirloom-tests-darwin** — the Apout-driven live-comparison
   harness. Highest research novelty; requires the most effort.
3. **OPP-15 Σ_content N3 substrate for the workspace** — turns
   TREE.md into a machine-readable, SPARQL-queryable provenance graph.
4. **OPP-8 + OPP-12** together — bundle 15+ additional papers into
   citations-darwin in 1 hour of work.
5. **OPP-2  heirloom-oralhistory-darwin** — small, deep primary source
   (subject to CHM permissions).

Everything else is TIER-2 or later. Total possible extension footprint,
if all TIER-1 + TIER-2 done: **7 new repos or major extensions**,
bringing the universe from 9 to potentially 16 repos.

---

# What NOT to do

- Do **not** try to preserve the whole 12 GB corpus in moonman81 repos.
  TUHS already does that job. Every extension should be a curated,
  documented, cross-referenced SUBSET with clear rationale.
- Do **not** create a repo for material whose primary value is
  historical-cultural rather than technical (Memorabilia, Usenix
  playing cards, most posters) unless the repo would primarily
  serve teaching / community.
- Do **not** ship live/moving-target upstream material verbatim; use
  the patches-only or annotation-only disciplines already established
  by `heirloom-vi-darwin` and `heirloom-ancestors-darwin`.

Written 2026-07-03. The corpus itself is unchanged; only opportunities
are enumerated. Nothing has been imported by this analysis pass.
