# equivariance.ua — composition consistency of the Klein four-group
# of flips acting on a 2x2 array, in Uiua 0.19.1.
# 
# The group Z2 x Z2 (Klein four) acts on a 2x2 array by index
# permutations: the identity, flip-rows (reverse the order of the
# rows), flip-cols (reverse each row), and flip-both (both, which is
# the 180-degree rotation). In Uiua glyphs:
#   flip-rows is reverse on the whole array,
#   flip-cols is rows-of-reverse (reverse applied to each row),
#   flip-both is the composition of the two.
# 
# This group is abelian: composing any two of its elements in either
# order gives the same array. This program composes the flips in both
# orders on the test array M = [[1, 2], [3, 4]] (all entries distinct,
# so any wrong permutation is visible) and prints the maximum absolute
# difference between the two orders for the three mixed pairs; each
# residual is 0. It also prints the residual between flip-rows applied
# twice and M itself: each flip is an involution.
# 
# Contrast: the transpose is a symmetry of the square that is not in
# this group, and flip-rows does not commute with it (together they
# generate the dihedral group). The last printed residual is the
# maximum absolute difference between the two orders of flip-rows and
# transpose, and it is nonzero, so the zero residuals above are not
# vacuous.

M  ← [1_2 3_4]
Fr ← ⇌ M
Fc ← ≡⇌ M
Fb ← ⇌ ≡⇌ M

&p "flip_both"
&p Fb

# Rows after cols, versus cols after rows.
Rc ← ⇌ Fc
Cr ← ≡⇌ Fr
&p "residual_rows_cols"
&p /↥ ⌵ ↯[4] - Rc Cr

# Both after rows, versus rows after both.
Rb ← ⇌ Fb
Br ← ⇌ ≡⇌ Fr
&p "residual_rows_both"
&p /↥ ⌵ ↯[4] - Rb Br

# Both after cols, versus cols after both.
Cb ← ≡⇌ Fb
Bc ← ⇌ ≡⇌ Fc
&p "residual_cols_both"
&p /↥ ⌵ ↯[4] - Cb Bc

# Involution: flip-rows twice returns M.
Rr ← ⇌ Fr
&p "residual_rows_twice_vs_original"
&p /↥ ⌵ ↯[4] - M Rr

# Contrast: flip-rows and transpose in the two orders.
&p "contrast_residual_transpose_rows"
&p /↥ ⌵ ↯[4] - ⇌ ⍉ M ⍉ ⇌ M
