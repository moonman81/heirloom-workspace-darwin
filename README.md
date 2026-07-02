# /opt/heirloom/src — Heirloom Darwin port workspace

Layout:

```
/opt/heirloom/src/
├── original/                        pristine vendor sources (not git-tracked)
│   ├── heirloom-sh-050706/
│   ├── heirloom-devtools-070527/
│   ├── heirloom-070715/             (toolchest)
│   ├── heirloom-doctools-080407/
│   └── heirloom-pkgtools-070227/
├── sh/                              per-package git repos
├── devtools/                        (git init'd; commit 1 = pristine drop
├── toolchest/                       from the corresponding original/ dir;
├── doctools/                        subsequent commits replay every patch
├── pkgtools/                        from the port history in order)
└── workspace/                       this workspace repo — cross-cutting files:
    ├── Makefile                     top-level phase driver
    ├── PORT.md                      decisions record + constraints
    ├── hardening/                   Phase 6 + 7 quality gates
    ├── .gitignore
    └── .cppcheck-suppress
```

Original monorepo remains at `/Volumes/heirloom/src` (16 commits chronicling
the full port). This split is a derived view for per-package release
management / upstream contribution.

Provenance: every commit in every per-package repo carries the same
subject line as its origin in the monorepo, so `git log` in each
package matches the corresponding monorepo commits chronologically.
