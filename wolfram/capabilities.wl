(* capabilities.wl -- Mathics3 capability probe, MONSTER-BRIDGE *)
(* *)
(* Runtime: Mathics3 10.0.1, invoked as `mathics -f capabilities.wl`. *)
(* Mathics3 is not Mathematica. *)
(* *)
(* Method: straight-line code only. Mathics3 has no working *)
(* TestReport / VerificationTest (both return unevaluated, as *)
(* this probe itself demonstrates), so each operation is run *)
(* on a tiny input and checked explicitly: either the result *)
(* matches the expected evaluated form (SameQ), or its Head *)
(* is still the operation name, which means it returned *)
(* unevaluated. An unevaluated return is reported as *)
(*   CAPABILITY_FAILURE: <op> unevaluated ... *)
(* and is never presented as a computed result. *)
(* *)
(* Required vs optional: *)
(*   REQUIRED: Expand, Factor, Coefficient, Part *)
(*     Factor is required because a pre-write probe showed it *)
(*     evaluates in Mathics3 10.0.1: Factor[x^2 - 1] gave *)
(*     (-1 + x) (1 + x) with Head Times. If a future run finds *)
(*     it unevaluated, this script reports it as a required *)
(*     failure and exits nonzero; it would then need to be *)
(*     demoted to optional-with-failure-line in the report. *)
(*   OPTIONAL: Simplify, Series, BitAnd, TestReport, *)
(*             VerificationTest *)
(*     An optional CAPABILITY_FAILURE line is a PASS for *)
(*     honesty: the gap is recorded explicitly, not hidden. *)
(* *)
(* Exit code: 0 if every REQUIRED operation is SUPPORTED, *)
(* 1 if any REQUIRED operation fails. Optional failures do *)
(* not change the exit code. *)

Print["=== capabilities.wl (Mathics3) ==="]
requiredFailures = 0

(* --- Expand (REQUIRED) --- *)
expR = Expand[(x + y)^2]
expOk = (expR === x^2 + 2 x y + y^2)
If[expOk, Print["SUPPORTED: Expand result = ", expR]]
If[!expOk, Print["CAPABILITY_FAILURE: Expand unevaluated or unexpected result on (x + y)^2, got ", expR]]
If[!expOk, requiredFailures = requiredFailures + 1]

(* --- Factor (REQUIRED) --- *)
facR = Factor[x^2 - 1]
facOk = (facR === (x - 1) (x + 1))
If[facOk, Print["SUPPORTED: Factor result = ", facR]]
If[!facOk, Print["CAPABILITY_FAILURE: Factor unevaluated or unexpected result on x^2 - 1, got ", facR]]
If[!facOk, requiredFailures = requiredFailures + 1]

(* --- Coefficient (REQUIRED) --- *)
coefR = Coefficient[744 + 196884 q + 21493760 q^2 + 864299970 q^3, q, 1]
coefOk = (coefR === 196884)
If[coefOk, Print["SUPPORTED: Coefficient result = ", coefR]]
If[!coefOk, Print["CAPABILITY_FAILURE: Coefficient unevaluated or unexpected result on jPoly, q, 1, got ", coefR]]
If[!coefOk, requiredFailures = requiredFailures + 1]

(* --- Part (REQUIRED, coefficient extraction alternative) --- *)
partR = Part[{744, 196884, 21493760, 864299970}, 2]
partOk = (partR === 196884)
If[partOk, Print["SUPPORTED: Part result = ", partR]]
If[!partOk, Print["CAPABILITY_FAILURE: Part unevaluated or unexpected result on {744, 196884, 21493760, 864299970}, 2, got ", partR]]
If[!partOk, requiredFailures = requiredFailures + 1]

(* --- Simplify (OPTIONAL) --- *)
simpR = Simplify[(x^2 - 1)/(x - 1)]
simpOk = (simpR === 1 + x)
If[simpOk, Print["SUPPORTED: Simplify result = ", simpR]]
If[!simpOk, Print["CAPABILITY_FAILURE: Simplify unevaluated or unexpected result on (x^2 - 1)/(x - 1), got ", simpR]]

(* --- Series (OPTIONAL) --- *)
serR = Series[Exp[x], {x, 0, 3}]
serUnevaluated = (Head[serR] === Series)
If[!serUnevaluated, Print["SUPPORTED: Series result = ", serR]]
If[serUnevaluated, Print["CAPABILITY_FAILURE: Series unevaluated on Exp[x], {x, 0, 3}"]]

(* --- BitAnd (OPTIONAL) --- *)
bitR = BitAnd[5, 3]
bitUnevaluated = (Head[bitR] === BitAnd)
If[!bitUnevaluated, Print["SUPPORTED: BitAnd result = ", bitR]]
If[bitUnevaluated, Print["CAPABILITY_FAILURE: BitAnd unevaluated on BitAnd[5, 3], expected 1 - Bit* builtins are not evaluated by Mathics3"]]

(* --- TestReport (OPTIONAL) --- *)
trR = TestReport["capabilities probe"]
trUnevaluated = (Head[trR] === TestReport)
If[!trUnevaluated, Print["SUPPORTED: TestReport result = ", trR]]
If[trUnevaluated, Print["CAPABILITY_FAILURE: TestReport unevaluated - TestReport is not implemented in Mathics3"]]

(* --- VerificationTest (OPTIONAL) --- *)
vtR = VerificationTest[1 + 1, 2]
vtUnevaluated = (Head[vtR] === VerificationTest)
If[!vtUnevaluated, Print["SUPPORTED: VerificationTest result = ", vtR]]
If[vtUnevaluated, Print["CAPABILITY_FAILURE: VerificationTest unevaluated - VerificationTest is not implemented in Mathics3"]]

Print["Required failures: ", requiredFailures]
If[requiredFailures > 0, Print["capabilities.wl: FAIL - one or more REQUIRED operations failed"]]
If[requiredFailures > 0, Exit[1]]
Print["capabilities.wl: PASS - all REQUIRED operations SUPPORTED (optional failures above, if any, are explicit)"]
Exit[0]
