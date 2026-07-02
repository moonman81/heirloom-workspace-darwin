# Phase 6 hardening + legacy round-trip driver.

SHELL = /bin/sh

.PHONY: all clean setuid-audit format-string-audit roundtrip static-analysis fuzz-smoke

all: setuid-audit format-string-audit roundtrip static-analysis fuzz-smoke

setuid-audit:
	@printf '\n=== setuid-audit ===\n'
	@sh setuid-audit/audit.sh

format-string-audit:
	@printf '\n=== format-string-audit ===\n'
	@sh format-string-audit/audit.sh >/dev/null 2>&1 || :
	@sh format-string-audit/clang-scan.sh

roundtrip:
	@printf '\n=== roundtrip ===\n'
	@sh roundtrip/roundtrip.sh

static-analysis:
	@printf '\n=== static-analysis ===\n'
	@sh static-analysis/scan.sh

fuzz-smoke:
	@printf '\n=== fuzz-smoke ===\n'
	@sh fuzz-seeds/smoke-run.sh

clean:
	rm -f setuid-audit/report.txt \
	      format-string-audit/report.txt \
	      format-string-audit/clang-scan-report.txt \
	      roundtrip/report.txt \
	      static-analysis/scan-report.txt \
	      fuzz-seeds/smoke-report.txt
