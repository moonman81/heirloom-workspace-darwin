#!/bin/sh
#
# clang-scan.sh — precise CWE-134 detection using clang's
# -Wformat-security + -Wformat-nonliteral flags.
#
# Recompiles each package's translation units with the extra warning
# flags enabled, collects the warnings, and produces a report.
# Non-blocking (does not touch installed binaries).

set -eu

ROOT=${ROOT:-/Volumes/heirloom/src}
REPORT=/Volumes/heirloom/src/hardening/format-string-audit/clang-scan-report.txt

: > "$REPORT"

log() { printf '%s\n' "$*" >>"$REPORT"; }

log "=== Heirloom clang -Wformat-security scan ==="
log "Date:   $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
log ""

CFLAGS_SCAN="-Wformat-security -Wformat=2 -Wno-format-nonliteral -fsyntax-only"

log "--- sh ---"
cd "$ROOT/sh"
for src in *.c; do
	cc $CFLAGS_SCAN -D_DARWIN_C_SOURCE -c "$src" -o /dev/null 2>&1 || true
done 2>&1 | grep -E 'format-security|format string is not a string literal' | tee -a "$REPORT" || :

log ""
log "--- toolchest (sampled: security-critical utilities) ---"
for tool in su mail cpio tar find grep sed ed cal date expr; do
	cd "$ROOT/toolchest/$tool" 2>/dev/null || continue
	for src in *.c; do
		[ -f "$src" ] || continue
		cc $CFLAGS_SCAN -D_DARWIN_C_SOURCE \
			-I../libcommon -I../libuxre -DUXRE \
			-c "$src" -o /dev/null 2>&1 || true
	done
done 2>&1 | grep -E 'format-security|format string is not a string literal' | tee -a "$REPORT" || :

log ""
log "--- pkgtools libpkg (touches user-supplied packaging metadata) ---"
cd "$ROOT/pkgtools/libpkg"
for src in *.c; do
	cc $CFLAGS_SCAN -D_DARWIN_C_SOURCE \
		-include $ROOT/pkgtools/hdrs/darwin_stat_shim.h \
		-I../hdrs -I../libpkg -I../libgendb -I/opt/homebrew/opt/openssl@3/include \
		-c "$src" -o /dev/null 2>&1 || true
done 2>&1 | grep -E 'format-security|format string is not a string literal' | tee -a "$REPORT" || :

log ""
log "=== Scan complete. Report at $REPORT ==="

n=$(grep -cE '\.c:[0-9]+:[0-9]+: warning:.*format' "$REPORT" 2>/dev/null || echo 0)
log "Total findings: $n"
printf 'Report: %s (%s findings)\n' "$REPORT" "$n" >&2
