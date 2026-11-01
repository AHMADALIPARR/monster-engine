# STATUS — plain facts, limits, verification scope

Last updated: build start (Phase 0 complete, Phase 1 in progress).

## Seed (owner-supplied, verbatim)

- `monster_bridge/` is the owner's Python reference implementation, copied
  byte-identical from `~/workspace/monster_bridge` (SHA-256 manifest diff:
  identical). It is never edited by this build.
- Its test suite runs green from this location: scan 4 records, xml 4
  records, validate 4 records, domains {moonshine, monster, lie}.
- `monster_bridge/schema/contract.xsd` is schema v1. The directive §4
  schema is authored separately as v2 under `schemas/`; v1 stays untouched.

## Phase states

- Phase 0 (audit): done. No pre-existing monster-engine repository existed;
  the seed above is the preserved starting code.
- Phase 1 (toolchain recovery): in progress. See `reports/toolchain-manifest.md`.
- Phases 2–9: pending, in directive §15 order.

## Standing limits

- Local repository only. No remote, no push, nothing published.
- Statuses used: VERIFIED / COUNTEREXAMPLE / UNPROVEN / UNSUPPORTED /
  EXECUTION_FAILED. A bounded Alloy check is never reported as an
  unrestricted proof. A numerical result is never reported as a proof.
- AMPL is not installed. Models in `ampl/` are AMPL-format artifacts and
  are not executed by an AMPL runtime.
- Mathics3 is not Mathematica. Unsupported Wolfram operations produce
  explicit capability failures.
- No claim is made that the Monster Group satisfies any hypothesis proved
  abstractly in Lean, and the Monster Group is never enumerated.
