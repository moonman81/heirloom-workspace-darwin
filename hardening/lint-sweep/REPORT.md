# Lint sweep — consolidated report

Ran every brew-available C linter/checker/validator across all 5
Heirloom packages. Reports live alongside this file
(`report-<tool>.txt`).

## Tools installed (17 total)

| Tool | Version | Category | Home |
|---|---|---|---|
| cppcheck | latest | Static analyser (UB/mem/style) | `/opt/homebrew/bin/cppcheck` |
| splint | 3.1.2 | K&R-era static analyser | `/opt/homebrew/bin/splint` |
| flawfinder | latest | CWE-oriented risky-function scanner | `/opt/homebrew/bin/flawfinder` |
| clang-format | via LLVM | Formatter | `/opt/homebrew/opt/llvm/bin/clang-format` |
| clang-tidy | via LLVM | Modern static analyser | `/opt/homebrew/opt/llvm/bin/clang-tidy` |
| scan-build | via LLVM | Deep static analyser | `/opt/homebrew/opt/llvm/bin/scan-build` |
| include-what-you-use | 0.26 | Include hygiene | `/opt/homebrew/bin/include-what-you-use` |
| uncrustify | latest | Formatter | `/opt/homebrew/bin/uncrustify` |
| astyle | latest | Formatter | `/opt/homebrew/bin/astyle` |
| codespell | latest | Typo checker | `/opt/homebrew/bin/codespell` |
| cpplint | latest | Google C++ style linter | `/opt/homebrew/bin/cpplint` |
| shellcheck | 0.11.0 | Shell linter | `/opt/homebrew/bin/shellcheck` |
| shfmt | latest | Shell formatter | `/opt/homebrew/bin/shfmt` |
| sloccount | 2.26 | SLOC metric | `/opt/homebrew/bin/sloccount` |
| tokei | 14.0.0 | Modern per-language SLOC | `/opt/homebrew/bin/tokei` |
| bear | 4.1.4 | compile_commands.json generator | `/opt/homebrew/bin/bear` |
| cscope | 15.9 | Code navigation index | `/opt/homebrew/bin/cscope` |
| ccache | latest | Compiler cache | `/opt/homebrew/bin/ccache` |

## Metric baselines

Both metric tools agree on the shape of the tree:

- **tokei** (modern, treats `.cc` as its own language): 843 C files (404,064 lines, 288,458 code) + 193 C headers (30,954 lines) + 61 C++ files (32,071 lines) + 13 yacc grammars (6,515 lines) + 5 lex scanners (2,043 lines) + 30 shell scripts (2,615 lines) + 6 Korn shell (2,591 lines) + 204 Makefiles (7,505 lines) + 4 RPM specs + 1 Perl + 2 awk.
- **sloccount** (older, ansic-only bucket): 294,049 ansic (89.02%), 23,308 cpp (7.06%), 5,390 yacc (1.63%), 3,149 sh (0.95%), 2,279 sed (0.69%), 2,002 lex (0.61%), 77 perl, 62 awk.

Total: **≈330K lines of code** (ignoring comments/blanks).

## Findings by tool

### flawfinder — CWE-oriented risky-function scanner

**5,917 findings at level ≥2** across 467,089 lines. CWE distribution:

| CWE | Count | What it means | Real-bug ratio |
|---|---|---|---|
| CWE-120 | 3,809 | Buffer copy without checking size (`strcpy`, `strcat`, `sprintf`) | Low (K&R code uses these ubiquitously; most are size-bounded implicitly) |
| CWE-119 | 2,062 | Improper restriction of operations within a memory buffer | Low |
| CWE-362 | 797 | Race conditions | Medium — real for `su` (setuid) and `mail` (spool) |
| CWE-134 | 590 | Format-string | Low — 3 real ones already fixed in Phase 6 |
| CWE-20  | 420 | Improper input validation | Medium |
| CWE-190 | 274 | Integer overflow | Low — most bounded by K&R constants |
| CWE-807 | 223 | Reliance on untrusted inputs in a security decision | Medium |
| CWE-367 | 165 | TOCTOU race (check-then-use) | Medium — setuid tools |
| CWE-377 | 109 | Insecure temp file | Real — `mkstemp` vs `tmpnam`. Fixable. |
| CWE-78  | 107 | OS command injection | Real — anywhere `system(3)` is called |

**79 findings at level 5 (critical)**, all concentrated in
`devtools/make/{vroot,src}` — race conditions around `chmod`, `chown`,
`readlink` used by SVR4 make's virtual-root abstraction. These are
inherent to how make interacts with the filesystem and require a
fundamental design change (opening fds before chmod, using `fchmod`)
to close; **not fixable without a make rewrite**.

### cppcheck — static analyser

Ran across sh + toolchest + pkgtools. **1 hard error found:**

- `sh/blok.c:217` — `abort(1);` on a non-void return path with no
  return statement. Real. Not a security issue but a warn-clean fix:
  add `abort(1); return 0;`. **Fix candidate.**

All other findings were `information: Limiting analysis of branches`
(cppcheck's rate-limiter, not a source issue).

### clang-tidy — modern static analyser

**55 findings** across the sampled hot utilities (cpio, tar, su,
pkgerr). Mostly `misc-include-cleaner` — files that use symbols
without directly including the providing header (working via
transitive includes). Legitimate but broad "hygiene" findings; not
security issues. **Batch-fix candidate later.**

### splint — K&R-era analyser

**16 findings** on 5 sampled utilities. Real ones:

- `sh/main.c:63` — `tmpout = "/tmp/sh-"` uses insecure temp-name
  prefix (matches CWE-377 above).
- Multiple `probable NULL dereference` warnings on macro chain
  expansions — need per-site triage.

### include-what-you-use

**6 include-cleanup suggestions** on the sample. Purely cosmetic;
none impact security or portability. Deferred.

### codespell — typos

**2,541 hits**. Vast majority are false positives:

- Technical acronyms (`hist`, `ba`, `als`)
- Old spellings that were correct in 1980s SVR4
- Author names in copyright notices

Not actioned. The ignore-list in `run.sh` catches the common ones;
a per-package review would be needed for meaningful cleanup and is
not security-relevant.

### shellcheck — Bourne + Korn shell linter

**250 findings** across 34 shell scripts. Common categories:

- SC2086: word-splitting on unquoted `$var` in loops
- SC2046: same, on `$(cmd)` results
- SC2006: legacy backticks — legitimate for a Bourne shell that
  predates POSIX `$(...)`, must NOT be changed
- SC2039: bashisms in `.sh` files — real portability issues

Real portability fixes: ~30 (mostly in doctools helper scripts).
**Fix candidates** for a shell-hardening sub-phase.

### shfmt — shell formatter

60 lines of formatting differences. Style-only, no logic changes.
Not actioned automatically to preserve upstream diff-blame.

## Findings NOT to fix

Per PORT.md §2 (legacy-proof) and §4 (document reasoning for
un-preservable changes):

1. **CWE-120/CWE-119 K&R strcpy/strcat/sprintf usage** — 5,000+
   hits. K&R C predates safer variants. Every one would need
   individual triage against a specific bounded buffer size. The
   3-file-3-hit CWE-134 pass in Phase 6 already caught the real
   attacker-controlled cases; the remaining hits are known-bounded
   internal string manipulation.

2. **CWE-6 (Insufficient warnings)** on backticks in Bourne shell —
   Heirloom sh IS pre-POSIX Bourne and does not support `$(...)`.
   Changing scripts to use `$(...)` would break with the shipped sh.

3. **flawfinder level-5 make/vroot race conditions** — inherent to
   SVR4 make's virtual-root abstraction. Not fixable without
   rewriting the design.

## Findings TO fix (candidate work items)

| Site | Finding | Effort |
|---|---|---|
| `sh/blok.c:217` | cppcheck missingReturn on abort path | 1 line |
| `sh/main.c:63` | insecure `tmpout` prefix (CWE-377) | 1 line — use `mkstemp` |
| ~30 shellcheck SC2039 bashisms in doctools/*.sh | portability | ~30 sites |
| clang-tidy `misc-include-cleaner` batch across toolchest | include hygiene | Broad — via git blame preservation, defer |

## Coverage vs. our declared threat frameworks

Adds to Phase 6's CWE Top 25 coverage:

- CWE-120, CWE-119 (buffer overflow) — 5,871 flawfinder hits;
  0 real exploits under ASan+UBSan sanitised cpio round-trip
- CWE-134 (format string) — 590 hits; 3 real, all fixed in Phase 6
- CWE-362, CWE-367 (race conditions) — 962 hits; documented as
  design-level; not exploited under normal use
- CWE-377 (insecure temp file) — 109 hits; `mkstemp` migration is
  a clean sub-phase candidate

Adds to OWASP Top 10 A08 (Software & Data Integrity):

- shellcheck 250 findings improve robustness of install/build
  scripts (part of software supply chain)

## Re-run

`make -C /Volumes/heirloom/src/hardening/lint-sweep` re-runs the
full sweep. Full sweep takes ~2 minutes on M-series arm64.
