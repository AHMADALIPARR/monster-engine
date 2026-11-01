#!/bin/sh
# Run the contract checkers and save one line per contract id to
# contracts/check-output.txt. Exits nonzero if any actual outcome
# differs from the expected outcome encoded in check_contracts.py
# (the deliberate non-homomorphism item's expectation is that the
# homomorphism property FAILS, reported as COUNTEREXAMPLE).
set -u
cd "$(dirname "$0")"
python3 check_contracts.py > check-output.txt
status=$?
cat check-output.txt
if [ "$status" -ne 0 ]; then
    echo "run_checks: checker reported an unexpected outcome (exit $status)" >&2
fi
exit "$status"
