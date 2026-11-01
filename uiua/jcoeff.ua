# jcoeff.ua — arithmetic on the first coefficients of the modular
# j-function, as Uiua 0.19.1 array operations.
# 
# The coefficient array below holds established published values: the
# j-function expands as j(tau) = 1/q + 744 + 196884 q + 21493760 q^2
# + 864299970 q^3 + ..., so the constant term and the first three
# q-coefficients are 744, 196884, 21493760, 864299970.
# 
# Checks printed:
#   (a) the McKay observation: 196884 - 1 = 196883, where 196883 is the
#       dimension of the smallest nontrivial representation of the
#       Monster group and 196884 is the first q-coefficient above.
#   (b) the partial sums of the coefficient array (scan of +).
#   (c) the consecutive differences of the coefficient array.
# 
# Subtraction note: in Uiua 0.19.1, "- X Y" evaluates to Y - X, so the
# expressions below are ordered to produce (later value) - (earlier
# value) and (coefficient) - 1 respectively.
# 
# Exactness: Uiua numbers are double-precision floats. Every value
# here, and every sum and difference computed, is an integer below
# 2^53 (the largest is 885991358), hence exactly representable, so the
# printed integers are exact.

A ← [744 196884 21493760 864299970]

&p "coefficients"
&p A

# (a) McKay: the second coefficient minus 1.
&p "mckay_difference"
&p - 1 ⊏1 A

# (b) Partial sums: scan with +.
&p "partial_sums"
&p \+ A

# (c) Consecutive differences: drop-first-three minus ... read in
# Uiua order: "- (take 3 A) (drop 1 A)" is (drop 1 A) - (take 3 A),
# the array of A[i+1] - A[i].
&p "consecutive_differences"
&p - ↙3 A ↘1 A
