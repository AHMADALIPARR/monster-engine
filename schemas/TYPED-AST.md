# Typed mathematical AST for contract schema v2

Design note for `schemas/contract-v2.xsd` and `schemas/validate_v2.py`.
The XML document is an interchange record. The mathematics inside a claim
lives in a typed abstract syntax tree (AST), defined by the node elements
under `normalized-expression`; it is never the raw text of the source.

## Node kinds

Every `normalized-expression` holds exactly one root node. A node is one
of five kinds, and each kind maps to one AST type:

| XML element | AST type | Fields | Meaning |
|---|---|---|---|
| `number` | `Num` | `value` (decimal literal, pattern `-?[0-9]+(\.[0-9]+)?`) | An exact numeric literal. Stored as text and read as a decimal/integer value by consumers; never as a float parsed from source prose. |
| `symbol` | `Sym` | `name`, optional `scope` | A reference to a name declared in the claim's `variable-scopes`. A symbol that is neither declared there nor bound by an enclosing binder is rejected. |
| `apply` | `App` | `operator`, child nodes | Application of a registered operator to its arguments. The child count must equal the operator's registry arity, and the operator must be declared in the claim's `operator-signatures`. |
| `call` | `Call` | `function`, child nodes | Application of a named function (for example `j`) to argument nodes. The function name must be declared with `kind="function"` in the claim's `variable-scopes`. Kept distinct from `apply` because named functions carry no registry arity. |
| `binder` | `Bind` | `kind` (`sum`, `product`, `forall`, `exists`, `lambda`, `limit`), `variable`, optional `lower` / `upper` node wrappers, required `body` node wrapper | Introduces a bound variable. The bound name is in scope only inside `body`; `lower` and `upper` are evaluated in the enclosing scope. |

## Operator registry and signatures

The global registry is fixed by the schema (`OperatorNameType` in
`contract-v2.xsd`, mirrored as `GLOBAL_OPERATORS` in `validate_v2.py`):
`add`, `subtract`, `multiply`, `divide`, `power` (arity 2), `negate`
(arity 1), `equals`, `not-equals`, `less-than`, `less-or-equal`,
`greater-than`, `greater-or-equal` (arity 2, proposition-valued), and
`coefficient` (arity 2: `coefficient(series, n)` is the coefficient of
`q^n` in the q-expansion of `series`).

Three layers must agree before an operator node is accepted:

1. The operator name exists in the global registry.
2. The document's `operator-registry` element lists it at the registry
   arity.
3. The claim's `operator-signatures` element declares it, with matching
   arity and, where recorded, argument and result types.

An operator failing any layer is rejected as an unsupported operator.
Extending the language means extending the registry in the schema and in
the validator together, not inventing an operator inside one document.

## Original and normalized expressions are both retained

Each claim carries two expression fields, on purpose:

- `original-expression` is the expression as it appears in the source,
  character for character as transcribed. It is evidence: a reader can
  audit the normalization against it, and its hash can be recorded under
  `source-hashes` with role `original-expression`.
- `normalized-expression` is the typed AST above. It is the only form
  downstream stages (Curry resolution, Alloy contracts, Lean obligations,
  Uiua kernels) may consume, because it has declared operators, declared
  symbols, and explicit binders.

Normalization is a recorded transformation between two retained values,
not a replacement. If the two disagree, the original governs what the
source said and the discrepancy is a defect in the normalization step.

## Variable scopes

`variable-scopes` declares, per claim, every name the normalized
expression may reference: its `kind` (`variable`, `function`,
`parameter`, `constant`), its `binding` (`free` or `bound`), the `scope`
label it belongs to, and an optional mathematical `type` (for example
"complex number, 0 < |q| < 1" for the moonshine variable `q`). Binder
nodes extend this environment locally for their body. There is no global
implicit environment: an undeclared symbol is a validation error, which
is what keeps two claims from silently sharing a name with different
meanings.

## Why XML strings are never executed

Neither expression field is code.

- `original-expression` is untrusted transcribed text from a corpus. It
  is stored, hashed, and displayed; nothing in the pipeline evaluates it,
  substitutes it into a shell or a computer-algebra session, or treats
  it as a program. The v1 seed scanner already follows this rule
  ("Uninterpreted extracted text; not a proven formula"), and v2 keeps it.
- `normalized-expression` looks structured, but the validator only walks
  it as data: it checks node kinds, operator names, arities, and scope
  declarations. It does not evaluate `apply` nodes, does not compute
  `coefficient`, and does not decide whether an `equals` node is true.
  Truth is established only by the evidence chain recorded on the claim
  (formal proof references, bounded checks, numerical residuals), each
  with its own tool, status, and artifact hash.
- Because evaluation never happens at this layer, a hostile or erroneous
  corpus document can at worst be rejected. It cannot make the validator
  run anything, and it cannot promote itself: the `verified` status is
  gated on formal-proof evidence, not on anything an expression says.
