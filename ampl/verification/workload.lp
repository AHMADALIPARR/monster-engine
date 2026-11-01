\ Verification-workload allocation model (LP format, executed by HiGHS)
\ Tasks: t1 cost 3 coverage 10; t2 cost 2 coverage 9; t3 cost 4 coverage 13; t4 cost 3 coverage 8
\ Budget B = 8 hours. Linking constraint: t2 requires t1 (t2 - t1 <= 0).
\ Hand-computed optimum: t1 + t2 + t4, cost 3 + 2 + 3 = 8, coverage 10 + 9 + 8 = 27.
\ Full hand enumeration is in README.md next to this file.
Maximize
 obj: 10 t1 + 9 t2 + 13 t3 + 8 t4
Subject To
 budget: 3 t1 + 2 t2 + 4 t3 + 3 t4 <= 8
 link: - t1 + t2 <= 0
Binary
 t1 t2 t3 t4
End
