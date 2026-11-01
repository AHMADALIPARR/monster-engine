# transforms.ua — reversible versus irreversible coordinate transforms,
# checked by a forward-then-inverse reconstruction residual in Uiua
# 0.19.1.
# 
# Vectors are rows of V. A transform is a matrix applied on the right,
# W = V * P, evaluated with the table/dot-product matrix product
# idiom:  table(dot, V, transpose(P)).
# 
# Reversible case: P is the cyclic permutation matrix for the map
# (x, y, z) -> (z, x, y). A permutation matrix is exactly invertible
# over the integers, and its inverse is its transpose. Applying P and
# then its transpose must return V exactly; the printed maximum
# absolute reconstruction residual is 0.
# 
# Irreversible case: Q is the projection (x, y, z) -> (x, y, 0), which
# drops the third coordinate. Applying Q and then its transpose (Q is
# symmetric, and its transpose is the only candidate inverse this
# check uses) cannot restore the dropped coordinate; the printed
# residual is the largest dropped coordinate in V, which is nonzero.
# The same residual computation therefore discriminates between the
# two cases.
# 
# Exactness: all entries are small integers, exactly representable in
# Uiua floats, and every product and sum stays a small integer.

V ← [1_2_3 4_5_6 7_8_9 0_¯1_2]

# Cyclic permutation matrix: row i of P says where basis vector i goes
# under (x, y, z) -> (z, x, y), with W = V * P.
P ← [0_1_0 0_0_1 1_0_0]
W ← ⊞(/+ ×) V ⍉P
&p "forward_transformed"
&p W

# Inverse of a permutation matrix is its transpose.
Pt ← ⍉P
Bk ← ⊞(/+ ×) W ⍉Pt
&p "permutation_roundtrip_max_abs_residual"
&p /↥ ⌵ ↯[12] - V Bk

# Projection dropping the third coordinate, then its transpose.
Q  ← [1_0_0 0_1_0 0_0_0]
Z  ← ⊞(/+ ×) V ⍉Q
Zb ← ⊞(/+ ×) Z ⍉Q
&p "projection_roundtrip_max_abs_residual"
&p /↥ ⌵ ↯[12] - V Zb
