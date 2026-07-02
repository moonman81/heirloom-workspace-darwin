# setuid-audit coverage matrix

## What this check does

1. **Enumerates** every binary under `/opt/heirloom` with the setuid
   or setgid bit set.
2. **Cross-checks** against the source-tree intent (per the Toolchest
   `heirloom.pkg` target, `su` and `ps` should be root-setuid;
   `shl` should be adm-setgid).
3. **Verifies dependency trust**: every shared-library dependency of
   a setuid binary must resolve inside `/System/Library`, `/usr/lib`,
   `/opt/heirloom`, `@rpath`, or `@executable_path`. Any dependency
   outside these paths is a CWE-732 finding — a setuid binary
   loading from a user-writable path is elevation-primitive.
4. **Records @rpath entries** — DYLD_LIBRARY_PATH is stripped by
   Darwin's dynamic linker for setuid execution, but explicit
   `LC_RPATH` load commands are not, so they need enumerating.

## Coverage — mapped to CWE / OWASP / ATT&CK / CAPEC

| Finding | CWE | OWASP | ATT&CK | CAPEC |
|---|---|---|---|---|
| Wrong perms on setuid target | CWE-732 | A01 Broken Access Control | T1548.001 Setuid & Setgid | CAPEC-69 Target Programs with Elevated Privileges |
| Dependency in writable path | CWE-732, CWE-427 | A08 Software & Data Integrity | T1574.006 Dynamic Linker Hijacking | CAPEC-471 Search Order Hijacking |
| @rpath in setuid binary | CWE-427 | A08 | T1574.007 Path Interception by PATH Environment Variable | CAPEC-159 Redirect Access to Libraries |
| Unexpected suid target (bit set on tool not in intent list) | CWE-269 | A01 | T1548 | CAPEC-70 Try Common or Default Usernames and Passwords |
| Suid target present in source but missing at install | (informational) | — | — | — |

## Current findings

Current run (`report.txt`): no binaries carry the setuid or setgid
bit because installation was performed as an unprivileged user
(`nonroot:staff`).

For a real deployment, `bin/su`, `bin/ps`, and `bin/shl` MUST have
their bits set. `install-suid.sh` (sibling) applies them under sudo.

## When to re-run

- After every install / re-install.
- After every deploy-time filesystem change under `/opt/heirloom`.
- Before every release.

## Escalation

Any finding at CWE-732 or CWE-427 severity is a release blocker.
File the finding against a specific binary; do not close until
the deployment tooling ensures the correct posture.
