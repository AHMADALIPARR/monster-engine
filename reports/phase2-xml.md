# Phase 2 — XML schema v2, validator, typed-AST note

## What was built

All artifacts live under `schemas/`. The owner's seed under
`monster_bridge/` was not edited; its v1 schema and the `validate()`
semantics in `monster_bridge/src/bridge.py` were read and carried forward.

- `schemas/contract-v2.xsd` — schema version 2 (root `research`,
  `version` fixed to `"2"`). Per source document: `id`, `path`, `sha256`
  (64-hex pattern type), `title`, one or more `author` elements,
  `publication-date` (full date or year), `provenance`. Per claim:
  `original-expression` and `normalized-expression` (both required, both
  preserved), `domain` (enumeration: moonshine, monster, lie, geo,
  modular-forms, general), `operator-signatures`, `assumptions`,
  `variable-scopes`, `candidate-invariants`, `dependencies`,
  `evidence` (v1 shape: `tool` / `status` / `artifact_sha256` attributes
  plus a `details` child, with an added optional `kind`),
  `counterexample-evidence` (with directive section 13 report statuses
  VERIFIED / COUNTEREXAMPLE / UNPROVEN / UNSUPPORTED / EXECUTION_FAILED),
  `formal-proof-references`, `numerical-residuals`,
  `toolchain-versions`, `source-hashes`, and a `verification-report`
  using the same section 13 statuses. Claim status is the v1 enumeration
  candidate / rejected / bounded / verified.
- `schemas/validate_v2.py` — Python 3 standard-library validator.
  Exit 0 when valid; exit 1 with one specific error message on stderr
  when invalid.
- `schemas/TYPED-AST.md` — design note mapping the XML node elements
  (`number`, `symbol`, `apply`, `call`, `binder`) to AST types, the
  scope rules, why original and normalized expressions are both kept,
  and why XML strings are never executed.
- `schemas/examples/` — one valid document and five invalid documents,
  one per rejection class (malformed XML, unsupported operator,
  unresolved dependency, dependency cycle, unsubstantiated verified).
- `schemas/run_tests.sh` — runs the validator over all examples plus an
  XSD well-formedness check; output saved in `schemas/test-output.txt`.

## Test tally, as actually run

`schemas/run_tests.sh` run on this machine (Python 3.12.3; xmllint is
not installed, so the XSD check used ElementTree parsing, which the
script reports in its output):

```
PASS: contract-v2.xsd is well-formed XML (ElementTree; xmllint not installed)
PASS: valid-moonshine.xml validates
PASS: invalid-malformed.xml rejected with expected error class 'malformed XML'
PASS: invalid-unsupported-operator.xml rejected with expected error class 'unsupported operator'
PASS: invalid-unresolved-dependency.xml rejected with expected error class 'unresolved dependency'
PASS: invalid-dependency-cycle.xml rejected with expected error class 'dependency cycle'
PASS: invalid-unsubstantiated-verified.xml rejected with expected error class 'unsubstantiated verified'
Tally: 7/7
```

Additional probes run by hand against the validator (scratch files, not
part of the suite): a `verified` claim carrying Lean formal-proof
evidence (tool `lean`, status `verified`, 64-hex artifact hash)
validates, confirming the gate is evidence-based rather than a blanket
rejection; a duplicate claim id is rejected; a `sum` binder whose body
uses its bound variable validates, while the same document with an
undeclared symbol in the body is rejected.

## The valid example's mathematics

Only established, published facts, at non-verified statuses:

- The q-expansion of the j-invariant, `j(q) = q^-1 + 744 + 196884 q +
  21493760 q^2 + ⋯`, recorded as one candidate claim plus two
  bounded coefficient claims (196884 for `q`, 21493760 for `q^2`). The
  document states explicitly that 744 is the constant coefficient of
  `j`, and that the normalized `J = j - 744` has constant coefficient 0.
- McKay's observation `196884 = 196883 + 1`, as a candidate claim with
  an exact-integer residual of 0 and the representation-theoretic
  reading (Griess algebra dimension 196884, smallest non-trivial
  Monster irreducible dimension 196883) recorded as a candidate
  invariant, not as an established correspondence.

No claim is marked verified, because this engine holds no formal proof
artifact for any of them; every `verification-report` in the example
says UNPROVEN. Sources are Conway and Norton (1979) and McKay (1980).
No digital copies of those papers are held in the corpus, so each
source `sha256` is the SHA-256 of the exact bibliographic locator
string in the `path` attribute; that basis is stated in each
`provenance` element, and for locally held files the same attribute
carries the file digest, as in v1.

## Design decisions

- **Dependency cycles.** Dependencies are collected into a directed
  graph after all references are checked for resolution, then a
  depth-first traversal with open/closed marking reports the first
  cycle as an explicit path (for example `c1 -> c2 -> c1`) and rejects
  the document. v1 checked only that references resolve; acyclicity is
  new in v2, as the directive requires, because a cyclic dependency
  graph has no valid evaluation or proof order.
- **Operator registration.** Three layers must agree: the operator name
  is in the global registry fixed by the schema, the document's
  `operator-registry` lists it at the registry arity, and the claim's
  `operator-signatures` declares it at the same arity. The AST walk
  additionally checks that each `apply` node supplies exactly the
  registry number of arguments. Any failure is an "unsupported
  operator" rejection, so a document cannot extend the language by
  inventing an operator locally.
- **Verified gate.** Mirrors v1 exactly and extends it to the second
  v2 evidence form: status `verified` requires either an `evidence`
  entry or a `formal-proof-references` entry whose tool is one of
  lean / coq / agda / isabelle, whose status is `verified`, and whose
  artifact hash matches the 64-hex pattern. Numerical or bounded
  evidence never satisfies the gate.
- **Symbols and binders.** Every `symbol` in a normalized expression
  must be declared in the claim's `variable-scopes` or bound by an
  enclosing `binder`; `call` targets must be declared as functions.
  This keeps names claim-local and makes scope part of validation
  rather than convention.
- **Structural checking without an XSD engine.** No XSD processor is
  installed in this environment, so `validate_v2.py` implements the
  schema's structural rules directly (required elements, schema child
  order, enumerations, patterns, numeric and date shapes) alongside the
  semantic rules. The XSD remains the normative definition; the test
  suite checks that it is well-formed XML, and uses xmllint on it when
  xmllint is available.
