#!/bin/sh
#
# audit.sh — grep-based first-pass detection of format-string CWE-134
# (Use of Externally-Controlled Format String) across the whole
# Heirloom source tree.
#
# The pattern this catches:
#     printf-family calls where the format-string argument is a
#     variable rather than a string literal, especially variables
#     that flow from argv[], environ, stdin, or on-disk config.
#
# The check is conservative — every hit is a candidate, not
# necessarily a bug. Manual triage judges intent.

set -eu

ROOT=${ROOT:-/Volumes/heirloom/src}
REPORT=/Volumes/heirloom/src/hardening/format-string-audit/report.txt

: > "$REPORT"

log() { printf '%s\n' "$*" >>"$REPORT"; }
log_screen() { printf '%s\n' "$*" >>"$REPORT"; printf '%s\n' "$*" >&2; }

log "=== Heirloom printf-family format-string audit ==="
log "Root:   $ROOT"
log "Date:   $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
log ""

# Match printf-family calls whose FIRST argument is NOT a string literal.
# printf(x, y)          — x is variable
# fprintf(fp, x, y)     — 2nd is variable format
# sprintf(buf, x, y)    — 2nd
# snprintf(buf, sz, x, y) — 3rd
# syslog(pri, x, y)     — 2nd
#
# Legitimate case: the format string is a compile-time constant
# reached via a #define; those are safe. Heuristic: bare identifier
# with no adjacent " ; treat as candidate.

log "--- Suspect printf(<var>, ...) sites ---"
grep -rnEH '\b(printf|fprintf|sprintf|snprintf|syslog|pfmt|vpfmt|warnx|errx|warn|err|dprintf|asprintf|vasprintf)[[:space:]]*\(' \
	--include='*.c' \
	"$ROOT/sh" "$ROOT/devtools" "$ROOT/toolchest" \
	"$ROOT/doctools" "$ROOT/pkgtools" 2>/dev/null \
	| grep -vE '"[^"]*%[^"]*"|,[[:space:]]*"' \
	| grep -vE '/\*|^[^:]+:[0-9]+:[[:space:]]*\*' \
	| head -50 \
	| tee -a "$REPORT"
log ""

log "--- Total candidate count: $(grep -rEH '\b(printf|fprintf|sprintf|snprintf|syslog|pfmt|vpfmt)[[:space:]]*\(' \
	--include='*.c' \
	"$ROOT/sh" "$ROOT/devtools" "$ROOT/toolchest" "$ROOT/doctools" "$ROOT/pkgtools" 2>/dev/null \
	| grep -vE '"[^"]*%[^"]*"|,[[:space:]]*"' \
	| wc -l | tr -d ' ') ---"

log ""

log "--- Non-literal error-report family (rarely used with attacker-controlled data but audit anyway) ---"
grep -rn 'errprint\|failure\|fatal' --include='*.c' "$ROOT/sh" "$ROOT/devtools" "$ROOT/toolchest" \
	2>/dev/null | grep -vE '"[^"]*%[^"]*"|,[[:space:]]*"' | grep -vE '/\*|^[^:]+:[0-9]+:[[:space:]]*\*' | head -20 | tee -a "$REPORT"

log ""
log "=== Report written to $REPORT ==="
printf 'Report: %s\n' "$REPORT" >&2
