# Fuzz-seed corpora

Seed inputs for AFL / libFuzzer runs against Heirloom parsers. Each
sub-directory holds inputs for one parser. The corpora are small
(hand-crafted edge cases) — feed them into AFL's `-i` flag for
mutation-based fuzzing:

```
afl-fuzz -i hardening/fuzz-seeds/nawk -o fuzz-out \
    -- /opt/heirloom/bin/nawk -f @@
```

## Parsers covered

| Parser | Corpus | CWE / CAPEC focus |
|---|---|---|
| nawk | `nawk/` | CWE-119 (buffer overflow in regex + printf), CWE-190 (integer overflow in loops) |
| oawk | `oawk/` | Same as nawk — older engine, different bug surface |
| bc   | `bc/`   | CWE-119, CWE-770 (unlimited resource) |
| dc   | `dc/`   | CWE-125 (out-of-bounds read on stack manipulation) |
| calendar | `calendar/` | CWE-134 (format string in reminders) |
| expr | `expr/` | CWE-190 (integer overflow), CWE-129 (validate array index) |
| ed   | `ed/`   | CWE-119, CWE-125 (line buffer, regex) |
| sed  | `sed/`  | CWE-119, CWE-125 |
| cpio | `cpio-headers/` | CWE-125, CWE-190, CWE-787 (archive header parsing) |
| tar  | `tar-headers/`  | Same as cpio |

## Manual fuzzing without AFL

For a quick smoke test without AFL, pipe seed inputs directly:

```
for seed in hardening/fuzz-seeds/nawk/*; do
    /opt/heirloom/bin/nawk -f "$seed" </dev/null 2>&1 | head -1
done
```

If any invocation SIGSEGVs / SIGABRTs, that's a finding.
