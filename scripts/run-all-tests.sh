#!/bin/bash
# Master test pass for MONSTER-BRIDGE (Phase 9).
# Runs every subsystem suite, records exit codes and wall times, and writes
# the transcript to tests/master-test-run.txt. A failing suite is recorded
# as FAILED with its exit code; the run continues and the final exit code
# is nonzero if any suite failed. Nothing is skipped silently: suites not
# re-run here are listed at the end with the reason and their recorded
# evidence location.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/tests/master-test-run.txt"
export PATH="$HOME/.cargo/bin:$HOME/.elan/bin:$HOME/workspace/.tools/jdk-21.0.12.1+1/bin:$HOME/workspace/.tools/highs/bin:$HOME/workspace/.tools/pakcs-3.9.0/bin:$PATH"
# NOTE: $HOME/.cargo/bin must precede /usr/bin — the system cargo is 1.75
# and cannot read this project's lock file (version 4); the rustup cargo
# is 1.99. The Phase 9 first pass failed exactly there; this ordering is
# the fix, recorded here so the failure is not repeated.
mkdir -p "$ROOT/tests"
: > "$OUT"
FAILURES=0
TOTAL=0

run_suite() {
  local name="$1"; shift
  local start end rc
  TOTAL=$((TOTAL+1))
  echo "===== SUITE: $name =====" >> "$OUT"
  echo "CMD: $*" >> "$OUT"
  start=$(date +%s)
  "$@" >> "$OUT" 2>&1
  rc=$?
  end=$(date +%s)
  echo "----- $name: exit=$rc wall=$((end-start))s -----" >> "$OUT"
  if [ $rc -ne 0 ]; then FAILURES=$((FAILURES+1)); fi
}

cd "$ROOT"
run_suite "seed-python-reference" bash monster_bridge/scripts/test.sh
run_suite "xml-v2-validator" bash schemas/run_tests.sh
run_suite "contracts-checkers" bash contracts/run_checks.sh
run_suite "coverage-optimization" bash ampl/run_coverage.sh
run_suite "highs-verification-model" bash -c 'highs ampl/verification/workload.lp > /tmp/highs-master.txt 2>&1; grep -Eq "Status +Optimal" /tmp/highs-master.txt && grep -Eq "Primal bound +27" /tmp/highs-master.txt'
run_suite "curry-resolution" bash curry/resolution/run.sh
run_suite "alloy-counterexamples" bash alloy/run_all.sh
run_suite "lean-build" bash -c 'cd lean && lake build'
run_suite "uiua-kernels" bash uiua/run_all.sh
run_suite "wolfram-mathics" bash wolfram/run.sh
run_suite "rust-cargo-test" bash -c 'cd rust && cargo test'
run_suite "rust-difftest" bash scripts/difftest.sh

{
  echo "===== NOT RE-RUN IN THIS PASS (recorded evidence stands) ====="
  echo "corpus-1M-benchmark: benchmarks/corpus-benchmark.txt (38.97s, recall exact); corpus regenerates byte-identically from corpus/gen_synthetic.py seed 20261031, so the recorded benchmark remains the measurement of record."
  echo "curry-battery: curry/battery/outputs/ + reports/toolchain-curry.md (Phase 1 battery, 7/7); Curry is exercised end-to-end in this pass by the curry-resolution suite."
  echo "===== SUMMARY ====="
  echo "suites run: $TOTAL, failed: $FAILURES"
} >> "$OUT"
cat "$OUT"
[ $FAILURES -eq 0 ]
