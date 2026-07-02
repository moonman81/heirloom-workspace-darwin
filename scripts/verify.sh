#!/bin/sh
# verify.sh — post-lifecycle smoke test for heirloom-workspace
# Verifies every phase installed into $PREFIX end-to-end.
set -eu
PREFIX="${1:-/opt/heirloom}"

if tty >/dev/null 2>&1; then
	C_OK='\033[32m'; C_FAIL='\033[31m'; C_RESET='\033[0m'
else
	C_OK=''; C_FAIL=''; C_RESET=''
fi
ok()   { printf '  %b✓%b %s\n' "$C_OK" "$C_RESET" "$*"; }
fail() { printf '  %b✗ %s%b\n' "$C_FAIL" "$*" "$C_RESET"; exit 1; }

# All five packages: check flagship binaries
[ -x "$PREFIX/bin/sh" ]              || fail 'sh missing'         ; ok 'sh'
[ -x "$PREFIX/ccs/bin/yacc" ]        || fail 'devtools yacc miss' ; ok 'devtools/yacc'
[ -x "$PREFIX/bin/cpio" ]            || fail 'toolchest cpio miss'; ok 'toolchest/cpio'
[ -x "$PREFIX/bin/nroff" ]           || fail 'doctools nroff miss'; ok 'doctools/nroff'
[ -x "$PREFIX/bin/pkgadd" ]          || fail 'pkgtools pkgadd miss'; ok 'pkgtools/pkgadd'

# Prefix inventory
total=$(find "$PREFIX" -type f -perm +111 2>/dev/null | wc -l | tr -d ' ')
printf '  Prefix: %s (%s installed binaries)\n' "$PREFIX" "$total"

# Roundtrip suite from the workspace's hardening tree
if [ -x hardening/roundtrip/roundtrip.sh ]; then
	printf '  Running roundtrip suite ...\n'
	if sh hardening/roundtrip/roundtrip.sh >/dev/null 2>&1; then
		ok 'roundtrip suite (cpio × 3 + tar × 2 + SCCS + pkg + awk + ISO 8601)'
	else
		fail 'roundtrip suite failed'
	fi
fi

printf '%bverify: workspace lifecycle OK%b\n' "$C_OK" "$C_RESET"
