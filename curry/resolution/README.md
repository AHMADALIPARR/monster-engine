# Phase 4 — Curry dependency resolution over the contract claims

Curry programs (PAKCS 3.9.0, SWI-Prolog backend) that perform
dependency resolution over the claim graph of
`contracts/families.json`, with derivation trees and provenance:
every derived claim identifies the clauses and substitutions used.

## Files

- `gen_facts.py` — reads `contracts/families.json` and generates
  `Facts.curry`: one `item "<id>" "<family>" "<kind>"` fact per item
  (28 items) and one `dependsOn "<item>" "<dependency>"` fact per
  `depends_on` edge (22 edges), using the exact ids and kinds in
  `families.json`.
- `Facts.curry` — generated facts (do not edit by hand).
- `Resolve.curry` — the Horn-clause resolution program (below).
- `MoonshineChain.curry` — auxiliary Horn facts mirroring the named
  moonshine claim chain of
  `counterexamples/moonshine_dependencies.json` /
  `alloy/moonshine_dependencies.als`: `JCoeff2` depends on
  `JCoeff1`, `McKayDecomp` depends on `JCoeff2`, `GradedDim`
  depends on `McKayDecomp`. In the primary corpus the same chain
  appears under the `MOON` family ids (`MOON-j-coeffs` →
  `MOON-mckay-identity` / `MOON-character-decomposition` →
  `MOON-partition-constraints`).
- `FactsCyclic.curry` — a separate, deliberately cyclic fact set
  (`a` depends on `b`, `b` depends on `a`) used only for the
  fuel-bounded closure demonstration. `families.json` itself is a
  DAG.
- `run.sh` — generates the facts, runs `Resolve.curry` in the PAKCS
  REPL batch mode used by the Phase 1 battery
  (`printf ":load Resolve\nmain\n:quit\n" | pakcs`), captures the
  raw session to `outputs/resolve-output.txt`, and runs the checker.
- `check.py` — independent checker (plain Python graph algorithms
  over `families.json`); see below.
- `outputs/resolve-output.txt`, `outputs/check-output.txt` — raw
  outputs of the last `run.sh` run.

## Clause inventory (Resolve.curry)

- `dependsTrans-base` — `dependsTrans x y` if `dependsOn x y`.
- `dependsTrans-step` — `dependsTrans x z` if `dependsOn x y` and
  `dependsTrans y z` (intermediate `y` a free logic variable).
- `checkable` — an item is checkable if its `families.json` kind is
  not `"abstract-only"`.
- `blocked-base` — an item is blocked if it is abstract-only.
- `blocked-step` — an item is blocked if it `dependsOn` a blocked
  item. Together these give exactly the abstract-only items plus
  everything that transitively depends on one.
- `resolvable-set` — resolvable = all items minus the blocked set.
  Negation-as-failure is done at the set level: the blocked set is
  derived by the positive Horn clauses above, enumerated with
  `getAllValues` (`Control.Search.AllValues`), and resolvable is
  its complement in the finite item set. No negation is used inside
  a clause body — a clause-level `not blocked x` guard would be
  evaluated under incomplete search and could succeed for the wrong
  reason, so the set formulation is the sound route.
- `derivation-base` — derivation of `resolvable(x)` when `x` is
  checkable with no dependencies: a single tree node.
- `derivation-step` — derivation of `resolvable(x)` when `x` is
  checkable with dependencies: a node whose children are the
  derivations of the dependencies.
- `moonTrans-base` / `moonTrans-step` — the same closure pattern
  over the auxiliary moonshine chain.
- `cycTransN-base` / `cycTransN-step` — the fuel-bounded closure
  (the Phase 1 battery's `reachN` pattern) over `FactsCyclic`.

Derivation trees are rose trees of nodes
`(item, clause-name, substitution, premise, children)`. The graph
is propositional over string ids, so the substitution recorded at
each node is the binding of the goal variable to that item id,
written `X := <id>`; the premise recorded is the item's kind fact.

## Results (as computed; Curry and independent checker agree)

Run: `./run.sh` (exit 0). Tallies:

- Items: 28. Edges: 22.
- BLOCKED: 8 — `GEO-holographic-scope`, `LIE-coordinate-compat`,
  `LIE-equivariance`, `LIE-tangent-space`, `MON-monster-abstract`,
  `MOON-mckay-thompson`, `MOON-modular-transform`,
  `MOON-partition-constraints`. All 8 are the abstract-only items
  themselves; in this corpus no checkable item depends, even
  transitively, on an abstract-only item, so `blocked-step` adds
  nothing beyond `blocked-base` — the checker recomputes the full
  fixpoint and confirms the same 8.
- RESOLVABLE: 20 (28 − 8).
- Transitive closures spot-checked: `MON-homomorphism` →
  {`MON-closure`, `MON-identity`}; `MON-character-compat` →
  {`MON-closure`, `MON-conjugacy`, `MON-identity`, `MON-inverses`}.
- Moonshine chain: transitive dependencies of `GradedDim` =
  {`JCoeff1`, `JCoeff2`, `McKayDecomp`}.

`check.py` recomputes the blocked set (fixpoint), the resolvable
set (complement), both transitive closures (DFS), and the
`MON-character-compat` derivation node set (item plus its transitive
dependencies) from `families.json` alone, parses the Curry program's
printed sets, and compares: all comparisons AGREE
(`outputs/check-output.txt`); it exits nonzero on any mismatch
(verified against a deliberately altered copy of the output, which
it rejected with exit 1).

## Derivation tree example

For `MON-character-compat` (three levels; verbatim from
`outputs/resolve-output.txt`):

```
NODE item=MON-character-compat clause=derivation-step subst="X := MON-character-compat" premise="kind=data-check (item fact)"
  NODE item=MON-conjugacy clause=derivation-step subst="X := MON-conjugacy" premise="kind=finite-check (item fact)"
    NODE item=MON-closure clause=derivation-base subst="X := MON-closure" premise="kind=finite-check (item fact)"
    NODE item=MON-inverses clause=derivation-step subst="X := MON-inverses" premise="kind=finite-check (item fact)"
      NODE item=MON-identity clause=derivation-base subst="X := MON-identity" premise="kind=finite-check (item fact)"
```

A second tree, for `GEO-reconstruction`, is printed in the same
output (nodes: `GEO-reconstruction`, `GEO-subdivision`,
`GEO-forward-inverse`, `GEO-tensor-shape`).

## Cyclic facts and bounded search

`families.json` is a DAG, so the unbounded `dependsTrans` terminates
there. On the separate cyclic facts (`a` ↔ `b`) the unbounded
closure would loop (the Phase 1 battery recorded exactly this for
its naive closure, killed by an external timeout). The fuel-bounded
closure with fuel 5 terminates and prints, labelled BOUNDED:

```
BOUNDED CYCLIC: cycTransN 5 from "a": ["b","a","b","a","b","a"]
```

— each reachable node once per distinct derivation path whose
length stays within the fuel bound (path lengths 1–6 along the
single outgoing edge at each node).

## Standing caveat

A derivation is only as trustworthy as its premises. The premises
here are the `families.json` classifications — which items are
`finite-check`, `data-check`, `identity-check`, or `abstract-only`,
and which items depend on which — and those classifications are
data recorded by the contracts workstream, not theorems. The Curry
program proves resolvability *relative to that data*: it shows that
an item's recorded dependency cone contains no abstract-only item,
citing the clause, substitution, and kind fact used at every step.
It does not prove the underlying mathematical claims, and a wrong
classification in `families.json` would flow through the derivation
unchallenged.
