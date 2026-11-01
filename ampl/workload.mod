# AMPL-format model -- separate artifact, NOT executed.
# Header: This file is written in AMPL syntax. AMPL is not installed
# in this environment, and this file has NOT been executed by an
# AMPL runtime. The executable verification of the same model was
# performed by HiGHS on the LP-format file
# ampl/verification/workload.lp (see ampl/verification/highs-run.txt).
#
# Verification-workload allocation model.
# Tasks: t1 cost 3 coverage 10; t2 cost 2 coverage 9;
#        t3 cost 4 coverage 13; t4 cost 3 coverage 8
# Budget B = 8 hours. Linking constraint: t2 requires t1 (t2 <= t1).
# Hand-computed optimum: t1 + t2 + t4, cost 3 + 2 + 3 = 8,
# coverage 10 + 9 + 8 = 27.

set TASKS := {t1, t2, t3, t4};

param cost {TASKS};
param coverage {TASKS};
param budget := 8;

var x {TASKS} binary;

maximize total_coverage:
    sum {t in TASKS} coverage[t] * x[t];

subject to hours_budget:
    sum {t in TASKS} cost[t] * x[t] <= budget;

subject to t2_requires_t1:
    x[t2] <= x[t1];

data;

param cost :=
    t1 3
    t2 2
    t3 4
    t4 3;

param coverage :=
    t1 10
    t2 9
    t3 13
    t4 8;
