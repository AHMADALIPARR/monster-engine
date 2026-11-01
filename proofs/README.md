# Lean proofs — what is proved, and what is not

Lean project: `../lean/` (Lake, `leanprover/lean4:v4.9.0`, Mathlib v4.9.0).
All files compile under `lake build`; there is no `sorry`/`admit` anywhere
(grep-verified). Build log: `lean-build-log.txt`. `#print axioms` output for
each file's headline theorem: `axioms.txt`.

> **Disclaimer.** Every result below is an *abstract* theorem: it is proved
> for an arbitrary group, action, homomorphism, bracket, or finite edge list
> satisfying the stated hypotheses. **Nothing here establishes that the
> Monster Group — or any other specific group, algebra, or contract corpus —
> satisfies those hypotheses**, and nothing here constructs a representation,
> action, or bracket for any specific object. Instantiating any of these
> theorems at a concrete object is separate work that would require proving
> that the object meets the hypotheses.

## `MonsterBridge/GroupAction.lean` — group actions

Part A (Mathlib's `MulAction G α`, `G` a group):

- `one_act` — `(1 : G) • x = x`. This is Mathlib's `one_smul`, restated.
- `mul_act` — `(g * h) • x = g • h • x`. This is Mathlib's `mul_smul`, restated.
- `inv_act_apply_inv` — `g • (g⁻¹ • x) = x`, derived from `mul_smul` plus
  group cancellation.
- `act_apply_inv_act` — `g⁻¹ • (g • x) = x`, derived the same way.
- `fixed_by_inv` — if `g • x = x` then `g⁻¹ • x = x`.

Part B (hand-rolled `HomAction G α`: a map `act : G → α → α` with the two
laws as structure fields `act_one`, `act_mul`; all results derived from
those two laws alone):

- `HomAction.act_inv_apply` *(headline)* — `A.act g (A.act g⁻¹ x) = x`.
  Axioms: `[propext]`.
- `HomAction.inv_act_apply` — `A.act g⁻¹ (A.act g x) = x`.
- `HomAction.act_bijective` — `A.act g` is bijective, inverse `A.act g⁻¹`.
- `HomAction.fixed_by_inv` — if `A.act g x = x` then `A.act g⁻¹ x = x`.
- `HomAction.law_one`, `HomAction.law_mul` — the two fields restated as
  theorems (labelled as restatements in the source).

## `MonsterBridge/Representation.lean` — homomorphisms compose

For groups `G H K L` and monoid homomorphisms (a representation is modelled
abstractly as a homomorphism out of a group, e.g. `G →* Equiv.Perm α`):

- `comp_apply` — `(ψ.comp φ) g = ψ (φ g)`.
- `comp_map_mul` — `(ψ.comp φ) (a * b) = (ψ.comp φ) a * (ψ.comp φ) b`:
  the composite preserves multiplication.
- `comp_map_one` — `(ψ.comp φ) 1 = 1`.
- `id_comp_repr` — `(MonoidHom.id H).comp φ = φ`.
- `comp_id_repr` *(headline)* — `φ.comp (MonoidHom.id G) = φ`.
  Axioms: `[propext, Quot.sound]`.
- `comp_assoc_repr` — `(χ.comp ψ).comp φ = χ.comp (ψ.comp φ)`.
- `perm_comp_apply` — the computation rule specialised to a permutation
  representation composed with an endomorphism of `Equiv.Perm α`.

## `MonsterBridge/LieBracket.lean` — abstract bracket

Hypotheses (section variables, assumed — not proved): a bracket
`bracket : L → L → L` on an additive commutative group `L`, with
antisymmetry `∀ x y, ⟦x, y⟧ = -⟦y, x⟧` and the Jacobi identity
`∀ x y z, ⟦x, ⟦y, z⟧⟧ + ⟦y, ⟦z, x⟧⟧ + ⟦z, ⟦x, y⟧⟧ = 0`. No bilinearity and
no Leibniz rule are assumed.

- `bracket_self_eq_neg_self` — `⟦x, x⟧ = -⟦x, x⟧`.
- `bracket_self_add_self_eq_zero` *(headline)* — `⟦x, x⟧ + ⟦x, x⟧ = 0`.
  This honest form is what antisymmetry alone implies: in characteristic 2,
  `b + b = 0` holds for every `b`, so `⟦x, x⟧ = 0` cannot be concluded there;
  in general `⟦x, x⟧` is only shown to be 2-torsion. Axioms: `[propext]`.
- `bracket_self_eq_zero_of_no_two_torsion` — `⟦x, x⟧ = 0`, under the extra
  explicit hypothesis `∀ b, b + b = 0 → b = 0` (no nonzero 2-torsion).
- `bracket_add_bracket_rev_eq_zero` — `⟦x, y⟧ + ⟦y, x⟧ = 0`.
- `jacobi_single` — `⟦x, ⟦y, z⟧⟧ = -(⟦y, ⟦z, x⟧⟧ + ⟦z, ⟦x, y⟧⟧)`, the one
  Jacobi rearrangement that follows from the stated hypotheses alone.
- `jacobi_rot` — the cyclic rotation of Jacobi (an instance of the hypothesis).
- `bracket_inner_swap` — `⟦x, ⟦y, z⟧⟧ = ⟦x, -⟦z, y⟧⟧`, by congruence from
  antisymmetry (no linearity used).

The Leibniz form `⟦x, ⟦y, z⟧⟧ = ⟦⟦x, y⟧, z⟧ + ⟦y, ⟦x, z⟧⟧` is deliberately
**not** stated: it does not follow from antisymmetry + Jacobi without extra
hypotheses.

## `MonsterBridge/DependencyModel.lean` — finite dependency model

Formulation: dependencies are a finite `List (Nat × Nat)` of edges over
`Nat` claim ids (mirroring the repo's XML model). Acyclicity is formulated
as existence of a topological ranking: `HasTopoRank edges rank` means
`rank : Nat → Nat` strictly increases along every listed edge.
`Reach edges a b` is reachability by a path of any positive length
(single edge, or paths composed transitively).

- `rank_strict_of_reach` — under a ranking, `Reach edges a b → rank a < rank b`
  (induction on the path; all lengths at once).
- `topoRank_no_cycle` *(headline)* — under a ranking, `¬ Reach edges a a`:
  no dependency cycle of any length. Axioms: **none** (the `#print axioms`
  output is "does not depend on any axioms").
- `topoRank_no_self_loop` — `(a, a) ∉ edges` (no length-1 cycle).
- `topoRank_no_two_cycle` — `(a, b)` and `(b, a)` are not both edges.
- `topoRank_no_three_cycle` — `(a, b)`, `(b, c)`, `(c, a)` are not all edges.
- `no_topoRank_of_self_loop` — contrapositive: a self-loop in the list
  implies no ranking exists.
- `no_topoRank_of_two_cycle` — contrapositive for a 2-cycle.
- `not_rankedAcyclic_of_cycle` — contrapositive for a cycle of any length:
  `Reach edges a a → ¬ IsRankedAcyclic edges`.
- `empty_rankedAcyclic`, `chain01_rankedAcyclic` — constructive witnesses
  that `[]` and `[(0, 1)]` are ranked-acyclic (identity ranking).
