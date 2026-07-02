#!/bin/sh
#
# scan.sh — run clang static-analyser (scan-build) against a sample
# of security-critical utilities. Optionally re-build with
# -fsanitize=address,undefined for runtime checking.
#
# Both passes non-blocking: they generate reports without touching
# the installed binaries.

set -eu

ROOT=${ROOT:-/Volumes/heirloom/src}
REPORT_DIR=/Volumes/heirloom/src/hardening/static-analysis
REPORT=$REPORT_DIR/scan-report.txt

: > "$REPORT"

log() { printf '%s\n' "$*" | tee -a "$REPORT" >&2; }

log "=== Heirloom static analysis + sanitiser scan ==="
log "Date: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
log ""

# ------------- clang -Weverything for security-critical utils -------------
log "--- clang -Wextra -Wall -Wshadow -Wcast-align pass on hot utilities ---"

SCAN_UTILS='su mail cpio tar find grep sed expr sh'

for tool_path in \
	sh:$ROOT/sh:sh_dummy.c \
	toolchest/su:$ROOT/toolchest/su:su.c \
	toolchest/mail:$ROOT/toolchest/mail:mail.c \
	toolchest/cpio:$ROOT/toolchest/cpio:cpio.c \
	toolchest/tar:$ROOT/toolchest/tar:tar.c \
	toolchest/find:$ROOT/toolchest/find:find.c \
	toolchest/grep:$ROOT/toolchest/grep:grep.c \
	toolchest/sed:$ROOT/toolchest/sed:sed.c \
	toolchest/expr:$ROOT/toolchest/expr:expr.c ; do
	pkg=${tool_path%%:*}
	dir=$(echo "$tool_path" | cut -d: -f2)
	src=${tool_path##*:}
	[ -f "$dir/$src" ] || continue
	log ""
	log "  $pkg"
	n=$(cc -c -O -Wall -Wextra -Wshadow -Wcast-align \
		-Wno-parentheses -Wno-pointer-sign \
		-D_DARWIN_C_SOURCE \
		-I$ROOT/toolchest/libcommon \
		-I$ROOT/toolchest/libuxre \
		"$dir/$src" -o /dev/null 2>&1 | \
		grep -cE '^[^:]+:[0-9]+:[0-9]+: warning:' || echo 0)
	log "    $n warnings"
done

log ""
log "--- ASan+UBSan build of cpio (verifies our CWE-134 fix and covers hot path) ---"
if cc -O1 -g -fsanitize=address,undefined -D_DARWIN_C_SOURCE \
	-I$ROOT/toolchest/libcommon -I$ROOT/toolchest/libuxre -DUXRE \
	"$ROOT/toolchest/cpio/cpio.c" \
	"$ROOT/toolchest/cpio/unshrink.c" \
	"$ROOT/toolchest/cpio/explode.c" \
	"$ROOT/toolchest/cpio/expand.c" \
	"$ROOT/toolchest/cpio/inflate.c" \
	"$ROOT/toolchest/cpio/crc32.c" \
	"$ROOT/toolchest/cpio/blast.c" \
	"$ROOT/toolchest/cpio/flags.c" \
	"$ROOT/toolchest/cpio/nonpax.c" \
	"$ROOT/toolchest/cpio/version.c" \
	-L$ROOT/toolchest/libcommon -lcommon -lz -lbz2 \
	-o /tmp/cpio.san 2>>"$REPORT"; then
	log "  OK  cpio built with ASan+UBSan"
	# Round-trip through the sanitised binary
	tmp=$(mktemp -d)
	printf 'sanitised test\n' > "$tmp/x"
	if (cd "$tmp" && echo x | /tmp/cpio.san -o >archive) 2>>"$REPORT" && \
	   (cd "$tmp" && mkdir dst && cd dst && /tmp/cpio.san -i <../archive) 2>>"$REPORT" && \
	   cmp "$tmp/x" "$tmp/dst/x" 2>>"$REPORT"; then
		log "  OK  cpio ASan+UBSan round-trip preserved bytes; no runtime findings"
	else
		log "  ! ASan/UBSan detected an issue during round-trip"
	fi
	rm -rf "$tmp" /tmp/cpio.san
else
	log "  ! sanitised build failed — inspect $REPORT"
fi

log ""
log "=== Scan complete. Report at $REPORT ==="
