# Phase 4 — Curry recursive search programs (dependency resolution)

Section owner: Phase 4 run, 2026-11-01.
Directive §7. All results below were produced by executing the named
commands on this VM in this run. Programs and outputs live in
`curry/resolution/`; the Phase 1 battery in `curry/battery/` was not
touched, and neither was `monster_bridge/`.

## Tooling

- PAKCS 3.9.0 at `~/workspace/.tools/pakcs-3.9.0/bin/pakcs`, SWI-Prolog
  9.0.4 backend (`/usr/bin/swipl`) — the toolchain verified in
  `reports/toolchain-curry.md`.
- Invocation pattern, taken from the battery: REPL batch mode,
  `printf ":load Resolve\nmain\n:quit\n" | pakcs`, with nondeterministic
  searches encapsulated by `getAllValues` from
  `Control.Search.AllValues` inside the IO `main`. Environment:
  `PATH` including the PAKCS `bin/`, `LC_ALL=C.UTF-8`.

## What was built

- `curry/resolution/gen_facts.py` — generator: reads the real claim
  graph, `contracts/families.json`, and emits `Facts.curry` with one
  fact per item (`item "MON-closure" "MON" "finite-check"` — id,
  family, kind, exactly as in `families.json`) and one fact per
  `depends_on` edge (`dependsOn "MON-associativity" "MON-closure"`).
  Generated file: 28 item facts, 22 edge facts.
- `curry/resolution/Resolve.curry` — Horn-clause resolution over the
  facts (clause inventory below), derivation trees with provenance.
- `curry/resolution/MoonshineChain.curry` — auxiliary Horn facts
  mirroring the moonshine claim chain of
  `counterexamples/moonshine_dependencies.json` /
  `alloy/moonshine_dependencies.als`: `JCoeff2` dependsOn `JCoeff1`,
  `McKayDecomp` dependsOn `JCoeff2`, `GradedDim` dependsOn
  `McKayDecomp`. (The task text's "JCoefficients →
  McKayDecomposition, JCoefficients → GradedDimensions" is this
  chain; the node names used are the Alloy model's own. In the
  primary corpus the same chain is the MOON family:
  `MOON-j-coeffs` → `MOON-mckay-identity` /
  `MOON-character-decomposition` → `MOON-partition-constraints`.)
- `curry/resolution/FactsCyclic.curry` — separate cyclic facts
  (`a` dependsOn `b`, `b` dependsOn `a`) for the bounded-search
  demonstration.
- `curry/resolution/run.sh` — generate facts, run the program,
  capture `outputs/resolve-output.txt`, run the checker into
  `outputs/check-output.txt`. Exit 0 in this run.
- `curry/resolution/check.py` — independent checker: recomputes
  everything from `families.json` with plain graph algorithms and
  compares against the Curry program's printed sets; exits nonzero
  on any mismatch.

## Clause inventory

Each Horn clause in `Resolve.curry` is named, and every printed
derived claim cites its clause:

- `dependsTrans-base`: `dependsTrans x y` if `dependsOn x y`.
- `dependsTrans-step`: `dependsTrans x z` if `dependsOn x y` and
  `dependsTrans y z`, intermediate `y` a free logic variable.
- `checkable`: kind (per `families.json`) is not `"abstract-only"`.
- `blocked-base`: an abstract-only item is blocked.
- `blocked-step`: an item that `dependsOn` a blocked item is blocked.
- `resolvable-set`: resolvable = all items − blocked set.
- `derivation-base`: `resolvable(x)` derivation for checkable `x`
  with no dependencies — a single node.
- `derivation-step`: `resolvable(x)` derivation for checkable `x`
  with dependencies — a node whose children are the dependencies'
  derivations.
- `moonTrans-base` / `moonTrans-step`: closure over the auxiliary
  moonshine chain.
- `cycTransN-base` / `cycTransN-step`: fuel-bounded closure over the
  cyclic facts (the battery's `reachN` pattern).

On negation: `resolvable` is *not* implemented as a clause-level
`not blocked x`. That guard would be evaluated under Curry's
incomplete search and is the unsound route. Instead the blocked set
is derived by the positive clauses `blocked-base`/`blocked-step`,
enumerated in full with `getAllValues`, and resolvable is its
complement in the finite item set — negation-as-failure at the set
level, over a completely computed set.

Provenance/substitutions: derivation trees are rose trees of nodes
`(item, clause-name, substitution, premise, children)`. The graph
is propositional over string ids, so the substitution at each node
is the binding of the goal variable to that id, recorded explicitly
as `X := <id>`; the premise is the item's kind fact.

## Results (executed this run; Curry vs independent checker)

`./run.sh` exit 0; checker output (`outputs/check-output.txt`):
ALL 28/28 AGREE, BLOCKED 8/8 AGREE, RESOLVABLE 20/20 AGREE,
TRANS MON-homomorphism 2/2 AGREE, TRANS MON-character-compat 4/4
AGREE, DERIVATION-NODES MON-character-compat 5/5 AGREE,
DERIVATION-CLAUSES AGREE, MOONCHAIN TRANS GradedDim 3/3 AGREE,
BOUNDED CYCLIC line present AGREE — `check: ALL COMPARISONS AGREE`.
A negative test (one id in a copy of the output altered) made the
checker report the mismatches and exit 1, as designed.

Tallies over the 28 items / 22 edges of `families.json`:

- BLOCKED (8): `GEO-holographic-scope`, `LIE-coordinate-compat`,
  `LIE-equivariance`, `LIE-tangent-space`, `MON-monster-abstract`,
  `MOON-mckay-thompson`, `MOON-modular-transform`,
  `MOON-partition-constraints` — exactly the abstract-only items.
  In this corpus no checkable item depends, even transitively, on an
  abstract-only item, so `blocked-step` contributes no further
  items; the checker's independent fixpoint computation confirms
  the same set, so this is a property of the data, not an artifact
  of either implementation.
- RESOLVABLE (20): the remaining items — all MON finite/data checks
  except the abstract Monster item, `MOON-j-coeffs`,
  `MOON-mckay-identity`, `MOON-character-decomposition`, the LIE
  `so(3)`/finite-action checks, and the bounded GEO checks.
- Transitive closures printed: `MON-homomorphism` →
  {`MON-closure`, `MON-identity`}; `MON-character-compat` →
  {`MON-closure`, `MON-conjugacy`, `MON-identity`, `MON-inverses`};
  moonshine chain `GradedDim` → {`JCoeff1`, `JCoeff2`, `McKayDecomp`}.

Derivation trees are printed for two resolvable items. The
multi-level one, `MON-character-compat` (verbatim from
`outputs/resolve-output.txt`):

```
NODE item=MON-character-compat clause=derivation-step subst="X := MON-character-compat" premise="kind=data-check (item fact)"
  NODE item=MON-conjugacy clause=derivation-step subst="X := MON-conjugacy" premise="kind=finite-check (item fact)"
    NODE item=MON-closure clause=derivation-base subst="X := MON-closure" premise="kind=finite-check (item fact)"
    NODE item=MON-inverses clause=derivation-step subst="X := MON-inverses" premise="kind=finite-check (item fact)"
      NODE item=MON-identity clause=derivation-base subst="X := MON-identity" premise="kind=finite-check (item fact)"
```

The second tree is for `GEO-reconstruction` (nodes
`GEO-reconstruction`, `GEO-subdivision`, `GEO-forward-inverse`,
`GEO-tensor-shape`).

## Cyclic facts: bounded behaviour

`families.json` is a DAG (acyclicity is enforced by the contracts
schema validator), so `dependsTrans` terminates on the real corpus.
On the separate cyclic facts the unbounded closure loops — the
Phase 1 battery recorded the same behaviour for its naive closure
(killed by an external timeout, exit 124). The fuel-bounded closure
`cycTransN` with fuel 5 terminates in the same run and prints,
labelled BOUNDED:

```
BOUNDED CYCLIC: cycTransN 5 from "a": ["b","a","b","a","b","a"]
```

Each reachable node appears once per distinct derivation path
within the bound (path lengths 1–6 on the a↔b cycle). This is a
bounded result: it enumerates paths up to the fuel bound, nothing
more.

Compiler output note: the raw session in
`outputs/resolve-output.txt` carries the same frontend warnings the
battery recorded for this relational style (non-exhaustive fact
patterns; relational functions potentially non-deterministic due to
overlapping rules). They are expected and do not affect the results.

## Standing caveat

A derivation is only as trustworthy as its premises — and the
premises here are the `families.json` classifications, which are
data, not theorems. What the Curry program establishes is
resolvability *relative to the recorded data*: that an item's
recorded dependency cone contains no abstract-only item, with the
clause, substitution, and kind fact cited at every step. It does
not prove any underlying mathematical claim, and a misclassification
in `families.json` would pass through the derivation unchallenged.

Status: Phase 4 — VERIFIED by execution (`run.sh` exit 0, all
checker comparisons AGREE, negative test exits 1).
