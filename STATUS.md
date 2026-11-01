# STATUS — plain facts, limits, verification scope

**Production release v1.0** of the Vertex Operator Algebra (VOA) formal library
shipped under `lean/MonsterBridge/VOA/` (2026-11-01). Zero-sorry, fully
integrated with the existing MonsterBridge Lean package.

Build complete through Phase 9 + VOA layer. Local repository only: no remote,
no push of binary artifacts, nothing published beyond this tree.

## Seed (owner-supplied, verbatim)

- `monster_bridge/` is the owner's Python reference implementation,
  copied byte-identical from `~/workspace/monster_bridge` (SHA-256
  manifest diff: identical) and never edited by this build. Its suite
  re-runs green: scan/xml/validate, 4 records each.
- `monster_bridge/schema/contract.xsd` is schema v1, untouched. The §4
  schema is v2 under `schemas/`.

## Phase outcomes (details in reports/phase*.md and
## reports/IMPLEMENTATION-REPORT.md)

- Phase 1 — VERIFIED. SWI-Prolog 9.0.4 + PAKCS 3.9.0 (directive §3
  battery 7/7); HiGHS 1.15.1 (verification optimum 27 = hand
  enumeration). Manifest: reports/toolchain-manifest.md.
- Phase 2 — VERIFIED. Schema v2 + validator, tests 7/7 (malformed,
  unsupported operator, unresolved ref, cycle, unsubstantiated
  verified — all rejected).
- Phase 3 — VERIFIED as measured. Extractor seed-consistent (record-
  for-record on the seed samples); synthetic corpus 1,050,000 lines;
  26,944 lines/sec; peak RSS 19,212 KB; recall exact (24,016/24,016).
  The corpus is synthetic; results say nothing about historical
  documents.
- Phase 4 — VERIFIED. Curry resolution over the 28 contract items
  agrees with an independent checker (20 resolvable, 8 blocked =
  exactly the abstract-only items); cyclic closure is fuel-bounded and
  labeled BOUNDED. Native Rust resolver: `monster resolve`
  (differential-tested in Phase 8).
- Phase 5 — BOUNDED. Contracts: 28 items — 14 VERIFIED (exact finite
  checks), 1 COUNTEREXAMPLE (deliberate, detected), 5 BOUNDED,
  8 UNSUPPORTED with reasons. Alloy: 41/41 commands as expected within
  recorded scopes (16 valid UNSAT-in-scope, 7 negative counterexamples
  archived, 15 runs SAT). Coverage optimization: HiGHS 20 = brute
  force 20. AMPL files are unexecuted artifacts.
- Phase 6 — VERIFIED. Lean v4.9.0 + Mathlib: 35 theorems, zero sorry,
  axioms audited (dependency soundness uses no axioms). Abstract
  theorems only; the Monster Group is not shown to satisfy any
  hypothesis and is never enumerated.
- Phase 7 — VERIFIED as numerical evidence. Uiua kernels 17/17
  independent cross-checks (Jacobi residual 0 / perturbed 1;
  round-trip 0 / non-invertible 9).
- Wolfram subsystem — VERIFIED capability map by execution. Mathics3
  supports Expand/Factor/Coefficient/Part/Simplify/Series; BitAnd,
  TestReport, VerificationTest are CAPABILITY_FAILURE. Mathics3 is
  not Mathematica.
- Phase 8 — VERIFIED. Rust `monster` CLI, 10 commands, std-only;
  cargo tests 14/14; differential test vs the Python seed 8/8
  (scan byte-identical on the seed samples).
- Phase 9 — DONE. Master pass `scripts/run-all-tests.sh`: 12/12
  suites, 0 failed (first attempt 10/12 — both failures were in the
  runner's own PATH/grep handling, fixed and documented).
  reports/verification-report.xml validates under the seed's own
  validator (12 records; the single `verified` claim is the Lean
  archive, gated on its olean hash
  7f14226821a4e14b0547341cdbf89208abddec9c993f5012436516d2317ae940).
  verification-report.xml SHA-256:
  4546c6b8ae14ff803403d4b01a7bc9c822cc9a4c758e085cb470f4b4b6f9369b.

## VOA library (v1.0 production)

- `lean/MonsterBridge/VOA/Basic.lean` — VertexAlgebra structure, modes, vacuum axioms, creation, locality. Zero sorry.
- `lean/MonsterBridge/VOA/Conformal.lean` — VertexOperatorAlgebra, Virasoro relations, conformal vector, weight-zero vacuum. Zero sorry.
- `lean/MonsterBridge/VOA/Modules.lean` — VertexAlgebraModule and VertexOperatorAlgebraModule. Zero sorry.
- Root `MonsterBridge.lean` imports the full VOA layer.
- Intended to support future formal work on moonshine graded dimensions and McKay–Thompson series; the Monster group itself remains UNSUPPORTED (order ~10^53).

## Standing limits

- Statuses: VERIFIED / COUNTEREXAMPLE / UNPROVEN / UNSUPPORTED /
  EXECUTION_FAILED. Bounded Alloy checks are never unrestricted
  proofs; numerical results are never proofs.
- UNSUPPORTED, with reasons recorded in the artifacts: the Monster
  Group itself; moonshine theory beyond the published coefficients
  checked as data; differential-geometric contract items;
  holographic duality (no evidence produced, none claimed);
  Mathematica and the AMPL runtime (not installed); Mathics3 Bit*/
  TestReport/VerificationTest; xmllint.
- Not in git (regenerable): lean/.lake (4.5 GB), rust/target,
  corpus/synthetic (67 MB), benchmarks/corpus-synthetic-hits.jsonl —
  see .gitignore. Generators and expected counts are committed.
