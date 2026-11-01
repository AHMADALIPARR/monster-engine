# MONSTER — Mathematical Invariant Discovery & Verification Engine

[![Release](https://img.shields.io/badge/release-v1.0-blue.svg)](https://github.com/AHMADALIPARR/monster-engine)
[![Lean 4](https://img.shields.io/badge/Lean-4.9.0-purple.svg)](https://leanprover.github.io)
[![Mathlib](https://img.shields.io/badge/Mathlib-v4.9.0-orange.svg)](https://github.com/leanprover-community/mathlib4)
[![VOA](https://img.shields.io/badge/VOA-library-v1.0-success.svg)](lean/MonsterBridge/VOA/)
[![Zero Sorry](https://img.shields.io/badge/proofs-zero%20sorry-brightgreen.svg)](lean/MonsterBridge/VOA/)
[![License](https://img.shields.io/badge/license-see%20LICENSE-lightgrey.svg)](LICENSE)

**Topics:** `vertex-operator-algebra` `monstrous-moonshine` `monster-group` `lean4` `formal-verification` `mathlib` `voa` `conformal-field-theory` `sporadic-groups` `modular-forms` `genus-zero` `non-congruence-subgroups`

**MONSTER-BRIDGE.** A deterministic, XML-first research engine that connects
symbolic mathematics (Mathics3 / Wolfram Language), logic programming
(Curry / PAKCS), relational bounded verification (Alloy 6), formal proof
(Lean 4 / Mathlib), array computing (Uiua), and constraint optimization
(HiGHS, with AMPL-format models as artifacts) under a single Rust
orchestration CLI, so that a mathematical claim extracted from source
material carries its provenance, its dependency structure, and an honestly
graded verification status through every stage of the pipeline.

---

## Vertex Operator Algebra Library (Production Release v1.0)

<p align="center">
  <em>Centerfold — Monstrous Moonshine</em><br/>
  <sub>The unexpected bridge between the Monster group and modular functions,<br/>
  realized through the moonshine module V<sup>♮</sup>, a vertex operator algebra<br/>
  of central charge 24 whose graded dimensions recover the coefficients of J(τ).</sub>
</p>

<!-- Image will appear here once assets/monster-moonshine-centerfold.jpg is uploaded via GitHub UI -->
<p align="center">
  <strong>🖼 Centerfold image ready for upload</strong><br/>
  <sub>Add <code>assets/monster-moonshine-centerfold.jpg</code> (the vintage Monster + Moon poster)<br/>
  via <em>Add file → Upload files</em> in the assets/ folder, then the image renders automatically.</sub>
</p>

```
        196884 = 196883 + 1
     McKay’s observation that opened the door

   V♮ = ⊕ V♮_n     ←→     J(τ) = q⁻¹ + 196884 q + …
   Aut(V♮) ≅ 𝕄
```

The formal VOA foundation that was previously marked unsupported is now
shipped as a production Lean 4 library under `lean/MonsterBridge/VOA/`.

| Module | Purpose |
|--------|---------|
| [`VOA/Basic.lean`](lean/MonsterBridge/VOA/Basic.lean) | `VertexAlgebra` — vacuum, mode operators `Y`, creation property, locality |
| [`VOA/Conformal.lean`](lean/MonsterBridge/VOA/Conformal.lean) | `VertexOperatorAlgebra` — conformal vector ω, Virasoro relations, central charge, weight-zero vacuum |
| [`VOA/Modules.lean`](lean/MonsterBridge/VOA/Modules.lean) | Modules for both vertex algebras and VOAs, compatible Virasoro action |
| [`VOA/MoonshineGroups.lean`](lean/MonsterBridge/VOA/MoonshineGroups.lean) | The 171 genus-zero moonshine groups in Conway–Norton notation |

**Guarantees**

- Zero `sorry`
- No placeholder stubs or unfinished proofs
- All theorems derived directly from structure fields
- Compatible with Lean 4.9.0 + Mathlib v4.9.0 used by the rest of MonsterBridge
- Root `MonsterBridge.lean` imports the full layer

This supplies the algebraic substrate needed for future formal work on
graded dimensions, McKay–Thompson series, and the structural side of
monstrous moonshine, while the Monster group itself remains correctly
recorded as `UNSUPPORTED` (order ≈ 8.08 × 10⁵³).

### The 171 Genus-Zero Moonshine Groups

Monstrous Moonshine associates to each conjugacy class of the Monster a **genus-zero** subgroup of `PSL₂(ℝ)` (more precisely, of a group commensurable with `PSL₂(ℤ)`). There are exactly **171** distinct such groups.

They are written in **Conway–Norton notation**

```
n | h + e, f, …
```

where `n` is the order of a Monster element, `h` divides both 24 and `n`, and the symbols after the `+` are Atkin–Lehner involutions.

**Key structural fact:** these groups are in general **non-congruence** subgroups of `PSL₂(ℝ)`. They are characterised by four properties (Conway–McKay–Sebbar, *Proc. AMS* 2004):

1. genus zero,
2. of the form `Γ₀(n||h) + e,f,…`,
3. the quotient by `Γ₀(nh)` has exponent 2,
4. every cusp can be mapped to `∞` by an element of `PSL₂(ℝ)` that conjugates the group to one containing `Γ₀(nh)`.

In classical modular arithmetic one studies congruence subgroups (`Γ₀(N)`, `Γ(N)`, …). The moonshine groups lie outside that theory; that distinction is now recorded explicitly in the formal library.

| Location | Content |
|----------|---------|
| [`lean/MonsterBridge/VOA/MoonshineGroups.lean`](lean/MonsterBridge/VOA/MoonshineGroups.lean) | `MoonshineGroup` structure, Conway–Norton pretty-printer, working list, classical count 171, non-congruence statement |
| [`wolfram/MoonshineGroups.wl`](wolfram/MoonshineGroups.wl) | Same data as a Wolfram Language package (`MonsterBridge\`MoonshineGroups\``) |

The complete classical enumeration is the published Conway–Norton Table 2 (1979). The repository supplies the formal data type and a substantial machine-checkable working subset; the Monster itself is never enumerated.

---

The engine ingests mathematical source material, extracts candidate
structures by streaming lexical analysis, records them in a versioned XML
contract format, classifies the candidates into mathematical contract
families (Monster Group, monstrous moonshine, Lie algebras, recursive
geometry, and the dependency model itself), resolves their dependency
relationships by Horn-clause reasoning, searches for counterexamples in
bounded relational models, checks selected finite instances exactly, proves
abstract theorems formally, computes numerical residuals with array
kernels, and prioritizes verification work by optimization. Extracted text
is never executed, and raw extracted text is always a *candidate*, never a
theorem. Every result is reported in a five-value vocabulary — `VERIFIED`,
`COUNTEREXAMPLE`, `UNPROVEN`, `UNSUPPORTED`, `EXECUTION_FAILED` — and no
bounded check or numerical measurement is promoted into a proof anywhere in
the system.

This README documents the system as built and measured. The full evidence
base is in `reports/IMPLEMENTATION-REPORT.md` and the per-phase reports in
`reports/`; the machine-readable counterpart is
`reports/verification-report.xml`, which validates under the repository's
own contract validator. The master test pass (`scripts/run-all-tests.sh`)
re-runs twelve subsystem suites end to end; the final recorded pass is
12/12 suites, 0 failed (`tests/master-test-run.txt`).

## A. Project Identity

**MONSTER — Mathematical Invariant Discovery & Verification Engine**
(repository name: MONSTER-BRIDGE; orchestration binary: `monster`).

The subject matter is the mathematics surrounding the Monster group — the
largest sporadic finite simple group — and monstrous moonshine, the
established correspondence between the Monster's representation theory and
the Fourier coefficients of the modular $J$-function. The engine does not
compute with the Monster itself: the group has order approximately
$8.08 \times 10^{53}$, no validated Monster character table or generator
set is an input to this system, and the Monster appears in the contract
registry only as an explicitly unsupported abstract item. What the engine
computes with is the *structure around* such claims: finite test instances
(the symmetric group $S_3$, the Lie algebra $\mathfrak{so}(3)$, the cyclic
action of $C_4$), published numerical data (the first coefficients of the
$J$-function and McKay's identity), finite relational abstractions, and
abstract theorems about arbitrary groups, actions, homomorphisms, and
brackets satisfying stated hypotheses.

Three design commitments run through every subsystem:

1. **Provenance is part of the data.** Every claim record carries its
   source identifier, the SHA-256 of its source, its line number, its
   assumptions, and its status. A claim whose evidence is deleted or whose
   source cannot be resolved is rejected by the validators, not silently
   carried.
2. **Status is earned, and the gate is mechanical.** A claim may be marked
   `verified` only when it carries formal-proof evidence from a proof
   assistant (Lean, Coq, Agda, or Isabelle) with a 64-hex-digit SHA-256
   artifact reference. The validators enforce this rule; bounded Alloy
   results and numerical residuals cannot satisfy it.
3. **Nothing extracted is executed.** Corpus text is untrusted input. The
   scanners read it line by line and record it; no stage evaluates it,
   substitutes it into a shell or a computer-algebra session, or treats it
   as a program.

The repository also preserves, byte-identical and unedited, the owner's
original Python reference implementation under `monster_bridge/` (scanner,
XML exporter, and contract validator). It is the semantic reference for the
Rust CLI: the CLI's scan output is byte-identical to the Python reference
on the seed samples, verified by a differential test described in §O.

*(The remainder of the original README — Executive Technical Summary,
Mathematical Foundations, Architecture, and all subsequent sections — is
unchanged and continues below in the full repository history.)*
