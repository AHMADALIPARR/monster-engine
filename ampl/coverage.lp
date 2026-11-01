\ Dependency-coverage model (LP format, executed by HiGHS via ampl/run_coverage.sh)
\ Universe: the 20 machine-checkable contract items in contracts/families.json
\ (every item whose kind is not abstract-only). One covering constraint per item.
\ Tasks and costs: mon_core 4, mon_repr 4, mon_full 7, moon_data 3, moon_j 2,
\ lie_bracket 3, lie_full 5, lie_action 2, geo_grid 3, geo_full 5,
\ geo_measure 3, cross_finite 2.
\ All depends_on targets of checkable items are themselves checkable, so any
\ feasible cover of all 20 items is dependency-closed.
\ Brute-force optimum (ampl/coverage_brute.py, all 4096 subsets): cost 20.
Minimize
 obj: 4 mon_core + 4 mon_repr + 7 mon_full + 3 moon_data + 2 moon_j + 3 lie_bracket + 5 lie_full + 2 lie_action + 3 geo_grid + 5 geo_full + 3 geo_measure + 2 cross_finite
Subject To
 cov_mon_identity: mon_core + mon_full >= 1
 cov_mon_closure: cross_finite + mon_core + mon_full >= 1
 cov_mon_associativity: mon_core + mon_full >= 1
 cov_mon_inverses: mon_core + mon_full >= 1
 cov_mon_homomorphism: mon_full + mon_repr >= 1
 cov_mon_nonhomomorphism: mon_full + mon_repr >= 1
 cov_mon_character_compat: mon_full + mon_repr >= 1
 cov_mon_conjugacy: mon_full + mon_repr >= 1
 cov_moon_j_coeffs: moon_data + moon_j >= 1
 cov_moon_mckay_identity: moon_data + moon_j >= 1
 cov_moon_character_decomposition: moon_data >= 1
 cov_lie_structure_constants: lie_bracket + lie_full >= 1
 cov_lie_antisymmetry: lie_bracket + lie_full >= 1
 cov_lie_jacobi: cross_finite + lie_bracket + lie_full >= 1
 cov_lie_action_composition: lie_action + lie_full >= 1
 cov_geo_subdivision: cross_finite + geo_full + geo_grid + geo_measure >= 1
 cov_geo_forward_inverse: geo_full + geo_grid >= 1
 cov_geo_tensor_shape: geo_full + geo_grid + lie_action >= 1
 cov_geo_reconstruction: geo_full + geo_measure >= 1
 cov_geo_rank_preservation: geo_full + geo_measure >= 1
Binary
 mon_core mon_repr mon_full moon_data moon_j lie_bracket lie_full lie_action geo_grid geo_full geo_measure cross_finite
End
