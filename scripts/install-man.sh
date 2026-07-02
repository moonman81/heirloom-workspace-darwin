#!/bin/sh
# install-man.sh — install workspace-repo man pages under PREFIX.
set -eu
PREFIX="${1:-/opt/heirloom}"
[ -d man ] || exit 0

MANDIR="$PREFIX/share/man"
if [ ! -w "$(dirname "$MANDIR")" ] 2>/dev/null && [ ! -d "$MANDIR" ]; then
	printf 'install-man: cannot write %s — skipping\n' "$MANDIR" >&2
	exit 0
fi

for section_dir in man/man*/; do
	[ -d "$section_dir" ] || continue
	section=$(basename "$section_dir")
	mkdir -p "$MANDIR/$section"
	for page in "$section_dir"*.[0-9] "$section_dir"*.[0-9][a-z]; do
		[ -f "$page" ] || continue
		cp "$page" "$MANDIR/$section/"
	done
done

if [ -f HOWTO.md ]; then
	mkdir -p "$PREFIX/share/doc/heirloom-workspace"
	cp HOWTO.md "$PREFIX/share/doc/heirloom-workspace/HOWTO.md"
	if [ -f PORT.md ]; then
		cp PORT.md "$PREFIX/share/doc/heirloom-workspace/PORT.md"
	fi
	if [ -d hardening ]; then
		mkdir -p "$PREFIX/share/doc/heirloom-workspace/hardening"
		cp -R hardening/COVERAGE-MATRIX.md hardening/README.md \
		    "$PREFIX/share/doc/heirloom-workspace/hardening/" 2>/dev/null || true
	fi
fi

printf 'install-man: workspace docs installed under %s\n' "$MANDIR" >&2
