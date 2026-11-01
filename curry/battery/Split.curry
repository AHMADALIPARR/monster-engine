-- Battery (b): logic variables and unification.
-- The expression (xs ++ ys) is unified with [1,2] via the equational
-- constraint (=:=). xs and ys are free (logic) variables; encapsulating
-- the expression with getAllValues enumerates every unifier, i.e. every
-- split of the list [1,2] into a prefix and a suffix.
module Split where

import Control.Search.AllValues ( getAllValues )

split12 :: ([Int], [Int])
split12 | xs ++ ys =:= [1, 2] = (xs, ys)
  where xs, ys free

main :: IO ()
main = do
  splits <- getAllValues split12
  print splits
