# Tests — index and how to run

Master pass: `bash scripts/run-all-tests.sh` runs the suites below and
writes `tests/master-test-run.txt`. Phase 9 result: **12 suites, 0
failed**. The first Phase 9 attempt scored 10/12; both failures were in
the master runner itself (system cargo 1.75 picked up by PATH — it
cannot read lock file version 4; and literal-space grep patterns
against HiGHS output). Both are fixed and commented in the script; no
subsystem failed in either attempt.

| Suite | Command | Record |
|---|---|---|
| Owner seed (Python reference) | `bash monster_bridge/scripts/test.sh` | scan/xml/validate 4 records, PASS |
| XML v2 validator | `bash schemas/run_tests.sh` | schemas/test-output.txt — 7/7 |
| Contract checkers | `bash contracts/run_checks.sh` | contracts/check-output.txt — 28 items |
| Coverage optimization | `bash ampl/run_coverage.sh` | ampl/coverage-run.txt — solver = brute force |
| HiGHS verification model | `highs ampl/verification/workload.lp` | ampl/verification/highs-run.txt — Optimal, 27 |
| Curry resolution | `bash curry/resolution/run.sh` | curry/resolution/outputs/ — Curry = checker |
| Curry toolchain battery (Phase 1) | see reports/toolchain-curry.md | curry/battery/outputs/ — 7/7 §3 items |
| Alloy counterexamples | `bash alloy/run_all.sh` | alloy/results.txt — 41 commands |
| Lean build | `cd lean && lake build` | proofs/lean-build-log.txt, proofs/axioms.txt |
| Uiua kernels | `bash uiua/run_all.sh` | uiua/outputs/ — 17/17 cross-checks |
| Wolfram / Mathics3 | `bash wolfram/run.sh` | wolfram/outputs/ — PASS |
| Rust unit tests | `cd rust && cargo test` | 14 passed, 0 failed |
| Rust differential test | `bash scripts/difftest.sh` | DIFFTEST PASS, 8/8 |

Not in the master pass (recorded evidence stands): the 1,050,000-line
corpus benchmark (benchmarks/corpus-benchmark.txt) — the synthetic
corpus regenerates byte-identically from corpus/gen_synthetic.py, so
the recorded run remains the measurement of record.
