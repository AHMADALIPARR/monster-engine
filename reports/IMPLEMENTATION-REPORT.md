# MONSTER-BRIDGE — Implementation Report

This report separates, for every subsystem: results that are VERIFIED
(formal proof or exact finite checks with independent confirmation),
BOUNDED checks (true only within a recorded scope), NUMERICAL evidence
(measurements and floating-point or finite-instance computations), and
UNRESOLVED items. Nothing in the second, third, or fourth category is
promoted into the first. Status vocabulary: VERIFIED / COUNTEREXAMPLE /
UNPROVEN / UNSUPPORTED / EXECUTION_FAILED (directive §13).

Repository: local only, no remote, no push. Owner's seed preserved
byte-identical at `monster_bridge/` (SHA-256 manifest diff at Phase 0:
identical; its suite re-runs green: scan/xml/validate, 4 records each).

## Master verification pass (Phase 9)

`scripts/run-all-tests.sh` re-ran 12 subsystem suites end-to-end:
**12 passed, 0 failed** (transcript: `tests/master-test-run.txt`).
First attempt scored 10/12; both failures were faults in the master
runner itself, not in any subsystem: (1) the runner's PATH picked up the
system cargo 1.75, which cannot read the project's lock file version 4 —
fixed by putting the rustup cargo 1.99 first; (2) literal-space grep
patterns against HiGHS output — fixed to whitespace-flexible patterns.
Both fixes are commented in the script. Suites not re-run in the master
pass (recorded evidence stands, reasons in the transcript): the
1,050,000-line corpus benchmark (corpus regenerates byte-identically)
and the Phase 1 Curry battery (Curry is exercised end-to-end by the
resolution suite).

## VERIFIED

- **Lean proofs** (`lean/MonsterBridge/`, pinned Lean v4.9.0 + Mathlib
  v4.9.0): `lake build` succeeds; 35 theorems; zero `sorry`/`admit`
  (grep-audited). Contents: group-action laws and consequences
  (g • (g⁻¹ • x) = x; fixed-by-g ⇒ fixed-by-g⁻¹) both via Mathlib's
  MulAction and via a hand-rolled action structure; representation
  composition laws (7 lemmas); bracket consequences from stated
  antisymmetry/Jacobi hypotheses — headline ⟦x,x⟧ + ⟦x,x⟧ = 0, and
  ⟦x,x⟧ = 0 only under an explicit no-2-torsion hypothesis; and the
  dependency-model soundness theorem: along any dependency path, ranks
  strictly increase, hence no cycle of any length exists in a rankable
  model. Axiom audit (`proofs/axioms.txt`): headline theorems use at
  most `propext` / `Quot.sound`; the dependency-model theorem uses **no
  axioms**. These are abstract theorems. Nothing here establishes that
  the Monster Group satisfies their hypotheses, and no such claim is
  made anywhere in this repository.
- **Exact finite contract checks** (`contracts/check_contracts.py`,
  rational/integer arithmetic): S3 group axioms by exhaustion
  (closure 36/36, associativity 216/216, identity/inverses 6/6), sign
  homomorphism 36/36, character orthonormality and conjugacy-class
  sizes [1,2,3] for S3, so(3) antisymmetry 9/9 and Jacobi 27/27 with
  max residual exactly 0, C4 action composition 64/64. Moonshine data
  checks: the published J coefficients {744, 196884, 21493760,
  864299970} and McKay's 196884 = 196883 + 1 verified as data equality;
  the dimension decomposition of 864299970 recorded in the checker is
  2·1 + 2·196883 + 21296876 + 842609326 (an earlier draft decomposition
  summed to 864103086 and the checker correctly failed it — the harness
  catching a wrong constant is part of the evidence).
- **Curry toolchain battery** (PAKCS 3.9.0 on SWI-Prolog 9.0.4): all
  seven directive §3 items executed — startup, unification with free
  variables, recursive Horn clauses, nondeterministic alternatives,
  recursive backtracking, occurs-check behavior (observed: finite
  failure on all three probes; no mechanism claimed beyond the
  observation), cyclic goals with fuel-bounded search.
- **Curry dependency resolution**: resolvable/blocked classification of
  all 28 contract items agrees between the Curry program and an
  independent Python checker (20 resolvable; the 8 blocked are exactly
  the abstract-only items); derivation trees cite clause names and
  substitutions; fuel-bounded closure over a cyclic fact base
  terminates with a result labeled BOUNDED.
- **HiGHS verification model**: solver Status Optimal, objective 27,
  equal to the independent hand enumeration (unique optimum {t1,t2,t4}).
- **Rust differential test**: the `monster` CLI's scan output is
  byte-identical to the owner's Python reference on the seed samples
  (reproducing the shipped hits.jsonl exactly) and record-identical on
  a 17-record adversarial tree; both validators cross-accept; cargo
  tests 14/14.
- **XML v2 validator tests**: 7/7, including rejection of malformed
  XML, unsupported operators, unresolved references, dependency
  cycles (new in v2), and unsubstantiated `verified` status.
- **Corpus extraction recall**: on the synthetic benchmark corpus,
  extracted hits equal planted hits exactly, per family
  (24,016 = 24,016).

## BOUNDED checks (true within the recorded scope only)

- **Alloy** (`alloy/`, `counterexamples/`): 41 commands; 16 valid-form
  checks UNSAT *within their scopes* (no counterexample in scope —
  explicitly not unrestricted proofs); 7 negative checks SAT with
  archived counterexample instances (broken group-action composition,
  non-homomorphic "representations", inconsistent moonshine dependency
  labeling, a Jacobi failure in sl(2) over F5 from one perturbed
  structure constant, a non-conserving subdivision, and a
  verified-without-evidence state trace — the owner's gate, caught);
  15/15 runs SAT. Scopes, times, and instance summaries are in
  `counterexamples/INDEX.md`.
- **Contract checkers' BOUNDED items** (5): GEO family concrete
  instances (dyadic subdivision conservation, shear round-trip,
  reconstruction residual, rank preservation) — exact on those
  instances, evidence about the contract shape, not the general claim.
- **Seed reference**: the owner's validator checks metadata structure,
  not proof validity — as its own README states.

## NUMERICAL evidence (measurements, not proofs)

- Corpus benchmark (SYNTHETIC corpus, 1,050,000 lines, 69,623,312
  bytes, seed 20261031): 38.97 s wall, 26,944 lines/sec, peak RSS
  19,212 KB, on this shared VM (45% CPU, 4 cores). Says nothing about
  historical documents.
- Uiua kernels (0.19.1; 17/17 independent Python cross-checks): so(3)
  Jacobi max residual 0, perturbed 1; permutation round-trip residual
  0, non-invertible projection residual 9; Klein-four composition
  residuals 0 with an out-of-group contrast of 3; J-coefficient
  arithmetic exact in float64 range (< 2^53), as documented. Full
  suite 0.57 s.
- Optimization: verification-coverage instance (12 tasks, 20 covering
  constraints): HiGHS optimum 20 = brute-force optimum 20 over all
  4,096 subsets. Optimization prioritizes work; it certifies nothing
  mathematical.
- Mathics3 symbolic outputs (Expand/Factor/Simplify/Series evaluated;
  J-coefficient ratios as exact rationals) — computer-algebra results
  from Mathics3 10.0.1, not Mathematica, and not proofs.

## UNSUPPORTED / UNPROVEN — stated plainly

- **UNSUPPORTED (abstract-only contract items, 8)**: the Monster Group
  itself (no enumeration, no direct check), modular transformation
  identities, McKay–Thompson theory beyond the concrete published
  coefficients, partition-function constraints, tangent-space
  consistency, equivariance and coordinate compatibility in the
  differential-geometric sense, and the holographic-duality scope
  item. Each carries its reason in `contracts/families.json`.
- **UNSUPPORTED (tools)**: Mathematica/Wolfram Engine (not installed);
  AMPL runtime (not installed — .mod files are unexecuted artifacts);
  Mathics3 operations BitAnd, TestReport, VerificationTest (return
  unevaluated; the wolfram subsystem reports them as
  CAPABILITY_FAILURE); xmllint (absent; XSD well-formedness checked
  via Python).
- **UNPROVEN (research questions left open by design)**: whether any
  extracted candidate invariant corresponds to a real theorem;
  moonshine relationships beyond the established published data
  checked here; holographic duality (no evidence produced, none
  claimed); the Curry derivations are only as trustworthy as the
  `families.json` classifications they consume, which are data.

## Deviations recorded during the build

- SWI-Prolog was installed from the Ubuntu noble .deb set already
  present on the VM rather than the Debian bookworm pool (the VM is
  Ubuntu 24.04 and the noble dependencies match it); the bookworm pool
  was checked and the substitution is documented in
  reports/toolchain-curry.md.
- The Lean project's dependency packages were copied from the
  Mathlib-verified testbed (identical manifest/revisions) after a
  fresh clone proved impractically slow; `lake exe cache get` and
  `lake build` were then the prescribed commands unmodified
  (proofs/lean-build-log.txt).
- The synthetic corpus and its hits file (67 MB / 7.9 MB) are excluded
  from git via .gitignore; the generator, seed, and expected counts
  are committed and regeneration is byte-identical.

## Reproducing

`bash scripts/run-all-tests.sh` re-runs the subsystem suites.
Per-subsystem instructions: schemas/run_tests.sh, contracts/run_checks.sh,
ampl/run_coverage.sh, curry/resolution/run.sh, alloy/run_all.sh,
uiua/run_all.sh, wolfram/run.sh, scripts/difftest.sh, and
`cd lean && lake build`. Toolchain: reports/toolchain-manifest.md.
Machine-readable counterpart of this report:
reports/verification-report.xml (validated by the seed's own
validator).
