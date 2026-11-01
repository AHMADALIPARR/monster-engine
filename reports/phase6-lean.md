# Phase 6 — Lean 4 / Mathlib proofs: report

Date: 2026-10-31. Project: `~/workspace/monster-engine/lean`
(Lake, `lean-toolchain` = `leanprover/lean4:v4.9.0`, Mathlib v4.9.0 via
`require mathlib from git "https://github.com/leanprover-community/mathlib4" @ "v4.9.0"`,
lakefile pattern copied from the working `~/workspace/scm-mathlib-test`).
No git commands were run; `monster_bridge/` was not touched.

## Build result

**`lake build` succeeds** (final clean rebuild of all four modules:
"Build completed successfully", exit 0). Full output, including the two
earlier failed attempts and their fixes, is in `proofs/lean-build-log.txt`;
axiom output is in `proofs/axioms.txt`.

Toolchain notes, stated plainly:

- The prescribed tar shim (`/tmp/tar-shim/tar` → `/usr/bin/tar --no-same-owner`)
  was recreated and put on `PATH` before `lake exe cache get`, which then
  ran exactly as in the testbed: "No files to download / Decompressing 4732
  file(s) / Completed successfully!".
- One deviation: `lake update`'s fresh clone of mathlib ran at ~35 MB/min
  and was stopped; the dependency packages were instead copied from the
  already-proven testbed `~/workspace/scm-mathlib-test/.lake/packages`
  (the lake-manifest was copied verbatim from the testbed, so revisions are
  identical — mathlib v4.9.0). The cache get and build after that are the
  prescribed commands, unmodified.
- Two Mathlib-4.9 naming facts cost one build attempt each and are recorded
  in the sources: `mul_inv_cancel` in 4.9 is the `GroupWithZero` lemma
  (`a ≠ 0 → a * a⁻¹ = 1`), so group cancellation in `GroupAction.lean` is
  discharged by `simp` after rewriting with `mul_smul`; and `add_neg_cancel`
  is not a lemma name in 4.9 (the step in `LieBracket.lean` uses `simp`).

## Tally

Files (4 proof modules + Lake root):

| File | `grep -c 'theorem\|lemma'` lines | actual `theorem` declarations |
|---|---|---|
| `lean/MonsterBridge/GroupAction.lean` | 17 | 11 |
| `lean/MonsterBridge/Representation.lean` | 9 | 7 |
| `lean/MonsterBridge/LieBracket.lean` | 9 | 7 |
| `lean/MonsterBridge/DependencyModel.lean` | 12 | 10 |
| **Total** | **47** | **35** |

(The grep count includes the words "theorem"/"lemma" inside docstrings and
comments; the right column counts `^theorem` declarations exactly. There are
no `lemma` declarations. `DependencyModel` additionally defines `HasTopoRank`,
`IsRankedAcyclic`, and the inductive `Reach`; `GroupAction` defines the
`HomAction` structure.)

- `sorry`/`admit`: **zero** — `grep -rn 'sorry\|admit'` over all Lean
  sources returns no matches; no `sorryAx` appears in any build output.
- Every theorem compiles under `lake build`.

## Axioms (`#print axioms`, headline theorem per file, verbatim)

- `MonsterBridge.GroupAction.HomAction.act_inv_apply` — `[propext]`
- `MonsterBridge.Representation.comp_id_repr` — `[propext, Quot.sound]`
- `MonsterBridge.LieBracket.bracket_self_add_self_eq_zero` — `[propext]`
- `MonsterBridge.DependencyModel.topoRank_no_cycle` — **does not depend on
  any axioms**

No `Classical.choice` and no `sorryAx` in any headline theorem — a subset
of the expected `propext / Classical.choice / Quot.sound` set.

## What was proved (summary; precise statements in `proofs/README.md`)

1. **GroupAction** — both laws for Mathlib's `MulAction` (labelled
   restatements of `one_smul`/`mul_smul`) plus derived consequences
   (`g • (g⁻¹ • x) = x`, fixed-by-`g` ⇒ fixed-by-`g⁻¹`); and for a
   hand-rolled `HomAction` structure the same consequences derived from
   the two law-fields alone, including bijectivity of `act g`.
2. **Representation** — 7 lemmas on composition of homomorphisms:
   computation rule, preservation of `*` and `1` by a composite, identity
   as left and right unit for composition, associativity, and a
   permutation-representation specialisation.
3. **LieBracket** — from antisymmetry + Jacobi as hypotheses only:
   `⟦x, x⟧ = -⟦x, x⟧`, the honest headline `⟦x, x⟧ + ⟦x, x⟧ = 0` (with the
   characteristic-2 remark in the source and README: antisymmetry alone
   gives 2-torsion, not `⟦x, x⟧ = 0`), `⟦x, x⟧ = 0` under an explicit
   no-2-torsion hypothesis, `⟦x, y⟧ + ⟦y, x⟧ = 0`, the single-term Jacobi
   isolation, the Jacobi rotation, and the inner-bracket swap by
   congruence. The Leibniz form is not stated, because it does not follow
   from the stated hypotheses.
4. **DependencyModel** — ranking formulation chosen and finished
   completely (no substitution needed): ranks strictly increase along
   `Reach` paths of any length, hence no cycle of any length, and
   concretely no self-loop, no 2-cycle, no 3-cycle; contrapositive forms
   (self-loop / 2-cycle / any cycle ⇒ no ranking exists); constructive
   ranked-acyclicity witnesses for `[]` and `[(0, 1)]`. The headline
   theorem is axiom-free.

No proof target proved unreachable; no target was weakened and no `sorry`
was left anywhere. The only formulation choice exercised was the one the
brief offered for file 4 (ranking/`Reach` instead of list-ordering), and
file 3 follows the brief's prescribed honest route for the self-bracket.

## Disclaimer

These are abstract theorems about arbitrary groups, actions, homomorphisms,
brackets, and finite edge lists satisfying the stated hypotheses. Nothing
here establishes that the Monster Group satisfies any of the hypotheses;
see `proofs/README.md`.
