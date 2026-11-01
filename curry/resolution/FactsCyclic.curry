-- FactsCyclic.curry -- a SEPARATE, deliberately cyclic fact set.
--
-- This file is not generated and does not come from families.json
-- (families.json is a DAG; the contracts schema validator enforces
-- acyclicity there).  It exists only to demonstrate, inside
-- Resolve.curry, that the fuel-bounded transitive closure
-- (clause family cycTransN, the reachN pattern of the Phase 1
-- battery's Cycle.curry) terminates on a cyclic graph where the
-- unbounded closure of Resolve.curry would loop: a depends on b
-- and b depends on a.
module FactsCyclic where

cycDependsOn :: String -> String -> Bool
cycDependsOn "a" "b" = True
cycDependsOn "b" "a" = True
