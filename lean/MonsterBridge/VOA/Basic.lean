import Mathlib

/-!
# Vertex algebras — core definitions and mode calculus

This file introduces the abstract structure of a **vertex algebra** over a
commutative ring (typically a field of characteristic zero in applications).
The formulation follows the standard algebraic axiomatization (Borcherds,
Frenkel–Lepowsky–Meurman, Kac):

* a vacuum vector `vac`;
* a state-field map `Y` producing formal Laurent series of endomorphisms;
* the vacuum axioms;
* the creation property;
* locality (weak commutativity).

All theorems in this file are derived from the structure fields alone.
No external computational data about the Monster or moonshine is assumed.
No `sorry` appears anywhere in the development.
-/

namespace MonsterBridge
namespace VOA

/-- Formal Laurent series of endomorphisms given by their mode coefficients.
    `Y a n` is the operator usually written `a_{(n)}`. -/
abbrev EndSeries (R : Type*) (V : Type*) [Semiring R] [AddCommMonoid V] [Module R V] :=
  ℤ → (V →ₗ[R] V)

/-- Extract the mode operator of index `n`. -/
def mode {R V : Type*} [Semiring R] [AddCommMonoid V] [Module R V]
    (Y : EndSeries R V) (n : ℤ) : V →ₗ[R] V :=
  Y n

/-- A **vertex algebra** over a commutative ring `R`.

    The structure packages the vacuum, the state-field correspondence
    (as mode operators), and the three fundamental axioms used in the
    algebraic theory.  Locality is stated in the weak form sufficient
    for most formal calculations: for every pair of states there exists
    `N` such that the modes of sufficiently high total index commute.
-/
structure VertexAlgebra (R : Type*) (V : Type*)
    [CommRing R] [AddCommGroup V] [Module R V] where
  /-- Vacuum vector. -/
  vac : V
  /-- State-field correspondence given by modes:
      `Y a n` is the operator usually written `a_{(n)}`. -/
  Y : V → EndSeries R V
  /-- Vacuum axiom: non-negative modes of the vacuum vanish. -/
  vac_mode_nonneg : ∀ n : ℤ, 0 ≤ n → Y vac n = 0
  /-- Vacuum axiom: the mode of index `-1` of the vacuum is the identity. -/
  vac_mode_m1 : Y vac (-1) = LinearMap.id
  /-- Creation property: for every state `a` and every vector `v`
      only finitely many modes of non-negative index can act non-trivially
      on `v`.  Stated as existence of an upper bound `N` such that
      `Y a n v = 0` whenever `n ≥ N`. -/
  creation : ∀ (a : V) (v : V), ∃ N : ℤ, ∀ n : ℤ, N ≤ n → Y a n v = 0
  /-- Locality (weak commutativity of modes):
      for any two states `a, b` there exists `N : ℕ` such that for all
      integers `m, n` with `m + n ≥ N` one has
      `Y a m ∘ Y b n = Y b n ∘ Y a m` as endomorphisms. -/
  locality : ∀ (a b : V), ∃ N : ℕ, ∀ (m n : ℤ),
      (N : ℤ) ≤ m + n →
      Y a m ∘ₗ Y b n = Y b n ∘ₗ Y a m

namespace VertexAlgebra

variable {R : Type*} {V : Type*} [CommRing R] [AddCommGroup V] [Module R V]
variable (VA : VertexAlgebra R V)

/-- Shorthand for the mode operators of the ambient vertex algebra. -/
def a_mode (a : V) (n : ℤ) : V →ₗ[R] V :=
  VA.Y a n

/-- High modes annihilate every vector (creation property, restated). -/
theorem high_mode_vanish (a v : V) :
    ∃ N : ℤ, ∀ n : ℤ, N ≤ n → VA.Y a n v = 0 :=
  VA.creation a v

/-- The mode of index `-1` of the vacuum is the identity endomorphism. -/
theorem vac_mode_m1_eq :
    VA.Y VA.vac (-1) = LinearMap.id :=
  VA.vac_mode_m1

/-- Applying the vacuum mode of index `-1` recovers the original vector. -/
theorem vac_mode_m1_apply (v : V) :
    VA.Y VA.vac (-1) v = v := by
  rw [VA.vac_mode_m1]
  rfl

/-- Non-negative modes of the vacuum vanish identically as endomorphisms. -/
theorem vac_mode_nonneg_eq (n : ℤ) (hn : 0 ≤ n) :
    VA.Y VA.vac n = 0 :=
  VA.vac_mode_nonneg n hn

/-- Applying a non-negative mode of the vacuum yields zero. -/
theorem vac_mode_nonneg_apply (n : ℤ) (hn : 0 ≤ n) (v : V) :
    VA.Y VA.vac n v = 0 := by
  rw [VA.vac_mode_nonneg n hn]
  rfl

/-- Locality implies that sufficiently high total-degree mode products
    commute.  Restatement of the locality field. -/
theorem modes_commute_of_locality (a b : V) :
    ∃ N : ℕ, ∀ (m n : ℤ), (N : ℤ) ≤ m + n →
      VA.Y a m ∘ₗ VA.Y b n = VA.Y b n ∘ₗ VA.Y a m :=
  VA.locality a b

/-- The vacuum mode of index `-1` is not the zero endomorphism whenever
    the underlying module is nontrivial. -/
theorem vac_mode_m1_ne_zero [Nontrivial V] :
    VA.Y VA.vac (-1) ≠ 0 := by
  intro h
  have : (LinearMap.id : V →ₗ[R] V) = 0 := by
    rw [← VA.vac_mode_m1, h]
  exact id_ne_zero this

/-- The vacuum vector itself is nonzero whenever the module is nontrivial,
    because the identity applied to it recovers the vector and the identity
    is nonzero. -/
theorem vac_ne_zero [Nontrivial V] :
    VA.vac ≠ 0 := by
  intro h
  have h_id := vac_mode_m1_ne_zero (VA := VA)
  have : VA.Y VA.vac (-1) = 0 := by
    ext v
    rw [vac_mode_m1_apply, h]
    simp
  exact h_id this

end VertexAlgebra

end VOA
end MonsterBridge

#print axioms MonsterBridge.VOA.VertexAlgebra.vac_mode_m1_apply
