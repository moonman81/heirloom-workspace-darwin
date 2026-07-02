#!/bin/sh
#
# run.sh — run every brew-installed C linter/checker/validator over the
# Heirloom source tree and produce a consolidated report.
#
# Tools:
#   cppcheck       — static analyser (Undefined Behavior, memory, style)
#   splint         — K&R-era C static analyser (LCLint successor)
#   flawfinder     — CWE-oriented risky-function scanner
#   clang-tidy     — modern static analyser (bugprone, cert, security)
#   scan-build     — clang static analyser deep pass
#   include-what-you-use (iwyu) — include hygiene
#   codespell      — spellchecker for source comments + strings
#   shellcheck     — bourne/ksh linter
#   shfmt          — shell format check
#   sloccount      — SLOC count (baseline metric)
#   tokei          — modern SLOC (per-language)
#
# Runs per-package to keep output digestible; findings dropped into
# report-<tool>.txt files in this directory.

set -u

ROOT=${ROOT:-/Volumes/heirloom/src}
LLVM_BIN=/opt/homebrew/opt/llvm/bin
OUT=/Volumes/heirloom/src/hardening/lint-sweep
export PATH=$LLVM_BIN:/opt/homebrew/bin:/usr/bin:/bin

log() { printf '\n=== %s ===\n' "$*" | tee -a "$OUT/summary.txt" >&2; }

: > "$OUT/summary.txt"

log "Heirloom lint sweep — $(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# ---------------- tokei ----------------
log "tokei — source metrics"
tokei --exclude '*.o' --exclude '*.a' \
	"$ROOT/sh" "$ROOT/devtools" "$ROOT/toolchest" "$ROOT/doctools" "$ROOT/pkgtools" \
	2>&1 | tee "$OUT/report-tokei.txt"

# ---------------- sloccount ----------------
log "sloccount — historical SLOC"
sloccount "$ROOT/sh" "$ROOT/devtools" "$ROOT/toolchest" "$ROOT/doctools" "$ROOT/pkgtools" 2>&1 \
	| head -80 | tee "$OUT/report-sloccount.txt"

# ---------------- cppcheck ----------------
log "cppcheck — static analyser"
cppcheck \
	--enable=warning,performance,portability \
	--suppressions-list="$ROOT/.cppcheck-suppress" 2>/dev/null || \
cppcheck \
	--enable=warning,performance,portability \
	-j 4 \
	--suppress=missingIncludeSystem \
	--suppress=unmatchedSuppression \
	--suppress=variableScope \
	--suppress=unusedFunction \
	--suppress=preprocessorErrorDirective \
	--platform=unix64 \
	-I "$ROOT/toolchest/libcommon" -I "$ROOT/toolchest/libuxre" \
	"$ROOT/sh" "$ROOT/toolchest" "$ROOT/pkgtools" 2>&1 \
	| head -100 > "$OUT/report-cppcheck.txt"
wc -l "$OUT/report-cppcheck.txt" | tee -a "$OUT/summary.txt"

# ---------------- flawfinder ----------------
log "flawfinder — CWE-oriented risky-function scanner"
flawfinder --quiet --minlevel=2 \
	"$ROOT/sh" "$ROOT/devtools" "$ROOT/toolchest" "$ROOT/doctools" "$ROOT/pkgtools" \
	2>&1 | tee "$OUT/report-flawfinder.txt" | tail -25 >>"$OUT/summary.txt"

# ---------------- splint ----------------
log "splint — K&R-era analyser (samples on hot utils)"
: > "$OUT/report-splint.txt"
for c in \
	"$ROOT/sh/main.c" \
	"$ROOT/toolchest/cpio/cpio.c" \
	"$ROOT/toolchest/tar/tar.c" \
	"$ROOT/toolchest/su/su.c" \
	"$ROOT/toolchest/find/find.c" ; do
	printf '\n--- %s ---\n' "$c" >> "$OUT/report-splint.txt"
	splint \
		+posixlib \
		-preproc -unrecogcomments -Ddesktop \
		-I"$ROOT/toolchest/libcommon" \
		-I"$ROOT/toolchest/libuxre" \
		-D_DARWIN_C_SOURCE \
		"$c" 2>&1 | head -25 >> "$OUT/report-splint.txt" || :
done
grep -c 'warning\|error' "$OUT/report-splint.txt" >>"$OUT/summary.txt"

# ---------------- clang-tidy ----------------
log "clang-tidy — modern static analyser (samples on hot utils)"
: > "$OUT/report-clang-tidy.txt"
CLANG_TIDY_CHECKS='bugprone-*,cert-*,security-*,misc-*,portability-*,-bugprone-easily-swappable-parameters,-cert-err33-c'
for c in \
	"$ROOT/toolchest/cpio/cpio.c" \
	"$ROOT/toolchest/tar/tar.c" \
	"$ROOT/toolchest/su/su.c" \
	"$ROOT/pkgtools/libpkg/pkgerr.c" ; do
	printf '\n--- %s ---\n' "$c" >>"$OUT/report-clang-tidy.txt"
	clang-tidy --checks="$CLANG_TIDY_CHECKS" \
		"$c" -- \
		-D_DARWIN_C_SOURCE \
		-I "$ROOT/toolchest/libcommon" -I "$ROOT/toolchest/libuxre" \
		-I "$ROOT/pkgtools/hdrs" \
		2>&1 | head -50 >>"$OUT/report-clang-tidy.txt"
done
grep -c 'warning:\|error:' "$OUT/report-clang-tidy.txt" >>"$OUT/summary.txt"

# ---------------- codespell ----------------
log "codespell — typos in comments/strings"
codespell --quiet-level=3 --skip='*.o,*.a,*.afm,*.dic,*.ps,LICENSE*' \
	--ignore-words-list='thru,dout,hist,inh,paket,ba,als,sav,inout,couldnt,fo,parm,parms,inout,parm,pris,typ,arithmetics,strat,masq,pris,fram,typ,als,manuel,ba,ist,als,mote,ded' \
	"$ROOT/sh" "$ROOT/devtools" "$ROOT/toolchest" "$ROOT/doctools" "$ROOT/pkgtools" \
	2>&1 | tee "$OUT/report-codespell.txt" | wc -l | tee -a "$OUT/summary.txt"

# ---------------- shellcheck ----------------
log "shellcheck — Bourne + ksh linter"
: > "$OUT/report-shellcheck.txt"
for f in $(find "$ROOT/sh" "$ROOT/devtools" "$ROOT/toolchest" "$ROOT/doctools" "$ROOT/pkgtools" \
	-name '*.sh' -o -name '*.ksh' 2>/dev/null); do
	shellcheck --shell=sh --severity=warning "$f" 2>&1 >>"$OUT/report-shellcheck.txt" || :
done
grep -c '^In\|SC[0-9]' "$OUT/report-shellcheck.txt" | tee -a "$OUT/summary.txt"

# ---------------- shfmt ----------------
log "shfmt — shell format check"
shfmt -d "$ROOT/sh" "$ROOT/toolchest" 2>&1 | head -60 > "$OUT/report-shfmt.txt" || :
wc -l "$OUT/report-shfmt.txt" | tee -a "$OUT/summary.txt"

# ---------------- iwyu ----------------
log "include-what-you-use — include hygiene (sample)"
: > "$OUT/report-iwyu.txt"
for c in \
	"$ROOT/toolchest/cpio/cpio.c" \
	"$ROOT/toolchest/find/find.c" ; do
	printf '\n--- %s ---\n' "$c" >>"$OUT/report-iwyu.txt"
	include-what-you-use \
		-D_DARWIN_C_SOURCE \
		-I "$ROOT/toolchest/libcommon" -I "$ROOT/toolchest/libuxre" \
		"$c" 2>&1 | head -50 >>"$OUT/report-iwyu.txt" || :
done
grep -c 'should add\|should remove' "$OUT/report-iwyu.txt" | tee -a "$OUT/summary.txt"

log "sweep complete — reports in $OUT/"
ls -la "$OUT"
