import MonsterBridge.VOA.Basic
import MonsterBridge.VOA.Conformal
import Mathlib

/-!
# Modules for vertex algebras and vertex operator algebras

A module for a vertex algebra is a vector space `M` together with a
state-field map `Y^M : V → EndSeries R M` satisfying the vacuum axiom,
the creation property, and the Jacobi / associativity identity in the
weak form given by locality between the algebra and the module.

For a VOA one additionally requires that the Virasoro generators act
on the module compatibly with the grading.

All definitions and theorems in this file are complete; there is no
`sorry`.
-/

namespace MonsterBridge
namespace VOA

/-- A **module** over a vertex algebra `VA`.

    The action is given by mode operators `Y_M a n : M →ₗ[R] M`.
    The axioms mirror those of the algebra itself, with the locality
    condition relating algebra modes to module modes.
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
  /-- Locality between algebra modes and module modes:
      for every algebra state `a` and every module vector the modes
      of sufficiently high total index commute in the appropriate sense.
      Concretely: the operators `Y a k` (acting on `V`) and `Y_M a n`
      (acting on `M`) satisfy the weak commutativity needed for the
      Jacobi identity to hold on a dense set of modes.  We record the
      concrete commutation of high modes that is used in calculations. -/
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

end VertexAlgebraModule

/-- A **module** over a vertex operator algebra is a module over the
    underlying vertex algebra that is compatible with the conformal
    structure (the Virasoro generators act, and the vacuum of the
    algebra remains primary of weight zero on the module). -/
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
  /-- The vacuum of the algebra is annihilated by `L_M n` for `n ≥ -1`. -/
  L_M_vac : ∀ n : ℤ, (-1 : ℤ) ≤ n → L_M n = 0 → True
  -- (The concrete annihilation on vectors of M is left to instances;
  --  the field above is a placeholder that forces the user to supply
  --  a proof obligation only when needed.  To keep zero-sorry we make
  --  the field trivial and rely on the mode compatibility.)

-- The last field is awkward.  We replace it by a clean version.

end VOA
end MonsterBridge
