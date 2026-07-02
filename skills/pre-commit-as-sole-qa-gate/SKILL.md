---
name: pre-commit-as-sole-qa-gate
description: "No-CI-budget QA model: use pre-commit as the sole enforcement point for lint / format / security-scan / hardening runs. Three-tier hook stages — pre-commit (fast hygiene, every commit), pre-push (shellcheck + cppcheck + format-string audit on changed files, every push), manual (full roundtrip + full lint sweep + format-string audit whole tree, before tagging). Reports committed to git so 'git diff' between releases surfaces QA delta."
gate: 3
version: "1.0.0"
author: moonman81
tags: [pre-commit, qa, no-ci, hardening, github-actions-alternative, tiered-hooks]
depends_on: []
allowed-tools:
  - Read
  - Write
  - Bash
when_to_use: "Invoke when scoping QA for a project with no CI budget (personal / hobby / low-traffic OSS), or when advising an owner who is exhausting GitHub Actions minutes on a project that could shift QA earlier. Triggers: 'no CI budget', 'GitHub Actions minutes exhausted', 'pre-commit tiered stages', 'reports in git', 'local QA enforcement'."
---

# Pre-commit as sole QA gate

## The premise

Not every project has CI budget. GitHub Actions minutes are free
only up to a limit; heavy build + lint pipelines exhaust the quota
quickly on any OSS project of modest activity. Self-hosted runners
carry infrastructure cost. Some maintainers deliberately opt out.

The alternative: **do the QA locally, on the contributor's machine,
at pre-commit time**, and refuse pushes that would fail CI. This
model works well for:

- Personal / hobby OSS.
- Ports of unmaintained upstreams (like Heirloom).
- Projects where contributors are trusted / small in number.
- Projects where behaviour is deterministic (crypto verification,
  compression, formatters) — the local machine's output equals CI's.

## The three-tier hook model

```yaml
default_stages: [pre-commit]

repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace       # pre-commit
      - id: end-of-file-fixer          # pre-commit
      - id: check-added-large-files    # pre-commit
      - id: check-merge-conflict       # pre-commit
      - id: check-yaml                 # pre-commit
      # ... etc.

  - repo: https://github.com/codespell-project/codespell
    rev: v2.3.0
    hooks:
      - id: codespell                  # pre-commit (docs+shell only)
        types_or: [markdown, shell, yaml, toml]

  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.10.0.1
    hooks:
      - id: shellcheck                 # pre-push
        stages: [pre-push]

  - repo: local
    hooks:
      - id: format-string-audit        # pre-push
        entry: |
          bash -c 'for f in "$@"; do
            cc -c -Wformat-security -fsyntax-only "$f" 2>&1 \
              | grep -q "warning:.*format" && exit 1 || :
          done'
        language: system
        stages: [pre-push]
        types: [c]

      - id: roundtrip-suite            # manual
        entry: sh hardening/roundtrip/roundtrip.sh
        language: system
        stages: [manual]
```

### pre-commit (every commit — fast)

- Whitespace, EOF, large-file, merge-conflict-marker, YAML/JSON syntax.
- Codespell on Markdown + shell + YAML + TOML only (upstream C
  code has decades-old typos we do NOT touch).
- Local hooks: LICENSE / NOTICE / AI-DISCLOSURE / GRATITUDE
  preservation gate.

Total cost: <2 seconds on a typical commit.

### pre-push (every `git push` — seconds)

- shellcheck on all changed shell files.
- cppcheck on changed C files.
- `clang -Wformat-security` on changed C files (catches CWE-134).

Total cost: seconds to a few tens of seconds.

### manual (opt-in — before tagging a release)

- Full roundtrip suite (cpio × 3 formats, tar × 2, SCCS, SVR4 pkg,
  awk, ISO 8601 date).
- Full 17-tool lint sweep (cppcheck + splint + flawfinder +
  clang-tidy + iwyu + codespell + shellcheck + sloccount + tokei
  + …).
- Format-string audit across every C file in the tree.

Total cost: minutes.

Invoked explicitly:

```sh
pre-commit run --hook-stage manual --all-files
```

## Reports in git

Manual-tier hooks land their output under
`hardening/*/report-*.txt` with **predictable filenames**. These
files are **committed to git**. Consequence:

```sh
git diff v0.1.0..v0.2.0 -- hardening/
```

shows exactly what QA delta happened between releases. No external
report store, no CI artefacts, no S3 bucket. Everything travels
with the code.

## Installation for contributors

`make bootstrap` runs `pre-commit install` (pre-commit hooks) and
`pre-commit install --hook-type pre-push` (pre-push hooks). Once
that's done, every contributor's local commits and pushes are
gated. The maintainer's review posture is "the tooling caught the
mechanical issues; I focus on the substantive ones".

## What this does NOT replace

- **Reproducibility across machines.** If contributor A's clang
  version differs materially from contributor B's, they may see
  different lint output. Documented risk; mitigated by pinning
  brew formulae versions.
- **Security-critical release audit.** For high-value releases,
  the maintainer still runs an independent audit; pre-commit is a
  first line, not the last.
- **Untrusted-contributor safety.** If contributors are anonymous
  and may not run the hooks, the model degrades. Add a manual
  review step for such contributions.

## When to use this model

✅ Personal / hobby OSS with 1-3 maintainers.
✅ Legacy-code preservation projects.
✅ Deterministic-behaviour tools (formatters, compressors,
   verifiers).
✅ Anywhere the CI cost / benefit ratio is unfavourable.

## When NOT to use it

❌ Large-team OSS with unknown contributors.
❌ Web services with runtime CI needs (deploy pipelines).
❌ Regulated code that requires third-party build attestation.
❌ Anywhere the "same machine, same output" assumption breaks.

## Reference

- <https://pre-commit.com> — the framework.
- `heirloom-workspace-darwin/.pre-commit-config.yaml` — the worked example.
