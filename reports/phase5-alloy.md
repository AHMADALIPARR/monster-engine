# Phase 5 (Alloy half) — bounded models and counterexample archive

Status: complete. All 41 commands executed; every command's actual
result matched its expected result (41/41). No model required debugging
against its expectation — the first full run of the suite already
produced the expected pattern everywhere.

## Tooling

- Alloy 6 jar: `~/workspace/hcalc-counter/alloy.jar` (21 MB, build dated
  2025-01-09), JDK 21 (`~/workspace/.tools/jdk-21.0.12.1+1`).
- Headless driver: `alloy/driver/RunAlloy.java` (deliverable). It parses
  each file with `CompUtil.parseEverything_fromFile`, executes each
  command with `TranslateAlloyToKodkod.execute_command` using
  `opt.solver = kodkod.engine.satlab.SATFactory.DEFAULT` (this build's
  API), and prints per command: label, kind (check/run), scope, result
  (SAT/UNSAT), elapsed ms, and — for SAT results — a compact instance
  summary (atoms per signature, tuples per field). (In this build
  `A4Solution.eval` returns `A4TupleSet`; the driver uses that type.)
- Runner: `alloy/run_all.sh` compiles the driver once and runs all
  twelve modules, writing `alloy/results.txt`. Full suite: 40,457 ms of
  solver time, ~57 s wall including JVM start-up and compilation.
- Raw results: `alloy/results.txt`. Archive: `counterexamples/INDEX.md`
  plus one JSON per module file in `counterexamples/`.

## Reading of results

Bounded results only. A check returning UNSAT means "no counterexample
within the recorded scope", nothing more; it is not an unrestricted
proof. A check returning SAT is a counterexample within scope, and its
instance summary is archived. All modules are finite abstractions; none
makes a claim about the actual Monster group.

## Per-module tally

| module file | commands | checks | runs | solver ms | expected vs actual |
|---|---|---|---|---|---|
| group_action.als | 4 | 3 UNSAT | 1 SAT | 2,492 | all as expected |
| group_action_bad.als | 3 | 1 SAT, 1 UNSAT | 1 SAT | 2,197 | all as expected |
| representation_composition.als | 3 | 2 UNSAT | 1 SAT | 3,563 | all as expected |
| representation_composition_bad.als | 2 | 1 SAT | 1 SAT | 2,672 | all as expected |
| moonshine_dependencies.als | 4 | 2 UNSAT | 2 SAT | 1,500 | all as expected |
| moonshine_dependencies_bad.als | 3 | 2 SAT | 1 SAT | 1,358 | all as expected |
| lie_algebra_abstraction.als | 4 | 3 UNSAT | 1 SAT | 8,296 | all as expected |
| lie_algebra_abstraction_bad.als | 3 | 1 SAT, 1 UNSAT | 1 SAT | 8,234 | all as expected |
| geometry_contracts.als | 5 | 3 UNSAT | 2 SAT | 5,329 | all as expected |
| geometry_contracts_bad.als | 2 | 1 SAT | 1 SAT | 1,979 | all as expected |
| verification_states.als | 5 | 3 UNSAT | 2 SAT | 1,533 | all as expected |
| verification_states_bad.als | 3 | 1 SAT, 1 UNSAT | 1 SAT | 1,304 | all as expected |
| **total** | **41** | **26** | **15** | **40,457** | **41/41 match** |

Aggregate: valid-form checks 16/16 UNSAT; negative targeted checks 7/7
SAT (counterexample found); negative sanity checks 3/3 UNSAT; runs
15/15 SAT.

## Module notes

1. **group_action** — abstract finite G with an operation table and
   identity, S with an action table; facts are the group axioms and the
   two action axioms. Assertions: identity fixes points, composition
   compatibility, and bijectivity of each element's action (the one
   genuine consequence, via inverses). Scope 3. Negative: composition
   axiom omitted; the returned counterexample has G = 3 atoms and S = 2
   atoms — a generator acting as a transposition while its square acts
   trivially. The identity check stays UNSAT in the bad module, as
   designed.

2. **representation_composition** — homomorphisms between finite magmas
   (operation tables, no associativity or identity axioms anywhere);
   h is defined as g ∘ f. Composition-of-homomorphisms is a pure
   equational consequence and checks UNSAT at scope 3, as does the
   triple-product corollary. Negative: f, g imposed homomorphic, h
   unconstrained; the check finds tables and a non-homomorphic h
   (EA = 2, EB = 3, EC = 2 atoms).

3. **moonshine_dependencies** — fixed chain JCoeff1 ← JCoeff2 ←
   McKayDecomp ← GradedDim; the fact is the direct consistency rule (an
   Established claim may not depend directly on a Conjecture claim);
   the assertions are the transitive forms, which follow. Negative: no
   consistency fact, with the inconsistent labeling injected
   (JCoeff1 = Conjecture, JCoeff2 = Established); both the direct and
   transitive checks return that labeling as counterexample.

4. **lie_algebra_abstraction** — sl(2) over F5, basis {H, E, F} plus a
   zero element Z; the full 4x4 bracket table (target + coefficient,
   coefficients as representatives in {−2..2}) is pinned by facts:
   [H,E] = 2E, [H,F] = −2F, [E,F] = H. Double brackets are evaluated by
   bilinearity on basis triples; antisymmetry, self-bracket, and Jacobi
   all check UNSAT (6-bit integers; products ≤ 4, component sums ≤ 12,
   no overflow). Negative: one independent structure constant perturbed,
   kk[H][E]: 2 → 1 (with its antisymmetric partner kk[E][H]: −2 → −1 so
   antisymmetry is preserved — its check stays UNSAT). For this target
   pattern the independent Jacobi component on (H, E, F) along H is
   c·(a + b) with a = kk[H][E], b = kk[H][F], c = kk[E][F]: genuine
   sl(2) gives 1·(2 − 2) = 0, the perturbed table gives 1·(1 − 2) = −1,
   and the Jacobi check returns the pinned perturbed table as
   counterexample. (Perturbing kk[E][F] alone would not have worked: it
   multiplies a + b = 0.)

5. **geometry_contracts** — cell forest with integer measures; the sum
   rule is a fact for internal cells. Assertions checked as
   consequences: the two-level unfolding (grandparent measure = sum of
   grandchildren) and root conservation (root measure = sum of leaf
   measures beneath it), both UNSAT at 5 cells / 6-bit ints; plus
   forward/inverse transform round trips from the inverse-relation
   definition. Negative: sum rule omitted; the check finds a 3-cell
   subdivision whose children do not sum to the parent.

6. **verification_states** — ordered traces (util/ordering) over
   statuses {Candidate, Bounded, Verified, Rejected}; each state
   carries at most one formal-proof evidence record. Facts: initial
   state is Candidate, steps follow AllowedStep, and every entered
   Verified state carries evidence (the owner's rule). Assertions:
   Verified always carries evidence, Rejected is absorbing, Verified
   never regresses — all UNSAT at 4 states. Negative: evidence rule
   omitted; the check finds a 4-state trace reaching Verified without
   evidence, while RejectedIsAbsorbing stays UNSAT.

## Limits

- Scopes are small by design (3–5 atoms per signature, 6-bit integers
  where integers occur); UNSAT results are bounded to those scopes.
- The Lie module checks Jacobi and antisymmetry for basis triples under
  the bilinear extension encoded in the model; it does not quantify
  over all coefficient vectors of the algebra.
- Instance summaries record atom and tuple counts per signature/field,
  not full tuple listings.
