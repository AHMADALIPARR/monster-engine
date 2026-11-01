# jacobi.ua — Jacobi residual of a concrete three-dimensional Lie algebra,
# computed with native Uiua 0.19.1 array operations.
# 
# The algebra is so(3), the cross-product algebra on basis e0, e1, e2:
#   [e0, e1] = e2,  [e1, e2] = e0,  [e2, e0] = e1,
# with antisymmetric completion and [ei, ei] = 0.
# Its structure constants are the Levi-Civita tensor: C_ijk is +1 for
# (i, j, k) a cyclic permutation of (0, 1, 2), -1 for an anticyclic
# permutation, and 0 otherwise, where
#   bracket(x, y)_k = sum over i, j of x_i * y_j * C_ijk.
# 
# The Jacobi residual tensor is, for all i, j, k, l,
#   J_ijkl = sum over m of
#       C_ijm * C_mkl + C_jkm * C_mil + C_kim * C_mjl,
# and this program prints its maximum absolute component, first for the
# algebra above (the value is 0: this algebra satisfies the Jacobi
# identity) and then for a perturbed constant table with C_012 set to 2
# (the value is nonzero: the check discriminates).
# 
# How the contraction is done in Uiua:
#   Let G_abcd = sum over m of C_abm * C_mcd. Reshaping C to a 9x3 array
#   (rows (a, b), columns m) and to a 3x9 array (rows m, columns (c, d))
#   turns G into one matrix product, evaluated with table and a dot
#   product:  G = table(dot, A, transpose(B))  in glyphs below.
#   The first Jacobi term is G read as (i, j, k, l). The second term is
#   G read as (j, k, i, l) and the third as (k, i, j, l); both readings
#   are index permutations of the flattened 81 components of G, applied
#   with select and index arrays built by broadcasting the range 0 1 2
#   over four axes of lengths 3, 1, 1, 1 and so on.
#   Subtraction note: in Uiua 0.19.1, "- X Y" evaluates to Y - X; this
#   program only takes absolute values of differences, where the order
#   does not matter, except where a comment says otherwise.
# 
# Exactness: every constant is -1, 0, 1, or 2, every product and sum is
# a small integer, and Uiua floats represent such integers exactly.

# Flat row-major structure constants, index i * 9 + j * 3 + k.
Cf ← [0 0 0 0 0 1 0 ¯1 0 0 0 ¯1 0 0 0 1 0 0 0 1 0 ¯1 0 0 0 0 0]
C  ← ↯[3 3 3] Cf

# Sanity prints of the encoded bracket table: [e0, e1] and [e1, e2].
&p "bracket_e0_e1"
&p ⊏ 1 ⊏ 0 C
&p "bracket_e1_e2"
&p ⊏ 2 ⊏ 1 C

# Permutation index arrays for the second and third Jacobi terms.
# For target component (i, j, k, l) of the second term the source flat
# index in G is j * 27 + k * 9 + i * 3 + l, and for the third term it
# is k * 27 + i * 9 + j * 3 + l.
R  ← ⇡3
Ix ← ↯[3 1 1 1] R
Jx ← ↯[1 3 1 1] R
Kx ← ↯[1 1 3 1] R
Lx ← ↯[1 1 1 3] R
St ← + + ×27 Jx ×9 Kx + ×3 Ix Lx
Su ← + + ×27 Kx ×9 Ix + ×3 Jx Lx

# Unperturbed constants: G, then J = G + permuted G + permuted G.
A  ← ↯[9 3] Cf
B  ← ↯[3 9] Cf
G  ← ⊞(/+ ×) A ⍉B
Gf ← ↯[81] G
Gt ← ⊏ St Gf
Gu ← ⊏ Su Gf
Gq ← ↯[3 3 3 3] Gf
J  ← + Gq + Gt Gu
&p "jacobi_max_abs_unperturbed"
&p /↥ ⌵ ↯[81] J

# Perturbed constants: the same computation with C_012 (flat index 5)
# changed from 1 to 2. All other entries are unchanged.
Cf ← [0 0 0 0 0 2 0 ¯1 0 0 0 ¯1 0 0 0 1 0 0 0 1 0 ¯1 0 0 0 0 0]
A  ← ↯[9 3] Cf
B  ← ↯[3 9] Cf
G  ← ⊞(/+ ×) A ⍉B
Gf ← ↯[81] G
Gt ← ⊏ St Gf
Gu ← ⊏ Su Gf
Gq ← ↯[3 3 3 3] Gf
J  ← + Gq + Gt Gu
&p "jacobi_max_abs_perturbed"
&p /↥ ⌵ ↯[81] J
