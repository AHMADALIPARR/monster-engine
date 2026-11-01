# Counterexample archive — MONSTER-BRIDGE Phase 5 (Alloy)

This archive records every command executed by `alloy/run_all.sh` (Alloy 6,
jar build dated 2025-01-09, headless driver `alloy/driver/RunAlloy.java`,
solver `SATFactory.DEFAULT`) over the twelve model files in `alloy/`:
six valid-form modules and their six deliberate negative (`_bad`)
variants. Per-module machine-readable records are in the JSON files
beside this index (`<module>.json`); the raw driver output is in
`alloy/results.txt`.

## What these results mean — read this first

**These are bounded results within the recorded scopes, not unrestricted
proofs.** A check that returned UNSAT means exactly "no counterexample
exists within the recorded scope" — nothing more. It does not establish
the assertion for larger scopes or in general. A check that returned SAT
means a concrete counterexample instance exists within the recorded
scope; for those, a textual instance summary (atoms per signature,
tuples per field) is recorded below and in the JSON files. A run that
returned SAT means an instance of the predicate exists within scope;
UNSAT on a run means none does within scope.

All models are finite abstractions over unnamed finite sets, finite
operation/action/bracket tables, a fixed four-node claim DAG, finite
cell trees, and finite traces. **No model makes any claim about the
actual Monster group.**

## Tally of this run

- Commands executed: 41 (26 checks, 15 runs). Total solver time:
  40,457 ms; whole suite wall time under one minute plus JVM start-up.
- Valid-form modules: all 16 checks UNSAT (no counterexample within
  scope), all 9 runs SAT (instances found — the premises are not
  vacuous).
- Negative variants: all 7 targeted checks SAT (counterexample found, as
  required), all 3 sanity checks UNSAT (the deliberately retained axioms
  still hold in the broken modules), all 6 runs SAT.

Every command's actual result matched its expected result.

## Per-module records

### geometry_contracts.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| TwoLevelSum | check | overall<=5, Int=6bits | UNSAT | 1965 | UNSAT |
| RootMeasureEqualsLeafTotal | check | overall<=5, Int=6bits | UNSAT | 1798 | UNSAT |
| TransformRoundTrips | check | overall<=5, Int=6bits | UNSAT | 467 | UNSAT |
| ShowSubdivision | run | overall<=5, Int=6bits | SAT | 621 | SAT |
| ShowNontrivialTransform | run | overall<=5, Int=6bits | SAT | 478 | SAT |

### geometry_contracts_bad.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| ChildrenSumToParent | check | overall<=4, Int=6bits | SAT | 1694 | SAT |
| BadSubdivision | run | overall<=4, Int=6bits | SAT | 285 | SAT |

Counterexample instance for check `ChildrenSumToParent` (atoms per signature, tuples per field): Cell=3, Cell.children=2, Cell.measure=3

### group_action.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| IdentityFixesPoints | check | overall<=3, Int=4(default)bits | UNSAT | 1585 | UNSAT |
| CompositionCompatible | check | overall<=3, Int=4(default)bits | UNSAT | 394 | UNSAT |
| EachElementActsBijectively | check | overall<=3, Int=4(default)bits | UNSAT | 305 | UNSAT |
| ShowNontrivialAction | run | overall<=3, Int=4(default)bits | SAT | 208 | SAT |

### group_action_bad.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| IdentityFixesPoints | check | overall<=3, Int=4(default)bits | UNSAT | 1396 | UNSAT |
| CompositionCompatible | check | overall<=3, Int=4(default)bits | SAT | 505 | SAT |
| BrokenAction | run | overall<=3, Int=4(default)bits | SAT | 296 | SAT |

Counterexample instance for check `CompositionCompatible` (atoms per signature, tuples per field): G=3, S=2, Act=1, Act.e=1, Act.mul=9, Act.act=6

Reading of this counterexample: a 3-element group (9 multiplication
tuples = a full 3x3 table) acting on a 2-element set (6 action tuples) —
the shape of a generator acting as a transposition while its square
acts trivially, which the identity axiom permits and the (omitted)
composition axiom would forbid.

### lie_algebra_abstraction.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| BracketAntisymmetric | check | overall<=4, Int=6bits | UNSAT | 3993 | UNSAT |
| BracketWithSelfIsZero | check | overall<=4, Int=6bits | UNSAT | 1309 | UNSAT |
| JacobiIdentity | check | overall<=4, Int=6bits | UNSAT | 1907 | UNSAT |
| ShowSl2Table | run | overall<=4, Int=6bits | SAT | 1087 | SAT |

### lie_algebra_abstraction_bad.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| BracketAntisymmetric | check | overall<=4, Int=6bits | UNSAT | 4225 | UNSAT |
| JacobiIdentity | check | overall<=4, Int=6bits | SAT | 2197 | SAT |
| ShowPerturbedEntry | run | overall<=4, Int=6bits | SAT | 1812 | SAT |

Counterexample instance for check `JacobiIdentity` (atoms per signature, tuples per field): Basis=4, H=1, E=1, F=1, Z=1, Alg=1, Alg.brT=16, Alg.brK=16

Reading of this counterexample: the bracket table is fully pinned by
facts (16 target entries and 16 coefficient entries = the complete
4x4 table over {H, E, F, Z}), so the counterexample is the perturbed
table itself — the single independent structure constant kk[H][E]
changed from 2 to 1 (partner kk[E][H] from -2 to -1) makes the Jacobi
component on (H, E, F) along H equal 1 * (1 + (-2)) = -1 instead of 0.

### moonshine_dependencies.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| TransitiveConsistency | check | overall<=4, Int=4(default)bits | UNSAT | 1004 | UNSAT |
| ConjectureNeverSupportsEstablished | check | overall<=4, Int=4(default)bits | UNSAT | 126 | UNSAT |
| ShowAllEstablished | run | overall<=4, Int=4(default)bits | SAT | 190 | SAT |
| ShowMixedConsistent | run | overall<=4, Int=4(default)bits | SAT | 180 | SAT |

### moonshine_dependencies_bad.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| DirectConsistency | check | overall<=4, Int=4(default)bits | SAT | 1082 | SAT |
| TransitiveConsistency | check | overall<=4, Int=4(default)bits | SAT | 170 | SAT |
| InconsistentLabeling | run | overall<=4, Int=4(default)bits | SAT | 106 | SAT |

Counterexample instance for check `DirectConsistency` (atoms per signature, tuples per field): Claim=4, JCoeff1=1, JCoeff2=1, McKayDecomp=1, GradedDim=1, Status=2, Established=1, Conjecture=1, Labeling=1, Claim.dependsOn=3, Labeling.status=4

Counterexample instance for check `TransitiveConsistency` (atoms per signature, tuples per field): Claim=4, JCoeff1=1, JCoeff2=1, McKayDecomp=1, GradedDim=1, Status=2, Established=1, Conjecture=1, Labeling=1, Claim.dependsOn=3, Labeling.status=4

Reading of these counterexamples: the injected labeling itself —
JCoeff1 labeled Conjecture, JCoeff2 (which depends on it) labeled
Established, over the fixed 3-edge dependency chain.

### representation_composition.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| CompositionOfHomomorphismsIsHomomorphism | check | overall<=3, Int=4(default)bits | UNSAT | 2181 | UNSAT |
| HomomorphismPreservesTripleProducts | check | overall<=3, Int=4(default)bits | UNSAT | 985 | UNSAT |
| ShowHomomorphisms | run | overall<=3, Int=4(default)bits | SAT | 397 | SAT |

### representation_composition_bad.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| CompositionOfHomomorphismsIsHomomorphism | check | overall<=3, Int=4(default)bits | SAT | 2177 | SAT |
| NonHomomorphicClaimedMap | run | overall<=3, Int=4(default)bits | SAT | 495 | SAT |

Counterexample instance for check `CompositionOfHomomorphismsIsHomomorphism` (atoms per signature, tuples per field): EA=2, EB=3, EC=2, MA=1, MB=1, MC=1, Maps=1, MA.op=4, MB.op=9, MC.op=4, Maps.f=2, Maps.g=3, Maps.h=2

Reading of this counterexample: full operation tables on EA (2x2),
EB (3x3), EC (2x2) with homomorphic f (2 tuples) and g (3 tuples), but
the claimed composite h (2 tuples) does not preserve the tables — it is
not the composition and not a homomorphism.

### verification_states.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| VerifiedAlwaysCarriesEvidence | check | overall<=4, Int=4(default)bits | UNSAT | 1119 | UNSAT |
| RejectedIsAbsorbing | check | overall<=4, Int=4(default)bits | UNSAT | 190 | UNSAT |
| VerifiedNeverRegresses | check | overall<=4, Int=4(default)bits | UNSAT | 29 | UNSAT |
| ShowVerifiedTrace | run | overall<=4, Int=4(default)bits | SAT | 100 | SAT |
| ShowRejectedTrace | run | overall<=4, Int=4(default)bits | SAT | 95 | SAT |

### verification_states_bad.als

| command | kind | scope | result | ms | expected |
|---|---|---|---|---|---|
| VerifiedAlwaysCarriesEvidence | check | overall<=4, Int=4(default)bits | SAT | 1012 | SAT |
| RejectedIsAbsorbing | check | overall<=4, Int=4(default)bits | UNSAT | 114 | UNSAT |
| VerifiedWithoutEvidence | run | overall<=4, Int=4(default)bits | SAT | 178 | SAT |

Counterexample instance for check `VerifiedAlwaysCarriesEvidence` (atoms per signature, tuples per field): Status=4, Candidate=1, Bounded=1, Verified=1, Rejected=1, Proof=1, State=4, ordering/Ord=1, State.status=4, State.evidence=3, ordering/Ord.Next=3

Reading of this counterexample: a 4-state ordered trace (3 Next tuples)
in which some state carries the Verified status while the trace's
evidence assignments (3 evidence tuples over 4 states) leave that state
without a formal-proof record — possible only because the bad module
omits the owner's evidence rule. (The summary in `alloy/results.txt`
additionally lists the ordering module's First tuple.)
