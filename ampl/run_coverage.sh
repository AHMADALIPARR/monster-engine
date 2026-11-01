#!/bin/sh
# Idempotent runner for the dependency-coverage model.
# Re-running this script regenerates ampl/coverage-run.txt from
# scratch: it runs the brute-force enumeration (coverage_brute.py,
# which also cross-checks coverage.lp against its task table), then,
# if a HiGHS binary is available, solves coverage.lp with HiGHS and
# verifies that the solver objective equals the brute-force optimum.
# Exits nonzero if the two optima disagree or the brute force fails.
# If HiGHS is not available, the run is written as PENDING and the
# script still exits 0 so it can simply be re-run after installation.
set -u
cd "$(dirname "$0")"

HIGHS=""
if [ -n "${HIGHS_BIN:-}" ] && [ -x "${HIGHS_BIN}" ]; then
    HIGHS="${HIGHS_BIN}"
elif [ -x "$HOME/workspace/.tools/highs/bin/highs" ]; then
    HIGHS="$HOME/workspace/.tools/highs/bin/highs"
elif command -v highs >/dev/null 2>&1; then
    HIGHS="$(command -v highs)"
fi

TMPDIR_WORK="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_WORK"' EXIT

python3 coverage_brute.py > "$TMPDIR_WORK/brute.txt" 2>&1
brute_status=$?
if [ "$brute_status" -ne 0 ]; then
    {
        echo "coverage run: brute-force enumeration FAILED (exit $brute_status)"
        cat "$TMPDIR_WORK/brute.txt"
    } > coverage-run.txt
    cat coverage-run.txt
    exit 1
fi
BRUTE_OPT="$(sed -n 's/^brute-force optimum cost: //p' "$TMPDIR_WORK/brute.txt")"

if [ -z "$HIGHS" ]; then
    {
        echo "coverage run: PENDING -- HiGHS binary not found."
        echo "Re-run ampl/run_coverage.sh after installing HiGHS to solve coverage.lp."
        echo ""
        echo "--- brute force (ampl/coverage_brute.py) ---"
        cat "$TMPDIR_WORK/brute.txt"
    } > coverage-run.txt
    cat coverage-run.txt
    exit 0
fi

"$HIGHS" coverage.lp > "$TMPDIR_WORK/highs.txt" 2>&1
highs_status=$?
SOLVER_OBJ="$(sed -n 's/^[[:space:]]*Primal bound[[:space:]]*//p' "$TMPDIR_WORK/highs.txt" | head -n 1 | tr -d ' ')"
SOLVER_INT="$(printf '%s' "$SOLVER_OBJ" | sed 's/\..*//')"

{
    echo "coverage run: HiGHS binary: $HIGHS (exit $highs_status)"
    echo ""
    echo "--- brute force (ampl/coverage_brute.py) ---"
    cat "$TMPDIR_WORK/brute.txt"
    echo ""
    echo "--- HiGHS output (ampl/coverage.lp) ---"
    cat "$TMPDIR_WORK/highs.txt"
    echo ""
    if [ "$highs_status" -eq 0 ] && [ -n "$SOLVER_INT" ] && [ "$SOLVER_INT" = "$BRUTE_OPT" ]; then
        echo "agreement: solver objective $SOLVER_OBJ equals brute-force optimum $BRUTE_OPT"
    else
        echo "agreement: MISMATCH solver objective '$SOLVER_OBJ' vs brute-force optimum '$BRUTE_OPT'"
    fi
} > coverage-run.txt
cat coverage-run.txt

if [ "$highs_status" -ne 0 ] || [ -z "$SOLVER_INT" ] || [ "$SOLVER_INT" != "$BRUTE_OPT" ]; then
    exit 1
fi
exit 0
