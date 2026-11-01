-- Battery (g): cyclic goals and bounded search.
-- The edge graph contains a cycle: a -> b -> a, plus b -> c.
-- reach is the naive recursive closure. reachN is the same closure
-- with an explicit fuel parameter bounding the recursion depth.
-- main asks, through the bounded reachN with fuel 5:
--   * every value of (reachN 5 "a" "zzz") -- "zzz" is unreachable, and
--     the unbounded version of this query loops around the a-b cycle
--     forever (see CycleNaive, run under an external timeout);
--     the bounded version terminates with the empty list.
--   * every y with reachN 5 "a" y -- reachability within the bound
--     still succeeds, returning each of b, a and c once per distinct
--     derivation path that stays within the fuel bound.
module Cycle where

import Control.Search.AllValues ( getAllValues )

edge :: String -> String -> Bool
edge "a" "b" = True
edge "b" "a" = True
edge "b" "c" = True

reach :: String -> String -> Bool
reach x y | edge x y = True
reach x z | edge x y && reach y z = True
  where y free

reachN :: Int -> String -> String -> Bool
reachN _ x y | edge x y = True
reachN n x z | n > 0 && edge x y && reachN (n - 1) y z = True
  where y free

reachTarget :: Int -> String -> String
reachTarget n a | reachN n a y = y
  where y free

main :: IO ()
main = do
  miss <- getAllValues (reachN 5 "a" "zzz")
  print miss
  hits <- getAllValues (reachTarget 5 "a")
  print hits
