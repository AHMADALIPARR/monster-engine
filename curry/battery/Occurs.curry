-- Battery (f): occurs-check behaviour.
-- The constraint x =:= N x (L 7) unifies a variable with a term that
-- contains the variable itself (the classic X = f(X) case). A system
-- performing an occurs check must reject this unification; a system
-- without one builds a cyclic (rational) tree.
--
-- probe walks down the left spine of a tree with a step budget and
-- returns 99 if the budget is exhausted before a leaf is reached.
-- For the cyclic value, probe 5 never reaches a leaf, so cycProbe
-- evaluates to 99 only if the cyclic unification succeeded.
-- main also evaluates a finite control term (probe 5 -> 7) and the
-- cyclic probe. Printing the cyclic term itself is attempted by the
-- separate driver OccursPrint, since forcing an infinite term to a
-- printed normal form is a different question from unifying it.
module Occurs where

import Control.Search.AllValues ( getAllValues )

data T = L Int | N T T
  deriving (Eq, Show)

probe :: Int -> T -> Int
probe 0 _       = 99
probe _ (L v)   = v
probe n (N l _) = probe (n - 1) l

cycProbe :: Int
cycProbe | x =:= N x (L 7) = probe 5 x
  where x free

finiteProbe :: Int
finiteProbe = probe 5 (N (N (L 7) (L 1)) (L 2))

main :: IO ()
main = do
  print finiteProbe
  vals <- getAllValues cycProbe
  print vals
