# Heirloom Darwin port — decisions record

Host: macOS 26.4.1 (Tahoe), Darwin 25.4.0, arm64, Apple clang 21.
Type widths (probed): time_t=8, off_t=8, long=8, int=4. LP64 model.

## Project-wide constraints

These constraints govern every phase and every edit:

1. **ISO 8601 default.** Where the date/time output format is at our
   discretion (new reports, new logs, new configuration knobs), default
   to `YYYY-MM-DD` (or full RFC 3339 `YYYY-MM-DDTHH:MM:SS±hh:mm` when a
   time component is needed). Where the format is mandated by POSIX,
   SUS, an existing on-disk / on-tape / on-wire artefact, or a legacy
   spec (POSIX `touch -t` argument, `date` default output, cpio/tar
   header timestamps, SCCS s-file date fields), preserve the mandated
   format.

2. **Legacy-proof.** Every ported utility must remain able to read and
   correctly interpret artefacts produced by prior systems: cpio
   archives (binary, ASCII, SVR4 hex), tar archives (USTAR + old), SCCS
   s-files, SVR4 pkg datastreams, troff documents, .mailrc files, magic
   file, terminfo/termcap, mail spool, spellhist, sulog. No on-disk /
   on-tape / on-wire format change without documented reasoning.

3. **Future-proof.** Every design choice at every phase should leave
   room for a knob to be added later. Prefer configuration variables
   over hard-coded constants; prefer overlayable defaults over embedded
   assumptions; prefer feature-detection over platform-detection where
   feasible. Prefer additive changes (new options, new envvars, new
   optional fields) over subtractive.

4. **Anything not preservable is documented.** Not just "we broke X"
   but *why*, what the alternative was, what it would have cost, and
   what the workaround is for legacy consumers. Recorded here in the
   Deviations section.

5. **SDLC + SSDLC discipline.** Each phase carries a test plan that
   explicitly considers:
   - **CWE Top 25** — buffer overflow (CWE-119/120/125/787), integer
     overflow (CWE-190), use-after-free (CWE-416), NULL dereference
     (CWE-476), path traversal (CWE-22), command injection (CWE-78),
     incorrect permissions (CWE-732), hard-coded credentials (CWE-798).
   - **OWASP Top 10** — A01 broken access control (setuid `su`, spool
     ownership), A03 injection, A08 software & data integrity.
   - **MITRE ATT&CK** — T1059.004 Unix-shell abuse (sh hardening),
     TA0004 privilege escalation (setuid audit).
   - **CAPEC** — CAPEC-100 buffer overflow, CAPEC-66 format-string,
     CAPEC-88 OS command injection.
   Security-critical utilities (`su`, `mail`, `cpio`, `tar`, `find`,
   `expr`, `passwd`, `login`-adjacent) get a dedicated hardening pass
   before release.

## Decisions (from scoping conversation)

1. **Install prefix**: `/opt/heirloom`
   - `bin/`         — SVID3 (default) personality
   - `bin/s42/`     — SVID4/SVR4.2 personality
   - `bin/posix/`   — POSIX.2/SUSv2 personality
   - `bin/posix2001/` — POSIX.1-2001/SUSv3 personality
   - `ucb/`         — UCB/BSD personality
   - `ccs/bin/`     — CCS (yacc, lex, m4, make, sccs)
   - `lib/`         — shared data (magic file, troff fonts/tmac, sccs help)
   - `share/man/5man/` — Heirloom man pages (`man1`, `man1b`, ..., `man8`)
   - `etc/default/` — defaults files

2. **Package scope**: all 5 (sh, devtools, toolchest, doctools, pkgtools).

3. **utmpx / process listing strategy on Darwin**:
   Port over macOS' `libproc` (from `<libproc.h>`) for process enumeration.
   For utmpx, Darwin does ship `<utmpx.h>` with `getutxent`/`endutxent` (deprecated
   since 10.9 but still functional), so those parts continue to work; the
   Heirloom `libcommon/_utmpx.h` shim is bypassed. Where Heirloom relies on
   Linux `/proc` scanning (`ps`, `whodo`, `pgrep`), it is rewritten against
   `proc_listpids(PROC_ALL_PIDS, ...)` + `proc_pidinfo(...)`.

4. **Personalities**: all four (SVID3, SVID4, POSIX, POSIX-2001) + UCB.
   All four are feasible on Darwin — they differ only in compile-time flags
   and install path within a single source tree, and Darwin's C library
   satisfies every one of them.

## Shared Darwin variable overlay (applied to every mk.config)

```
CC              = cc
HOSTCC          = cc
CPPFLAGS        = -D_DARWIN_C_SOURCE
CFLAGS          = -O -g
CFLAGS2         = -O2 -g
CFLAGSS         = -Os -g
CFLAGSU         = -O2 -g -funroll-loops
LDFLAGS         =
LARGEF          =                     # Darwin off_t already 64-bit
LCRYPT          =                     # no -lcrypt on Darwin
LKVM            =                     # no -lkvm on Darwin (use libproc)
LSOCKET         =                     # sockets in libSystem
LCURS           = -lcurses            # ncurses shim in libSystem
LIBZ            = -lz                 # no -Bstatic on lld
LIBBZ2          = -lbz2
USE_ZLIB        = 1
USE_BZLIB       = 1
RANLIB          = ranlib -c
STRIP           = strip
YACC            = yacc                # Phase 1: system bison; Phase 3+: /opt/heirloom/ccs/bin/yacc
LEX             = lex                 # Phase 1: system flex;  Phase 3+: /opt/heirloom/ccs/bin/lex
```

## Prefix variables (mk.config, all packages)

```
ROOT            =                     # DESTDIR-style; empty for direct install
DEFBIN          = /opt/heirloom/bin
SV3BIN          = /opt/heirloom/bin
S42BIN          = /opt/heirloom/bin/s42
SUSBIN          = /opt/heirloom/bin/posix
SU3BIN          = /opt/heirloom/bin/posix2001
UCBBIN          = /opt/heirloom/ucb
CCSBIN          = /opt/heirloom/ccs/bin
DEFLIB          = /opt/heirloom/lib
DEFSBIN         = /opt/heirloom/bin
MANDIR          = /opt/heirloom/share/man/5man
DFLDIR          = /opt/heirloom/etc/default
SPELLHIST       = /opt/heirloom/var/adm/spellhist
SULOG           = /opt/heirloom/var/log/sulog
MAGIC           = /opt/heirloom/lib/magic
```

## Deviations from stock mk.config, per package

- **sh** — no mk.config; edits applied to `sh/makefile` directly.
- **devtools** — `mk.config` edited; `YACC=yacc`/`LEX=lex` (bootstrap via system flex/bison).
- **toolchest** — `build/mk.config` edited; also `build/mk.head` inspected for header injections.
- **doctools** — `mk.config` edited; troff data paths (`FONTDIR`/`TMACDIR`) resolved under `/opt/heirloom/lib/troff`.
- **pkgtools** — `mk.config` edited; `CPPFLAGS` prepended with `-I/opt/homebrew/opt/openssl@3/include`.

## Build order (phase-driven; see top-level Makefile)

Phase 1 → sh    (bootstrap runtime)
Phase 2 → devtools     (yacc/lex/m4/make/sccs)
Phase 3 → toolchest    (libs first, then utilities in five sub-tiers)
Phase 4 → doctools     (troff family)
Phase 5 → pkgtools     (SVR4 packaging)

Each phase installs into `/opt/heirloom` as it completes (or into
`$(STAGE)/opt/heirloom` if `STAGE=/absolute/path` is set, DESTDIR-style).

---

## Phase 0.5 audit — Y2K, Y2038, and large-file findings

Full grep evidence in commit history. Summary:

### Y2K findings

| Finding | Location | Verdict |
|---|---|---|
| **Hard-coded '19' century prefixes** | *none across all 5 packages* | ✅ clean |
| **Two-digit-year `strftime` output** | `toolchest/logins/logins.c:165` (`%m%d%y`) | ⚠ display-only, 6-byte buffer forces `MMDDYY`; will replace with `%Y-%m-%d` (ISO 8601) inside a wider buffer as a Phase 3b-iii fix — output format change tolerated because `logins(1)` output is human-facing not machine-consumed |
| **Two-digit-year input format** | `pkgtools/libadm/ckdate.c:53,86` (default `%m/%d/%y`) | ⚠ **legacy Sun windowing** — 70–99 → 20th century, 00–69 → 21st century; SUS-standard. Keep as-is (SVR4 pkg format preservation). Add `%Y-%m-%d` as accepted parse form (additive extensibility) |
| **SCCS s-file date parsing** | `devtools/sccs/man/prs.1:87`, `get.1:92` (documented) | ⚠ same 69/00 sliding window; on-disk SCCS s-file format ⇒ **cannot change** without breaking every SCCS ever authored. Preserve. |
| **`touch(1) -t` POSIX parsing** | `toolchest/touch/touch.c:229` | ✅ standard POSIX pivot (`if tm_year<69 tm_year+=100`); 4-digit path present; correct |
| **`date(1)` default output** | `toolchest/date/date.c:226` (`%a %b %e %H:%M:%S %Z %Y`) | ✅ 4-digit year always |
| **`calendar(1)` reminders** | `toolchest/calendar/calendar.c` | ✅ uses `localtime()` on live `time_t`; no year windowing |
| **`nawk`/`oawk` `systime`/`strftime`** | `toolchest/nawk/`, `toolchest/oawk/` | ✅ delegates to libc `strftime` — user script's choice of `%Y` or `%y` |

### Y2038 findings

Darwin arm64 has `sizeof(time_t) == 8`. Every C-level `time_t` variable is
Y2038-safe at the language level. The remaining risks are:

| Finding | Location | Verdict |
|---|---|---|
| **`int` cast of time_t** | *none found* | ✅ clean |
| **`time()` return stored in non-`time_t`** | *none problematic*; all callers use `time_t` | ✅ clean |
| **`long` used for time-of-day** | `toolchest/tar/tar.c:1976 (long mtime)`, `sccs/mpwlib/lockit.c:78 (long ltime, omtime)` | ✅ safe on Darwin (`long` = 64-bit); would truncate on 32-bit ILP32 platforms — **document as ILP32-unsafe** for the future-portability register |
| **Cpio binary archive `c_mtime[4]`** | `toolchest/cpio/cpio.c:373` (binary format), `be32p/pbe32/me32p/pme32` | ⚠ **format-limited to 32-bit seconds** → wraps at year 2106 (unsigned) or 2038 (signed). **Cannot fix without breaking cpio interop.** Preserve. Add write-time warning when mtime > 0xFFFFFFFF. Reader accepts unsigned semantics (year 2106 boundary). |
| **Cpio SVR4 hex archive `c_mtime[11]`** | `toolchest/cpio/cpio.c:409` (SVR4 hex ASCII format) | ✅ 11 hex digits ≈ 44 bits ≈ year 559 444; safe past 2038 |
| **Cpio octal ASCII `c_mtime` (old ASCII)** | `toolchest/cpio/cpio.c:3807` (`rdoct(bp->Cdr.c_mtime, 11)`) | ✅ 11 octal digits = 33 bits ≈ year 2242; safe |
| **Tar USTAR `mtime[12]`** | `toolchest/tar/tar.c` USTAR block | ✅ 11 octal digits + NUL = 33 bits ≈ year 2242; safe. GNU tar base-256 extension supported for post-2242. |
| **SVR4 pkg `volcopy_label.v_time`** | `pkgtools/hdrs/archives.h:170` (`int v_time`) | ⚠ dead code path — `volcopy(1M)` not in Toolchest utility list, not built. Note but no action. |
| **SCCS delta table `s_time_t p_cutoff`** | `devtools/sccs/hdr/defines.h:193` | ✅ declared `time_t`; Darwin 64-bit |
| **Mail lock timestamp** | `toolchest/mail/maillock.c:55` (`time_t locktime`) | ✅ clean |

### Large-file support findings

Darwin: `sizeof(off_t) == 8` always; `_FILE_OFFSET_BITS` is ignored; LFS is transparent.

| Finding | Location | Verdict |
|---|---|---|
| **`off_t` variable count** | 145 across all packages | ✅ used correctly throughout |
| **`fseek()` calls (LONG-arg, not `off_t`)** | 43 sites across Toolchest + Doctools + Devtools + Pkgtools | ✅ safe on Darwin because `long`=64-bit; **document as ILP32-unsafe**. Prefer `fseeko`/`ftello` for new code — additive convention. |
| **`fseeko`/`ftello`** | 24 / 4 sites | ✅ already used where it matters (tar, cpio) |
| **`lseek()` callers** | 8 sites in critical utilities | ✅ all use `off_t` locals |
| **`st_size` casts to smaller type** | *none found* | ✅ clean |
| **Explicit `stat64`/`fstat64`/`struct stat64`** | `pkgtools/libinst/ocfile.c` (2 hits), `pkgtools/libadm/fulldevnm.c` (many hits) | ⚠ **Darwin action needed:** Darwin still ships `stat64` etc. as deprecated aliases of `stat`. Will compile with deprecation warnings; behaviour is correct. **Fix in Phase 5:** add a small header shim `#define stat64 stat` (etc.) to silence warnings and keep future-portability clean. |
| **`_FILE_OFFSET_BITS` references in code** | *none in source* — only in `mk.config` where we zeroed it | ✅ clean |
| **Darwin `struct stat` `st_size` type** | `off_t` (probed from SDK `<sys/stat.h>`) | ✅ 64-bit unconditionally |

### Time-related headers, macOS support

- `<time.h>`, `<sys/time.h>`, `<sys/times.h>` — all present on Darwin, POSIX-compatible.
- `<utmpx.h>` — present but deprecated since 10.9; `getutxent()` still functional. Used by `who`, `users`, `shl`, `logins`. Keep the standard-utmpx code path for these; Darwin will emit deprecation warnings — silence via `-Wno-deprecated-declarations` scoped to the affected translation units.
- `struct stat st_mtimespec` / `st_atimespec` — Darwin exposes both timespec forms and the SUS-compat `st_mtime`/`st_atime`/`st_ctime` aliases. Heirloom uses the plain aliases → portable.

### Format-preservation constraints (immutable)

These formats **must not change** — any change breaks legacy artefact interop:

- **cpio** binary header — 32-bit big-endian mtime (year 2106 unsigned wrap)
- **cpio** old ASCII header — 11-octal mtime (year 2242)
- **cpio** SVR4 hex header — 11-hex mtime (year 559 444)
- **tar** USTAR header — 11-octal mtime (year 2242) + GNU base-256 extension for later
- **SCCS s-file** delta table — 2-digit year with 69/00 sliding pivot (Y2069 boundary)
- **SVR4 pkg** datastream — pkginfo/prototype format, fixed field widths
- **magic** file — /etc/magic format, fixed record layout
- **utmpx** on-disk — Darwin's format, host-owned (we consume via libc)

Any write outside these boundaries emits a warning; any read tolerates the boundary as documented.

### Future-configurability register

Deferred but scoped for later configurability, per project-wide constraint 3:

| Register entry | Trigger | Extension mechanism |
|---|---|---|
| ISO 8601 as default output format everywhere | env `HEIRLOOM_DATEFMT` | `date(1)` already supports `+FMT`; wire an envvar for default fallback |
| Post-2038 archive extension for cpio | user hits mtime > 0xFFFFFFFF | Adopt libarchive-style `mtime.high` extended attribute in new archive-format variant `svrx` (opt-in) |
| SCCS 4-digit year on write | user requests | Extend `admin -n` to accept a `-Y4` flag; on-disk s-file stays legacy on read |
| `stat64` shim in Pkgtools | Darwin deprecation warnings become errors | Header `src/pkgtools/hdrs/darwin_stat_shim.h` (added in Phase 5) |
| `_FILE_OFFSET_BITS=64` re-enable | port to 32-bit Linux later | mk.config already has `LARGEF` variable; set at that time |
| ILP32 portability | future 32-bit target | The `long mtime` in tar.c and SCCS lockit.c should be `time_t` — flagged in tar/lockit source comments |

### Test-plan hooks per SDLC constraint 5

Applied at every phase — each phase's test suite MUST include:

- Fuzz seeds for any parser touched (nawk grammar, bc/dc grammar, calendar, expr, ed, sed, cpio header, tar header).
- Setuid audit output for `su` (Phase 3b-iii) and any tool installed setuid.
- Format-string audit for printf-family callers with user-controlled fmt arg.
- Round-trip test with a legacy artefact of each on-disk format (cpio binary, cpio ASCII, tar USTAR, SCCS s-file, SVR4 pkg) — proves preservation constraint 2.
- Buffer-overflow static-analysis pass (clang `-Wall -Wextra -Werror`) as a build-gate.

Tracked as Phase 6 (post-build hardening) — added below.

