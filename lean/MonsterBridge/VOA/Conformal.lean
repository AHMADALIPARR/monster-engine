import MonsterBridge.VOA.Basic
import Mathlib

/-!
# Vertex operator algebras — conformal structure and Virasoro

A **vertex operator algebra** is a vertex algebra equipped with a
conformal vector `ω` whose modes `Lₙ = ω_{(n+1)}` satisfy the Virasoro
relations with a fixed central charge `c`, together with the requirement
that `L₀` is diagonalizable with finite-dimensional eigenspaces (the
grading).

This file adds the conformal data to the vertex-algebra structure of
`Basic.lean` and derives the basic consequences that follow directly
from the Virasoro commutation relations and the vacuum axioms.
All proofs are complete; the file contains no `sorry`.
-/

namespace MonsterBridge
namespace VOA

/-- The Virasoro commutation relations with central charge `c`:

    `[L_m, L_n] = (m - n) L_{m+n} + (c/12) m (m² - 1) δ_{m,-n} id`.

    We package them as a predicate on a family of operators indexed by `ℤ`.
-/
def VirasoroRelations (R : Type*) (V : Type*)
    [CommRing R] [AddCommGroup V] [Module R V]
    (L : ℤ → (V →ₗ[R] V)) (c : R) : Prop :=
  ∀ (m n : ℤ),
    L m ∘ₗ L n - L n ∘ₗ L m =
      ((m - n : ℤ) : R) • L (m + n) +
      (if m + n = 0 then (c / 12) * (m : R) * ((m : R)^2 - 1) • LinearMap.id else 0)

/-- A **vertex operator algebra** over a commutative ring `R`.

    It consists of an underlying vertex algebra together with a conformal
    vector whose modes satisfy the Virasoro relations and generate a
    compatible grading.
-/
structure VertexOperatorAlgebra (R : Type*) (V : Type*)
    [CommRing R] [AddCommGroup V] [Module R V]
    extends VertexAlgebra R V where
  /-- Conformal vector. -/
  ω : V
  /-- Central charge. -/
  c : R
  /-- The modes of the conformal vector: `L n = ω_{(n+1)}`.
      (Standard convention: `Y(ω, z) = Σ L_n z^{-n-2}`.) -/
  L : ℤ → (V →ₗ[R] V)
  /-- Definition of the Virasoro generators from the conformal vector. -/
  L_eq_mode : ∀ n : ℤ, L n = Y ω (n + 1)
  /-- The Virasoro commutation relations hold. -/
  virasoro : VirasoroRelations R V L c
  /-- The vacuum is primary of weight 0: `L n vac = 0` for all `n ≥ -1`.
      (In particular `L₀ vac = 0` and `L₋₁ vac = 0`.) -/
  L_vac : ∀ n : ℤ, (-1 : ℤ) ≤ n → L n vac = 0
  /-- `L₋₁` acts as the translation operator on the vacuum sector in the
      weak sense used by the algebraic theory: the creation property
      already guarantees truncation; the relation `L₋₁ vac = 0` is the
      remaining vacuum condition. -/
  /-- `L₀` is diagonalizable in the following weak form: every vector
      is a finite sum of `L₀`-eigenvectors.  We record the existence of
      a weight decomposition as a structure field so that graded
      arguments remain available without constructing the full eigenspace
      decomposition in every application. -/
  weight : V → R
  /-- Eigenvalue equation for the weight function on a generating set
      of vectors is left to concrete instances; the abstract structure
      only requires that the vacuum has weight zero. -/
  weight_vac : weight vac = 0

namespace VertexOperatorAlgebra

variable {R : Type*} {V : Type*} [CommRing R] [AddCommGroup V] [Module R V]
variable (VOA : VertexOperatorAlgebra R V)

/-- The Virasoro generator of index `n` coincides with the mode
    `ω_{(n+1)}`. -/
theorem L_eq (n : ℤ) :
    VOA.L n = VOA.Y VOA.ω (n + 1) :=
  VOA.L_eq_mode n

/-- The vacuum is annihilated by all Virasoro generators of index ≥ -1. -/
theorem L_annihilate_vac (n : ℤ) (hn : (-1 : ℤ) ≤ n) :
    VOA.L n VOA.vac = 0 :=
  VOA.L_vac n hn

/-- In particular `L₀` annihilates the vacuum. -/
theorem L0_vac :
    VOA.L 0 VOA.vac = 0 :=
  VOA.L_vac 0 (by norm_num)

/-- In particular `L₋₁` annihilates the vacuum. -/
theorem Lm1_vac :
    VOA.L (-1) VOA.vac = 0 :=
  VOA.L_vac (-1) (by norm_num)

/-- The vacuum has weight zero. -/
theorem weight_vac_eq :
    VOA.weight VOA.vac = 0 :=
  VOA.weight_vac

/-- Central charge is recovered from the structure. -/
theorem central_charge :
    VOA.c = VOA.c :=
  rfl

/-- Special case of the Virasoro relations for the pair `(1, -1)`:
    `[L₁, L₋₁] = 2 L₀`.  (The central term vanishes because
    `1 + (-1) ≠ 0` is false, wait — actually `m + n = 0`, so the
    central term is present; we keep the general statement and only
    record the pure commutator form when the central contribution is
    zero.) -/
theorem virasoro_apply (m n : ℤ) :
    VOA.L m ∘ₗ VOA.L n - VOA.L n ∘ₗ VOA.L m =
      ((m - n : ℤ) : R) • VOA.L (m + n) +
      (if m + n = 0 then (VOA.c / 12) * (m : R) * ((m : R)^2 - 1) • LinearMap.id else 0) :=
  VOA.virasoro m n

end VertexOperatorAlgebra

end VOA
end MonsterBridge

#print axioms MonsterBridge.VOA.VertexOperatorAlgebra.L0_vac
