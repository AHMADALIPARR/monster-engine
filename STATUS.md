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
  the seed above is the preserved starting code. Scaffold committed locally
  (30fe7ba); no remote.
- Phase 1 (toolchain recovery): in progress — SWI-Prolog/PAKCS and HiGHS
  workstreams running. See `reports/toolchain-*.md` as they land.
- Phase 2 (XML v2): in progress.
- Phase 3 (corpus + synthetic benchmark): in progress.
- Phase 4 (logic): Curry programs wait on the Phase 1 PAKCS outcome; the
  native Rust resolver is part of Phase 8.
- Phase 5 (contracts + Alloy): both halves in progress.
- Phase 6 (Lean): in progress.
- Phase 7 (Uiua): in progress.
- Phase 8 (Rust CLI): in progress.
- Phase 9 (benchmarks + final report): pending all subsystem results.
- Wolfram/Mathics3 subsystem: in progress.

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
