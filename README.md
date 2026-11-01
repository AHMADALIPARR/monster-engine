# MONSTER-BRIDGE — Mathematical Discovery Engine

A deterministic, XML-first engine for mathematical research on Monstrous
Moonshine, Monster Group symmetries, Lie groups and manifolds, modular
forms, and recursive geometry. It ingests mathematical source material,
extracts candidate structures into a versioned XML contract format,
resolves dependency relationships, searches for counterexamples in bounded
models, and verifies selected claims formally.

## Components

- `monster_bridge/` — the original Python reference: a non-evaluating,
  streaming lexical scanner (`scan`), XML exporter (`xml`), and contract
  validator (`validate`). Raw extracted text is always a candidate, never
  a theorem; a `verified` status requires formal-proof evidence with a
  SHA-256 artifact reference.
- `schemas/` — the versioned XML contract schemas (v1 in the seed, v2 in
  `schemas/` carrying the full field set: normalized expressions, operator
  signatures, assumptions and scopes, candidate invariants, dependency
  edges, counterexample evidence, proof references, residuals, toolchain
  versions, source hashes).
- `curry/` — Horn-clause resolution over contract claims (PAKCS when
  available; a native Rust resolver otherwise, labeled as such).
- `alloy/` + `counterexamples/` — Alloy 6 bounded models for finite group
  actions, representation composition, moonshine dependency consistency,
  Lie-algebra abstractions, recursive geometry contracts, and
  verification-state transitions, with counterexample archives recording
  scope, result, and instance.
- `lean/` + `proofs/` — Lean 4 / Mathlib proofs of abstract group-action
  and representation laws, bracket identities from stated hypotheses, and
  soundness of the finite dependency model.
- `uiua/` — Uiua array kernels: Jacobi residuals, J-coefficient
  arithmetic, reversible coordinate transforms, equivariance residuals.
- `ampl/` — AMPL-format optimization models (artifacts; not executed by
  an AMPL runtime). Optimization runs on HiGHS.
- `rust/` — the `monster` command-line engine: scan, normalize, classify,
  resolve, contract, counterexample, verify, evaluate, report, doctor.
- `wolfram/` — Mathics3 symbolic normalization scripts with explicit
  capability failures for unsupported operations.
- `corpus/`, `benchmarks/`, `reports/` — corpus material (synthetic
  benchmark data is labeled synthetic), measured benchmarks, and the
  verification reports.

## Verification vocabulary

Every subsystem reports one of: VERIFIED, COUNTEREXAMPLE, UNPROVEN,
UNSUPPORTED, EXECUTION_FAILED. Bounded checks and numerical evidence are
reported as what they are and are never promoted to proofs.

License: see `LICENSE`.
