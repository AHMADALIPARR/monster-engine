-- MoonshineChain.curry -- the named moonshine claim chain, as Horn
-- facts mirroring counterexamples/moonshine_dependencies.json and
-- its source alloy/moonshine_dependencies.als.
--
-- The Alloy model's DependencyChain fact fixes a four-node chain
-- (dependsOn points from a claim to the claim it rests on):
--
--   JCoeff2    dependsOn JCoeff1
--   McKayDecomp dependsOn JCoeff2
--   GradedDim  dependsOn McKayDecomp
--   JCoeff1    dependsOn (nothing)
--
-- i.e. the J-coefficient claims are the established data at the
-- base, the McKay decomposition rests on them, and the graded
-- dimensions rest on the decomposition.  Those node names are the
-- Alloy model's; the families.json corpus carries the same chain
-- under its own ids (MOON-j-coeffs, MOON-mckay-identity /
-- MOON-character-decomposition, MOON-partition-constraints), which
-- is the primary corpus resolved in Resolve.curry.  This module is
-- the auxiliary mirror the directive asks for; no status labeling
-- is asserted here (in the Alloy model, Established/Conjecture is a
-- separate Labeling, not a property of the chain itself).
module MoonshineChain where

moonClaim :: String -> Bool
moonClaim "JCoeff1" = True
moonClaim "JCoeff2" = True
moonClaim "McKayDecomp" = True
moonClaim "GradedDim" = True

moonDependsOn :: String -> String -> Bool
moonDependsOn "JCoeff2" "JCoeff1" = True
moonDependsOn "McKayDecomp" "JCoeff2" = True
moonDependsOn "GradedDim" "McKayDecomp" = True
