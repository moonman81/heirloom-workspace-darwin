#!/bin/sh
#
# install-suid.sh — apply the setuid / setgid bits that the Toolchest
# heirloom.pkg target intends. Requires sudo.
#
# Refuses to run under any user other than root; refuses to touch a
# binary that is not on the intent list. Idempotent.

set -eu

PREFIX=${PREFIX:-/opt/heirloom}

if [ "$(id -u)" -ne 0 ]; then
	printf 'must run as root (try: sudo %s)\n' "$0" >&2
	exit 1
fi

# tool:mode:owner:group
INTENT='
su:4755:root:wheel
ps:4755:root:wheel
shl:2755:root:wheel
'

printf '%s\n' "$INTENT" | while IFS=: read tool mode owner group; do
	[ -z "$tool" ] && continue
	target="$PREFIX/bin/$tool"
	if [ ! -f "$target" ]; then
		printf 'skip:   %s (not installed)\n' "$target" >&2
		continue
	fi
	chown "$owner:$group" "$target"
	chmod "$mode" "$target"
	printf 'apply:  %s mode=%s owner=%s:%s\n' "$target" "$mode" "$owner" "$group" >&2
done

printf '\nfinal state:\n' >&2
ls -la "$PREFIX/bin/su" "$PREFIX/bin/ps" "$PREFIX/bin/shl" 2>&1 | sed 's/^/  /' >&2
