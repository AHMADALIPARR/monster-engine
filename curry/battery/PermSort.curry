-- Battery (e): recursive backtracking search.
-- insert places its first argument nondeterministically at every
-- position of a list, so perm enumerates all permutations of its input
-- (3! = 6 for a 3-element list, all shown by main). psort keeps only
-- the permutation satisfying isSorted: the evaluator must generate
-- candidate permutations and backtrack out of the unsorted ones until
-- the sorted permutation is found. getAllValues of psort [3,1,2] contains
-- exactly the one sorted result, which is only possible if the five
-- failing candidates were explored and abandoned by backtracking.
module PermSort where

import Control.Search.AllValues ( getAllValues )

insert :: a -> [a] -> [a]
insert x ys     = x : ys
insert x (y:ys) = y : insert x ys

perm :: [a] -> [a]
perm []     = []
perm (x:xs) = insert x (perm xs)

isSorted :: [Int] -> Bool
isSorted []       = True
isSorted [_]      = True
isSorted (x:y:zs) = x <= y && isSorted (y : zs)

psort :: [Int] -> [Int]
psort xs | isSorted ys = ys
  where ys = perm xs

main :: IO ()
main = do
  allPerms <- getAllValues (perm [3, 1, 2] :: [Int])
  print allPerms
  sorted <- getAllValues (psort [3, 1, 2])
  print sorted
