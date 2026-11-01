import Mathlib

/-!
# Representation homomorphisms compose

A *representation* of a group `G` is modelled here abstractly as a monoid
homomorphism out of `G` — for example `G →* Equiv.Perm α` (a permutation
representation) or `G →* H` into another group.  The results below are about
homomorphisms in general: composition of two of them is again a homomorphism
(it is *defined* as one by `MonoidHom.comp`, and we prove its computation
rules), the identity homomorphism is a two-sided unit for composition, and
composition is associative.

These are abstract theorems.  Nothing here constructs a representation of
any particular group (e.g. the Monster) or asserts that one exists.
-/

namespace MonsterBridge
namespace Representation

variable {G H K L : Type*} [Group G] [Group H] [Group K] [Group L]

/-- Computation rule for a composed representation: applying `ψ ∘ φ` is
    applying `φ` first and then `ψ`. -/
theorem comp_apply (φ : G →* H) (ψ : H →* K) (g : G) :
    (ψ.comp φ) g = ψ (φ g) :=
  MonoidHom.comp_apply ψ φ g

/-- The composite of two representation homomorphisms preserves
    multiplication — i.e. the composite really is a homomorphism, checked
    directly on products. -/
theorem comp_map_mul (φ : G →* H) (ψ : H →* K) (a b : G) :
    (ψ.comp φ) (a * b) = (ψ.comp φ) a * (ψ.comp φ) b := by
  simp only [MonoidHom.comp_apply, map_mul]

/-- The composite of two representation homomorphisms preserves the
    identity element. -/
theorem comp_map_one (φ : G →* H) (ψ : H →* K) :
    (ψ.comp φ) 1 = 1 := by
  simp only [MonoidHom.comp_apply, map_one]

/-- The identity representation composed on the left is the identity
    operation on representations: `id ∘ φ = φ`. -/
theorem id_comp_repr (φ : G →* H) :
    (MonoidHom.id H).comp φ = φ :=
  MonoidHom.id_comp φ

/-- Composing with the identity representation on the right changes
    nothing: `φ ∘ id = φ`.  This is the headline theorem of this file. -/
theorem comp_id_repr (φ : G →* H) :
    φ.comp (MonoidHom.id G) = φ :=
  MonoidHom.comp_id φ

/-- Composition of representation homomorphisms is associative. -/
theorem comp_assoc_repr (φ : G →* H) (ψ : H →* K) (χ : K →* L) :
    (χ.comp ψ).comp φ = χ.comp (ψ.comp φ) :=
  MonoidHom.comp_assoc φ ψ χ

/-- Specialisation to permutation representations: composing two
    permutation representations of `G` pointwise is `ψ` after `φ`. -/
theorem perm_comp_apply {α : Type*} (φ : G →* Equiv.Perm α) (ψ : Equiv.Perm α →* Equiv.Perm α)
    (g : G) (x : α) :
    ((ψ.comp φ) g) x = (ψ (φ g)) x :=
  rfl

end Representation
end MonsterBridge

#print axioms MonsterBridge.Representation.comp_id_repr
