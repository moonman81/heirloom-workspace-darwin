# Phase 6 hardening + legacy round-trip test suite

Post-build discipline per PORT.md §5 (SDLC/SSDLC). Each sub-directory
holds a self-contained slice of the hardening pass. Run each script
directly or via `make -C hardening all`.

## Directory layout

| Dir | Purpose | CWE / OWASP / ATT&CK / CAPEC hooks |
|---|---|---|
| `roundtrip/`   | Reads a legacy artefact of each on-disk format and asserts our tools round-trip it byte-identically | Preservation of legacy interop (PORT.md §2) |
| `setuid-audit/` | Enumerates every setuid target we install; checks permission, ownership, and shared-library trust | CWE-732, CWE-269, ATT&CK T1548 (Abuse Elevation Control Mechanism) |
| `format-string-audit/` | Grep + clang analyser pass for `printf`-family calls with user-controlled fmt arg | CWE-134, CAPEC-135 |
| `fuzz-seeds/`  | Corpus of malformed inputs for parsers (nawk, oawk, bc, dc, calendar, expr, ed, sed, cpio, tar) — feeds AFL / libFuzzer | CWE-119/120/125/787, CWE-190, CAPEC-100, CAPEC-88 |
| `static-analysis/` | Wraps `scan-build` + `-fsanitize=address,undefined` builds; captures the outputs | CWE-416 UAF, CWE-476 NULL deref, CWE-190 int overflow |

## Coverage matrix

Each sub-directory carries a `COVERAGE.md` mapping its individual
checks to concrete CWE / OWASP / ATT&CK / CAPEC entries. Sources:

- **CWE Top 25 (2024)**: https://cwe.mitre.org/top25/
- **OWASP Top 10 (2021)**: https://owasp.org/Top10/
- **MITRE ATT&CK v14**: https://attack.mitre.org/
- **CAPEC 3.9**: https://capec.mitre.org/

## Run order

```
1. make -C hardening/setuid-audit          # find setuid installs
2. make -C hardening/format-string-audit   # grep + clang analyser
3. make -C hardening/roundtrip             # legacy interop
4. make -C hardening/static-analysis       # scan-build + sanitisers
5. make -C hardening/fuzz-seeds/corpus     # seed corpus (manual runs beyond)
```

`make -C hardening all` runs 1..4 in that order (fuzz is opt-in due
to time; run separately).
