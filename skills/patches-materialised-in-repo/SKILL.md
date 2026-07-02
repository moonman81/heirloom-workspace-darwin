---
name: patches-materialised-in-repo
description: "For a downstream port whose value is 'apply these Darwin patches to a pristine vendor tarball', ship a patches/ directory in each repo with per-commit .patch files (git format-patch output), a MANIFEST.md index, and a cumulative.diff single-file. Consumers who don't want to clone the whole port can apply the patches directly to their own vendor drop. Regenerated from git history — never hand-edited."
gate: 3
version: "1.0.0"
author: moonman81
tags: [patches, downstream-port, git-format-patch, provenance, upstream-contribution]
depends_on: []
allowed-tools:
  - Read
  - Write
  - Bash
when_to_use: "Invoke when scoping how to publish patches from a downstream port to make them consumable by users who prefer to apply patches to their own vendor drop, or by upstream maintainers reviewing the port for merge. Triggers: 'materialise patches in repo', 'patches/ directory pattern', 'git format-patch series', 'cumulative diff for patch(1)', 'downstream patch series'."
---

# Patches materialised in repo

## The idea

A downstream port's value is: **these specific patches make the
vendor code work on our platform**. Everything else in the port
repo — README, NOTICE, ALM Makefile, scripts, tests, docs — is
supporting infrastructure. The patches ARE the port.

Make that fact visible by shipping the patches as **first-class
files under `patches/`**, generated automatically from git history,
alongside the vendor baseline (commit 1) and the accumulated
downstream work.

## Layout

```
patches/
├── README.md               ← usage overview
├── MANIFEST.md             ← index: subject / SHA / files-touched per patch
├── 0001-<subject>.patch    ← git format-patch output, per commit
├── 0002-<subject>.patch
├── ...
└── cumulative.diff         ← one file: vendor → current, unified diff
```

## Regeneration script

```sh
# Locate patch range: vendor baseline → last port commit
VENDOR=$(git rev-list --max-parents=0 refs/heads/main)
END=$(git log --format='%H %s' | grep 'first-post-patch-commit' | head -1 | awk '{print $1}')^

# Clear + regenerate
rm -rf patches
mkdir -p patches
git format-patch --output-directory=patches "$VENDOR..$END" >/dev/null
git diff "$VENDOR..$END" -- . ':(exclude)patches/' > patches/cumulative.diff

# Emit MANIFEST.md
# ... walk patches/, extract subject + SHA + file-count per patch ...
```

The full script is in `heirloom-<pkg>-darwin/patches/README.md`
consumers-facing; the port maintainer keeps a wrapper at
`/tmp/heirloom-patches.sh` or similar.

## What ends up in `patches/`

**Only the port patches themselves.** Not:

- Housekeeping commits (README, NOTICE, CHANGELOG, GRATITUDE,
  AI-DISCLOSURE, CONTRIBUTING, SECURITY, ISSUE_TEMPLATE).
- ALM commits (GNUmakefile, scripts/, man/, HOWTO.md).
- Skills / documentation additions.

These are additive to the repo but they are not modifications to the
vendor code. Including them in `patches/` would obscure the actual
Darwin work — a reader wanting to know "what did the port CHANGE in
the vendor code" should get the answer in one directory listing.

## Consuming the patches

### git-format workflow

```sh
# 1. Get the vendor tarball
$ curl -O http://heirloom.sourceforge.net/.../vendor-070715.tar.bz2
$ tar xjf vendor-070715.tar.bz2
$ cd vendor-070715

# 2. Init git so we can apply the patch series
$ git init && git add -A && git commit -m "vendor: pristine 070715"

# 3. Apply every port patch, one by one, preserving author/date/subject
$ git am /path/to/heirloom-<pkg>-darwin/patches/*.patch
```

Each patch becomes an individual commit with the port maintainer's
authorship, date, subject, and body preserved from `git
format-patch`.

### patch(1) workflow

For environments without `git`:

```sh
$ cd vendor-070715
$ patch -p1 < /path/to/heirloom-<pkg>-darwin/patches/cumulative.diff
```

Loses per-commit granularity; produces a bulk diff. Fine for a
one-shot port; not fine for cherry-picking.

## Provenance value

- **Downstream porters** see the exact list of Darwin-specific
  changes without cloning the whole repo. Ideal for someone who
  wants to port the same vendor code to, say, OpenBSD — they can
  read `patches/` to see which changes to expect.
- **Upstream maintainers** reviewing a port for merge can walk
  `patches/*.patch` as a review series. `git send-email
  patches/*.patch` is a one-liner.
- **Audit trail.** Someone asking "prove this port consists exactly
  of these N patches, no more, no less" can compare `patches/`
  against the git log range.

## Automated regeneration

Never hand-edit `patches/*.patch`. They are a materialised view of
the git history. The regeneration script must:

- Be idempotent (delete + regenerate).
- Commit the resulting change if any (so a re-run either produces no
  diff or produces a new commit).
- Be run automatically by CI or by a pre-commit manual-stage hook.

## The workspace-repo variant

The workspace repo does NOT carry `patches/`. Its history is not
port patches to a vendor drop; it is the port's own infrastructure.
Skip `patches/` for workspace / orchestration / documentation repos.

## When to use this pattern

✅ Downstream port of an unmaintained upstream (Heirloom, MINIX,
   ancient Unix, TENEX libraries).
✅ Vendored dependency with local patches that need to be
   re-applied on upstream refreshes.
✅ Distribution-style patch series (Debian rules-of-conduct for
   how to publish `.deb`-style patch stacks).

## When NOT to use this pattern

❌ Greenfield code you own — patches are meaningful only against a
   pristine reference.
❌ Long-running fork where the fork has diverged so far that
   "patches against upstream" is no longer meaningful.
❌ Projects where every commit is a mixture of port + housekeeping
   — separate them first, then materialise.

## Reference

- `git format-patch(1)`, `git am(1)`, `patch(1)`.
- <http://heirloom.sourceforge.net> — upstream Heirloom vendor
  reference.
- Every `heirloom-<pkg>-darwin/patches/MANIFEST.md` in the port
  set carries a worked example of the layout.
