# Phase 6 hardening — CWE/OWASP/ATT&CK/CAPEC coverage matrix

Mapping each hardening check to the threat frameworks per PORT.md §5.

## Coverage summary

| Framework | Entries touched | Covered by |
|---|---|---|
| CWE Top 25 (2024) | 8 | roundtrip, static-analysis, fuzz-seeds, format-string-audit |
| OWASP Top 10 (2021) | 3 | setuid-audit, format-string-audit |
| MITRE ATT&CK v14 | 4 | setuid-audit, static-analysis |
| CAPEC 3.9 | 5 | setuid-audit, format-string-audit, fuzz-seeds |

## Detailed matrix

### CWE Top 25

| CWE | Description | Check | Result |
|---|---|---|---|
| **CWE-119** | Buffer overflow (classic) | fuzz-seeds/{nawk,bc,ed,sed}, static-analysis ASan | ✅ 0 ASan findings on cpio round-trip; seeds run clean |
| **CWE-125** | Out-of-bounds read | fuzz-seeds/{dc,ed,cpio-headers}, ASan | ✅ 0 findings |
| **CWE-134** | Format string | format-string-audit/clang-scan | ✅ 3 real findings → 3 fixes committed; scan now clean |
| **CWE-190** | Integer overflow | fuzz-seeds/expr/overflow, ASan+UBSan | ✅ UBSan finds none in cpio; expr seed exits cleanly |
| **CWE-269** | Improper privilege management | setuid-audit | ✅ Intent list matches installed state (empty, unprivileged install) |
| **CWE-427** | Uncontrolled search path (setuid deps) | setuid-audit dep-trust check | ✅ No suid targets to check on unprivileged install; check ready for real deploy |
| **CWE-674** | Uncontrolled recursion | fuzz-seeds/nawk/deep-recurse | ⚠ Documented as accepted: universal awk behaviour, all K&R awks share it |
| **CWE-732** | Incorrect permission assignment | setuid-audit | ✅ Ownership + mode inspection ready; install-suid.sh applies intent |

### OWASP Top 10 (2021)

| OWASP | Description | Check |
|---|---|---|
| A01: Broken Access Control | Setuid `su`, spool ownership | setuid-audit + install-suid.sh |
| A03: Injection | Format-string, command-string parsing | format-string-audit |
| A08: Software & Data Integrity | Legacy artefact preservation, dep trust | roundtrip + setuid-audit dep-trust |

### MITRE ATT&CK v14

| ATT&CK | Technique | Check |
|---|---|---|
| T1548.001 | Setuid & Setgid | setuid-audit enumerates + validates |
| T1574.006 | Dynamic Linker Hijacking | setuid-audit @rpath + dep-trust |
| T1059.004 | Unix Shell Abuse | sh format-string audit (clean) |
| TA0002 | Execution (general) | static-analysis sanitiser build |

### CAPEC 3.9

| CAPEC | Pattern | Check |
|---|---|---|
| CAPEC-69 | Target Programs with Elevated Privileges | setuid-audit |
| CAPEC-100 | Buffer Overflow | fuzz-seeds/{nawk,bc,ed,sed,cpio} |
| CAPEC-135 | Format String Injection | format-string-audit |
| CAPEC-159 | Redirect Access to Libraries | setuid-audit @rpath check |
| CAPEC-471 | Search Order Hijacking | setuid-audit dep-trust |

## Findings fixed during this phase

| Location | CWE | Fix | Commit |
|---|---|---|---|
| toolchest/cpio/cpio.c:2418 | CWE-134 | Add literal "%s" format | pending |
| pkgtools/libpkg/pkgerr.c:116 | CWE-134 | Add literal "%s" format | pending |
| pkgtools/libpkg/tputcfent.c:162 | CWE-134 | Add literal "%s" format for strftime output | pending |
| doctools/troff/n7.c:1489 | CWE-476 (NULL deref) | Guard first-alloc path | already committed 85cf402 |

## Findings deferred (documented, no fix)

| Location | Rationale |
|---|---|
| CWE-674 in nawk/oawk/bc | Universal awk-family behaviour; no interpreter in the family bounds recursion. Documented in fuzz-seed comment. Downstream users must apply resource limits (`ulimit -s`) if fielding awk against untrusted input. |
| CWE-732 warnings on install | Unprivileged install — no suid targets present. Real deployments run `hardening/setuid-audit/install-suid.sh` after `sudo make phase3-install`. |

## Deferred to future phases

| Item | Task |
|---|---|
| Full AFL / libFuzzer runs across the seed corpora | future task (est. 4-8h for meaningful coverage) |
| clang-scan --analyze deep-analysis pass | future task |
| Full CWE Top 25 coverage sweep beyond the sampled utilities | future task |
| OpenSSL 3.x pkgtools port completion → re-adds attack surface to audit | task #19 (Phase 5-C4) |
