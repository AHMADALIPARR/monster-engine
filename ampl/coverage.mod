# AMPL-format model -- separate artifact, NOT executed by AMPL.
# Header: This file is written in AMPL syntax. AMPL is not installed
# in this environment, and this file has NOT been executed by an AMPL
# runtime (not-executed-by-AMPL). The executable form of the same
# model is ampl/coverage.lp, run by HiGHS via ampl/run_coverage.sh;
# see ampl/coverage-run.txt for the solver output and
# ampl/coverage_brute.py for the brute-force optimum (cost 20).
#
# Dependency-coverage model: select a minimum-cost set of
# verification tasks covering all 20 machine-checkable contract items
# from contracts/families.json. All depends_on targets of checkable
# items are themselves checkable, so a feasible cover of all 20 items
# is dependency-closed.

set TASKS := {mon_core, mon_repr, mon_full, moon_data, moon_j,
              lie_bracket, lie_full, lie_action, geo_grid, geo_full,
              geo_measure, cross_finite};

set ITEMS := {MON-identity, MON-closure, MON-associativity, MON-inverses,
              MON-homomorphism, MON-nonhomomorphism, MON-character-compat,
              MON-conjugacy, MOON-j-coeffs, MOON-mckay-identity,
              MOON-character-decomposition, LIE-structure-constants,
              LIE-antisymmetry, LIE-jacobi, LIE-action-composition,
              GEO-subdivision, GEO-forward-inverse, GEO-tensor-shape,
              GEO-reconstruction, GEO-rank-preservation};

param cost {TASKS};
param covers {TASKS, ITEMS} default 0;

var x {TASKS} binary;

minimize total_cost:
    sum {t in TASKS} cost[t] * x[t];

subject to cover_item {i in ITEMS}:
    sum {t in TASKS} covers[t, i] * x[t] >= 1;

data;

param cost :=
    mon_core 4
    mon_repr 4
    mon_full 7
    moon_data 3
    moon_j 2
    lie_bracket 3
    lie_full 5
    lie_action 2
    geo_grid 3
    geo_full 5
    geo_measure 3
    cross_finite 2;

param covers :=
    [mon_core, MON-identity] 1
    [mon_core, MON-closure] 1
    [mon_core, MON-associativity] 1
    [mon_core, MON-inverses] 1
    [mon_repr, MON-homomorphism] 1
    [mon_repr, MON-nonhomomorphism] 1
    [mon_repr, MON-character-compat] 1
    [mon_repr, MON-conjugacy] 1
    [mon_full, MON-identity] 1
    [mon_full, MON-closure] 1
    [mon_full, MON-associativity] 1
    [mon_full, MON-inverses] 1
    [mon_full, MON-homomorphism] 1
    [mon_full, MON-nonhomomorphism] 1
    [mon_full, MON-character-compat] 1
    [mon_full, MON-conjugacy] 1
    [moon_data, MOON-j-coeffs] 1
    [moon_data, MOON-mckay-identity] 1
    [moon_data, MOON-character-decomposition] 1
    [moon_j, MOON-j-coeffs] 1
    [moon_j, MOON-mckay-identity] 1
    [lie_bracket, LIE-structure-constants] 1
    [lie_bracket, LIE-antisymmetry] 1
    [lie_bracket, LIE-jacobi] 1
    [lie_full, LIE-structure-constants] 1
    [lie_full, LIE-antisymmetry] 1
    [lie_full, LIE-jacobi] 1
    [lie_full, LIE-action-composition] 1
    [lie_action, LIE-action-composition] 1
    [lie_action, GEO-tensor-shape] 1
    [geo_grid, GEO-subdivision] 1
    [geo_grid, GEO-forward-inverse] 1
    [geo_grid, GEO-tensor-shape] 1
    [geo_full, GEO-subdivision] 1
    [geo_full, GEO-forward-inverse] 1
    [geo_full, GEO-tensor-shape] 1
    [geo_full, GEO-reconstruction] 1
    [geo_full, GEO-rank-preservation] 1
    [geo_measure, GEO-subdivision] 1
    [geo_measure, GEO-reconstruction] 1
    [geo_measure, GEO-rank-preservation] 1
    [cross_finite, MON-closure] 1
    [cross_finite, LIE-jacobi] 1
    [cross_finite, GEO-subdivision] 1;
