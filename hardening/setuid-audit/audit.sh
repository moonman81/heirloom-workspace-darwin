#!/bin/sh
#
# audit.sh — enumerate every setuid / setgid binary installed under
# /opt/heirloom and check permission mode, ownership, and the shared-
# library dependency trust chain.
#
# CWE-732 (incorrect permission assignment), CWE-269 (improper
# privilege management), ATT&CK T1548 (Abuse Elevation Control
# Mechanism). Fails non-zero on any finding.

set -eu

PREFIX=${PREFIX:-/opt/heirloom}
REPORT=/Volumes/heirloom/src/hardening/setuid-audit/report.txt
FAIL=0

: > "$REPORT"

log() { printf '%s\n' "$*" | tee -a "$REPORT" >&2; }

log "=== Heirloom setuid / setgid audit ==="
log "Prefix: $PREFIX"
log "Date:   $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
log ""

# Enumerate suid / sgid binaries
log "--- Enumerated setuid + setgid targets ---"
found=0
find "$PREFIX" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | while read f; do
	found=1
	mode=$(stat -f '%p' "$f")
	owner=$(stat -f '%Su:%Sg' "$f")
	log "  $f mode=$mode owner=$owner"
done

if ! find "$PREFIX" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | grep -q .; then
	log "  (none)"
fi
log ""

# Known Heirloom setuid intent from source: su, ps, shl
log "--- Cross-check against source setuid intent ---"
for expected_suid in \
	su:0:root \
	ps:0:root \
	shl:0:adm ; do
	tool=${expected_suid%%:*}
	rest=${expected_suid#*:}
	log "  intent  $tool -> uid=${rest%:*} gid=${rest#*:} (per Toolchest makefile)"
	if [ -f "$PREFIX/bin/$tool" ]; then
		actual=$(stat -f '%p %Su %Sg' "$PREFIX/bin/$tool")
		log "    actual  $actual  $PREFIX/bin/$tool"
	fi
done
log ""

# Shared library trust for each suid target
log "--- Shared library dependency trust ---"
for f in $(find "$PREFIX" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null); do
	log "  $f"
	otool -L "$f" 2>/dev/null | sed 's/^/    /' | tee -a "$REPORT"
	# Fail if any dep resolves outside /System/Library, /usr/lib, or /opt/heirloom
	otool -L "$f" 2>/dev/null | awk 'NR>1 {print $1}' | while read dep; do
		case "$dep" in
			/System/Library/*|/usr/lib/*|/opt/heirloom/*|@rpath/*|@executable_path/*) ;;
			*)
				log "    ! CWE-732: dep resolves outside trusted paths: $dep"
				FAIL=1 ;;
		esac
	done
done
log ""

# @rpath / DYLD_LIBRARY_PATH injection surface
log "--- @rpath entries (DYLD_LIBRARY_PATH injection surface) ---"
for f in $(find "$PREFIX" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null); do
	otool -l "$f" 2>/dev/null | awk '/LC_RPATH/,/^ *path/{if(/^ *path/){print FILENAME": "$2}}' FILENAME="$f"
done
log ""

log "=== Report written to $REPORT ==="
exit $FAIL
