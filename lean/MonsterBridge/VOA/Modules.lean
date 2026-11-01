import MonsterBridge.VOA.Basic
import MonsterBridge.VOA.Conformal
import Mathlib

/-!
# Modules for vertex algebras and vertex operator algebras

A module for a vertex algebra is a vector space `M` together with a
state-field map `Y^M : V → EndSeries R M` satisfying the vacuum axiom,
the creation property, and weak locality between module modes.

For a VOA one additionally requires that the Virasoro generators act
on the module via the modes of the conformal vector.

All definitions and theorems in this file are complete; there is no
`sorry`.
-/

namespace MonsterBridge
namespace VOA

/-- A **module** over a vertex algebra `VA`.

    The action is given by mode operators `Y_M a n : M →ₗ[R] M`.
    The axioms mirror those of the algebra itself.
-/
structure VertexAlgebraModule (R : Type*) (V : Type*) (M : Type*)
    [CommRing R] [AddCommGroup V] [Module R V]
    [AddCommGroup M] [Module R M]
    (VA : VertexAlgebra R V) where
  /-- State-field map of the module: `Y_M a n` is the action of the
      mode `a_{(n)}` on `M`. -/
  Y_M : V → (ℤ → (M →ₗ[R] M))
  /-- Vacuum axiom on the module: the mode `-1` of the vacuum acts as
      the identity on `M`. -/
  vac_mode_m1_M : Y_M VA.vac (-1) = LinearMap.id
  /-- Non-negative modes of the vacuum annihilate every vector of `M`. -/
  vac_mode_nonneg_M : ∀ n : ℤ, 0 ≤ n → Y_M VA.vac n = 0
  /-- Creation property on the module. -/
  creation_M : ∀ (a : V) (m : M), ∃ N : ℤ, ∀ n : ℤ, N ≤ n → Y_M a n m = 0
  /-- Locality of module modes among themselves. -/
  locality_M : ∀ (a b : V), ∃ N : ℕ, ∀ (k n : ℤ),
      (N : ℤ) ≤ k + n →
      Y_M a k ∘ₗ Y_M b n = Y_M b n ∘ₗ Y_M a k

namespace VertexAlgebraModule

variable {R V M : Type*}
  [CommRing R] [AddCommGroup V] [Module R V]
  [AddCommGroup M] [Module R M]
variable {VA : VertexAlgebra R V} (Mod : VertexAlgebraModule R V M VA)

/-- The vacuum mode of index `-1` acts as the identity on the module. -/
theorem vac_id (m : M) :
    Mod.Y_M VA.vac (-1) m = m := by
  rw [Mod.vac_mode_m1_M]
  rfl

/-- Non-negative vacuum modes annihilate the module. -/
theorem vac_annihilate (n : ℤ) (hn : 0 ≤ n) (m : M) :
    Mod.Y_M VA.vac n m = 0 := by
  rw [Mod.vac_mode_nonneg_M n hn]
  rfl

/-- High modes of any algebra element eventually annihilate every
    module vector. -/
theorem high_mode_vanish_M (a : V) (m : M) :
    ∃ N : ℤ, ∀ n : ℤ, N ≤ n → Mod.Y_M a n m = 0 :=
  Mod.creation_M a m

/-- Module modes of sufficiently high total index commute. -/
theorem modes_commute_M (a b : V) :
    ∃ N : ℕ, ∀ (k n : ℤ), (N : ℤ) ≤ k + n →
      Mod.Y_M a k ∘ₗ Mod.Y_M b n = Mod.Y_M b n ∘ₗ Mod.Y_M a k :=
  Mod.locality_M a b

end VertexAlgebraModule

/-- A **module** over a vertex operator algebra is a module over the
    underlying vertex algebra together with a compatible action of the
    Virasoro generators given by the modes of the conformal vector.
-/
structure VertexOperatorAlgebraModule (R : Type*) (V : Type*) (M : Type*)
    [CommRing R] [AddCommGroup V] [Module R V]
    [AddCommGroup M] [Module R M]
    (VOA : VertexOperatorAlgebra R V)
    extends VertexAlgebraModule R V M VOA.toVertexAlgebra where
  /-- Action of the Virasoro generators on the module. -/
  L_M : ℤ → (M →ₗ[R] M)
  /-- Compatibility: the Virasoro action is given by the modes of the
      conformal vector. -/
  L_M_eq : ∀ n : ℤ, L_M n = Y_M VOA.ω (n + 1)

namespace VertexOperatorAlgebraModule

variable {R V M : Type*}
  [CommRing R] [AddCommGroup V] [Module R V]
  [AddCommGroup M] [Module R M]
variable {VOA : VertexOperatorAlgebra R V}
  (Mod : VertexOperatorAlgebraModule R V M VOA)

/-- The Virasoro generators on the module are exactly the modes of `ω`. -/
theorem L_M_mode (n : ℤ) :
    Mod.L_M n = Mod.Y_M VOA.ω (n + 1) :=
  Mod.L_M_eq n

end VertexOperatorAlgebraModule

end VOA
end MonsterBridge

#print axioms MonsterBridge.VOA.VertexAlgebraModule.vac_id
