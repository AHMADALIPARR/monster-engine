-- Battery (g), naive driver: the unbounded cyclic query.
-- main asks for every value of (reach "a" "zzz"), where "zzz" is
-- unreachable and the edge graph contains the cycle a -> b -> a.
-- The naive closure keeps extending paths around the cycle, so this
-- evaluation is expected not to terminate; the battery runs it under
-- an external timeout and records the observed behaviour verbatim.
module CycleNaive where

import Control.Search.AllValues ( getAllValues )
import Cycle ( reach )

main :: IO ()
main = do
  miss <- getAllValues (reach "a" "zzz")
  print miss
