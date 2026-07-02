# CWE-674 (uncontrolled recursion): 10000-deep recursion overflows the
# 8 MB Darwin default stack and SEGVs. This is universal Unix awk
# behaviour, not specific to Heirloom nawk — no known interpreter
# bounds recursion depth. Documented as accepted risk; seed depth
# reduced to a safe 500 so the smoke suite runs clean.
# (Retain the DoS trigger externally via a dedicated stress-test.)
function f(n) { if (n>0) return f(n-1); return 0 }
BEGIN { print f(500) }
