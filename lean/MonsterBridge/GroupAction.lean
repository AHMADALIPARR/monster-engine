import Mathlib

/-!
# Abstract group actions

Two parts:

* Part A uses Mathlib's `MulAction`.  There the two action laws *are* the
  class fields, so `one_smul` / `mul_smul` are one-liners; we say so plainly.
* Part B is a hand-rolled action: a function `act : G → α → α` together with
  the two laws as explicit hypotheses (fields of `HomAction`).  Everything in
  Part B is *derived* from those two laws alone: in particular the action of
  an inverse element is the inverse function of the action of the element,
  and a point fixed by `g` is also fixed by `g⁻¹`.

These are abstract theorems about any group action.  Nothing here asserts
that any particular group (e.g. the Monster) acts on any particular set.
-/

namespace MonsterBridge
namespace GroupAction

/-! ## Part A: Mathlib's `MulAction` -/

variable {G α : Type*} [Group G] [MulAction G α]

/-- Identity acts trivially.  This is Mathlib's `one_smul`, restated. -/
theorem one_act (x : α) : (1 : G) • x = x :=
  one_smul G x

/-- Compatibility of the action with group multiplication.
    This is Mathlib's `mul_smul`, restated. -/
theorem mul_act (g h : G) (x : α) : (g * h) • x = g • h • x :=
  mul_smul g h x

/-- Derived consequence: acting by `g` after `g⁻¹` is the identity.
    Proof: rewrite with the compatibility law `mul_smul`, then `simp`
    discharges `g * g⁻¹ = 1` (a group axiom) and `one_smul`.
    (In Mathlib 4.9 the name `mul_inv_cancel` denotes the `GroupWithZero`
    lemma, so the group cancellation is left to `simp` here.) -/
theorem inv_act_apply_inv (g : G) (x : α) : g • (g⁻¹ • x) = x := by
  rw [← mul_smul]
  simp

/-- Derived consequence: acting by `g⁻¹` after `g` is the identity. -/
theorem act_apply_inv_act (g : G) (x : α) : g⁻¹ • (g • x) = x := by
  rw [← mul_smul]
  simp

/-- Orbit-stabilizer-relevant lemma: a point fixed by `g` is fixed by `g⁻¹`. -/
theorem fixed_by_inv {g : G} {x : α} (h : g • x = x) : g⁻¹ • x = x := by
  have h' := act_apply_inv_act g x
  rw [h] at h'
  exact h'

/-! ## Part B: a hand-rolled action, consequences derived from the two laws -/

/-- A group action packaged by hand: the map `act` plus the two laws as
    fields.  The theorems below do *not* restate the fields; they derive
    new facts from them. -/
structure HomAction (G α : Type*) [Group G] where
  /-- The action map. -/
  act : G → α → α
  /-- Law 1: the identity element acts trivially. -/
  act_one : ∀ x : α, act 1 x = x
  /-- Law 2: the action respects group multiplication. -/
  act_mul : ∀ (g h : G) (x : α), act (g * h) x = act g (act h x)

namespace HomAction

variable {G α : Type*} [Group G] (A : HomAction G α)

/-- Acting by `g` after `g⁻¹` (with the hand-rolled action) is the identity.
    Proof uses only `act_mul` at `(g, g⁻¹)` and `act_one`. -/
theorem act_inv_apply (g : G) (x : α) : A.act g (A.act g⁻¹ x) = x := by
  calc A.act g (A.act g⁻¹ x) = A.act (g * g⁻¹) x := (A.act_mul g g⁻¹ x).symm
    _ = A.act 1 x := by simp
    _ = x := A.act_one x

/-- Acting by `g⁻¹` after `g` (with the hand-rolled action) is the identity. -/
theorem inv_act_apply (g : G) (x : α) : A.act g⁻¹ (A.act g x) = x := by
  calc A.act g⁻¹ (A.act g x) = A.act (g⁻¹ * g) x := (A.act_mul g⁻¹ g x).symm
    _ = A.act 1 x := by simp
    _ = x := A.act_one x

/-- `act g` is bijective, with inverse `act g⁻¹` (both directions proved
    above from the two laws alone). -/
theorem act_bijective (g : G) : Function.Bijective (A.act g) := by
  refine Function.bijective_iff_has_inverse.mpr ⟨A.act g⁻¹, ?_, ?_⟩
  · intro x
    exact A.inv_act_apply g x
  · intro x
    exact A.act_inv_apply g x

/-- A point fixed by `g` is also fixed by `g⁻¹` (hand-rolled version). -/
theorem fixed_by_inv {g : G} {x : α} (h : A.act g x = x) : A.act g⁻¹ x = x := by
  have h' := A.inv_act_apply g x
  rw [h] at h'
  exact h'

/-- The identity law, restated as a theorem about `HomAction`
    (this one *is* just the field, and is labelled as such). -/
theorem law_one (x : α) : A.act 1 x = x :=
  A.act_one x

/-- The multiplication law, restated as a theorem about `HomAction`
    (this one *is* just the field, and is labelled as such). -/
theorem law_mul (g h : G) (x : α) : A.act (g * h) x = A.act g (A.act h x) :=
  A.act_mul g h x

end HomAction

end GroupAction
end MonsterBridge

#print axioms MonsterBridge.GroupAction.HomAction.act_inv_apply
