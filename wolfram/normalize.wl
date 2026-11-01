(* normalize.wl -- Mathics3 / Wolfram subsystem, MONSTER-BRIDGE *)
(* *)
(* Purpose: define the J-function coefficients as published data, *)
(* expand / factor two polynomial identities symbolically, verify *)
(* McKay arithmetic, and compute exact rational ratios/differences. *)
(* *)
(* Runtime: Mathics3 10.0.1, invoked as `mathics -f normalize.wl`. *)
(* Mathics3 is not Mathematica. No Mathematica-only feature is *)
(* claimed or relied on here. Every operation used is checked at *)
(* run time: if it returns unevaluated (Head unchanged), this *)
(* script prints CAPABILITY_FAILURE: <op> and exits nonzero, *)
(* rather than presenting an unevaluated form as a result. *)
(* *)
(* Published data: the q-expansion of the modular j-function is *)
(*   j(tau) = q^-1 + 744 + 196884 q + 21493760 q^2 *)
(*            + 864299970 q^3 + ... *)
(* where q = Exp[2 Pi I tau]. The coefficients 744, 196884, *)
(* 21493760, 864299970 below are established published data *)
(* (the constant term and the coefficients of q, q^2, q^3), *)
(* reproduced here as data, not derived by this script. *)
(* The McKay observation checked below is the published *)
(* identity 196884 = 196883 + 1, where 196883 is the dimension *)
(* of the smallest faithful representation of the Monster *)
(* group and 196884 is the q^1 coefficient above. *)

Print["=== normalize.wl (Mathics3) ==="]

(* ---------------------------------------------------------- *)
(* (a) J-function coefficient list as data                    *)
(* ---------------------------------------------------------- *)

jCoeffs = {744, 196884, 21493760, 864299970}
Print["J coefficients (published data): jCoeffs = ", jCoeffs]
Print["J c0 (constant term, coefficient of q^0): ", jCoeffs[[1]]]
Print["J c1 (coefficient of q^1): ", jCoeffs[[2]]]
Print["J c2 (coefficient of q^2): ", jCoeffs[[3]]]
Print["J c3 (coefficient of q^3): ", jCoeffs[[4]]]
Print["J polynomial (truncated, without q^-1 term): jPoly = 744 + 196884 q + 21493760 q^2 + 864299970 q^3"]

jPoly = 744 + 196884 q + 21493760 q^2 + 864299970 q^3
Print["J polynomial evaluated: ", jPoly]

(* ---------------------------------------------------------- *)
(* (b) Polynomial identities: Expand and Factor               *)
(* Both Expand and Factor were probed before this script was *)
(* written and both evaluate in Mathics3 10.0.1 (see          *)
(* capabilities.wl and outputs/capabilities.out). Each use   *)
(* below is nevertheless guarded: an unevaluated return is a *)
(* capability failure, not a result.                          *)
(* ---------------------------------------------------------- *)

Print["--- Identity 1: (x + y)^2 expansion ---"]
orig1 = (x + y)^2
Print["Original 1: ", orig1]
exp1 = Expand[(x + y)^2]
If[Head[exp1] === Expand, Print["CAPABILITY_FAILURE: Expand unevaluated on (x + y)^2"]]
If[Head[exp1] === Expand, Exit[1]]
Print["Normalized 1 (Expand[(x + y)^2]): ", exp1]
check1 = (exp1 === x^2 + 2 x y + y^2)
Print["Identity check 1: Expand[(x + y)^2] == x^2 + 2 x y + y^2 : ", check1]
If[!check1, Print["CAPABILITY_FAILURE: Expand result did not match expected x^2 + 2 x y + y^2"]]
If[!check1, Exit[1]]

Print["--- Identity 2: x^2 - 1 factorization ---"]
orig2 = x^2 - 1
Print["Original 2: ", orig2]
fac2 = Factor[x^2 - 1]
If[Head[fac2] === Factor, Print["CAPABILITY_FAILURE: Factor unevaluated on x^2 - 1"]]
If[Head[fac2] === Factor, Exit[1]]
Print["Normalized 2 (Factor[x^2 - 1]): ", fac2]
check2 = (fac2 === (x - 1) (x + 1))
Print["Identity check 2: Factor[x^2 - 1] == (x - 1) (x + 1) : ", check2]
If[!check2, Print["CAPABILITY_FAILURE: Factor result did not match expected (x - 1) (x + 1)"]]
If[!check2, Exit[1]]

Print["--- Identity 2b: (x - 1) (x + 1) expansion (cross-check) ---"]
orig2b = (x - 1) (x + 1)
Print["Original 2b: ", orig2b]
exp2b = Expand[(x - 1) (x + 1)]
If[Head[exp2b] === Expand, Print["CAPABILITY_FAILURE: Expand unevaluated on (x - 1) (x + 1)"]]
If[Head[exp2b] === Expand, Exit[1]]
Print["Normalized 2b (Expand[(x - 1) (x + 1)]): ", exp2b]
check2b = (exp2b === x^2 - 1)
Print["Identity check 2b: Expand[(x - 1) (x + 1)] == x^2 - 1 : ", check2b]
If[!check2b, Print["CAPABILITY_FAILURE: Expand cross-check did not match expected x^2 - 1"]]
If[!check2b, Exit[1]]

(* Coefficient extraction cross-check, also guarded. *)
Print["--- Coefficient extraction cross-check ---"]
coef1 = Coefficient[jPoly, q, 1]
If[Head[coef1] === Coefficient, Print["CAPABILITY_FAILURE: Coefficient unevaluated on jPoly"]]
If[Head[coef1] === Coefficient, Exit[1]]
Print["Coefficient[jPoly, q, 1] = ", coef1]
coefCheck = (coef1 === 196884)
Print["Coefficient check: Coefficient[jPoly, q, 1] == 196884 : ", coefCheck]
If[!coefCheck, Print["CAPABILITY_FAILURE: Coefficient result did not match 196884"]]
If[!coefCheck, Exit[1]]
Print["Coefficient[jPoly, q, 0] = ", Coefficient[jPoly, q, 0]]
Print["Coefficient[jPoly, q, 2] = ", Coefficient[jPoly, q, 2]]
Print["Coefficient[jPoly, q, 3] = ", Coefficient[jPoly, q, 3]]

(* ---------------------------------------------------------- *)
(* (c) McKay arithmetic, symbolically / exactly               *)
(* ---------------------------------------------------------- *)

Print["--- McKay arithmetic ---"]
mckayDiff = 196884 - 196883
Print["McKay difference: 196884 - 196883 = ", mckayDiff]
mckayCheck = (196884 - 196883 == 1)
Print["McKay verification: 196884 - 196883 == 1 : ", mckayCheck]
If[!mckayCheck, Print["CAPABILITY_FAILURE: McKay arithmetic did not evaluate to True"]]
If[!mckayCheck, Exit[1]]
Print["McKay form: 196884 = 196883 + 1 : ", (196884 == 196883 + 1)]

(* ---------------------------------------------------------- *)
(* (d) Coefficient ratios and differences as exact rationals  *)
(* Division of integers in this system yields exact          *)
(* rationals (e.g. 196884/744 = 16407/62); no floating-point  *)
(* approximation is used or printed here.                     *)
(* ---------------------------------------------------------- *)

Print["--- Coefficient ratios (exact rationals) ---"]
Print["Ratio c1/c0: 196884/744 = ", jCoeffs[[2]]/jCoeffs[[1]]]
Print["Ratio c2/c1: 21493760/196884 = ", jCoeffs[[3]]/jCoeffs[[2]]]
Print["Ratio c3/c2: 864299970/21493760 = ", jCoeffs[[4]]/jCoeffs[[3]]]
Print["Ratio c1/196883: 196884/196883 = ", jCoeffs[[2]]/196883]

Print["--- Coefficient differences (exact integers) ---"]
Print["Difference c1 - c0: 196884 - 744 = ", jCoeffs[[2]] - jCoeffs[[1]]]
Print["Difference c2 - c1: 21493760 - 196884 = ", jCoeffs[[3]] - jCoeffs[[2]]]
Print["Difference c3 - c2: 864299970 - 21493760 = ", jCoeffs[[4]] - jCoeffs[[3]]]

Print["=== normalize.wl done ==="]
Exit[0]
