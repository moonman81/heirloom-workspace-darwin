#!/bin/sh
#
# smoke-run.sh — run every seed through its parser once. Any exit-by-
# signal (SIGSEGV, SIGABRT, SIGFPE, SIGBUS) is a finding.
#
# Not fuzzing — this just confirms the seeds are well-formed enough
# to feed AFL later. Real fuzzing uses `afl-fuzz -i <corpus>`.

set -u
# NB: no `set -e` — a parser exiting nonzero for a malformed seed is
# expected data, not a script failure. We evaluate rc explicitly to
# distinguish exit-by-signal (finding) from exit-by-status (fine).

PREFIX=${PREFIX:-/opt/heirloom}
SEEDS=/Volumes/heirloom/src/hardening/fuzz-seeds
REPORT=$SEEDS/smoke-report.txt
: > "$REPORT"

log() { printf '%s\n' "$*" | tee -a "$REPORT" >&2; }
FAILURES=0

run_seed() {
	tool="$1"; seed="$2"; mode="$3"
	# mode: file (parser -f seed), stdin (parser <seed), text (parser 'seed' text)
	case "$mode" in
		file)   $tool -f "$seed" </dev/null >/dev/null 2>>"$REPORT" ;;
		stdin)  $tool <"$seed"      >/dev/null 2>>"$REPORT" ;;
		text)   $tool "$(cat "$seed")" </dev/null >/dev/null 2>>"$REPORT" ;;
	esac
	rc=$?
	# rc >= 128 → signal
	if [ $rc -ge 128 ]; then
		log "  FAIL $seed (signal $((rc-128)))"
		FAILURES=$((FAILURES+1))
	fi
	return 0
}

log "=== Fuzz-seed smoke run ==="
log "Date: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
log ""

# nawk
log "--- nawk ---"
for s in $SEEDS/nawk/*.awk; do
	run_seed "$PREFIX/bin/posix2001/awk" "$s" file
done

# oawk
log "--- oawk ---"
for s in $SEEDS/oawk/*.awk; do
	run_seed "$PREFIX/bin/awk" "$s" file
done

# bc
log "--- bc ---"
for s in $SEEDS/bc/*.bc; do
	run_seed "$PREFIX/bin/bc" "$s" stdin
done

# dc
log "--- dc ---"
for s in $SEEDS/dc/*.dc; do
	run_seed "$PREFIX/bin/dc" "$s" stdin
done

# expr (each line one invocation; skip for now — 'text' mode requires arg-parsing)
log "--- expr (skipping — arg-parsed, needs bespoke runner) ---"

# ed
log "--- ed ---"
for s in $SEEDS/ed/*.ed; do
	run_seed "$PREFIX/bin/ed" "$s" stdin
done

# sed (script files via -f)
log "--- sed ---"
for s in $SEEDS/sed/*.sed; do
	printf 'foo bar baz\naaa\n' | $PREFIX/bin/sed -f "$s" >/dev/null 2>>"$REPORT"
	rc=$?
	if [ $rc -ge 128 ]; then
		log "  FAIL $s (signal $((rc-128)))"
		FAILURES=$((FAILURES+1))
	fi
done

log ""
log "=== Summary ==="
log "Failures: $FAILURES"
log "Report: $REPORT"

exit $FAILURES
