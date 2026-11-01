-- Resolve.curry -- Phase 4: Horn-clause dependency resolution over
-- the contract claims of contracts/families.json, with derivation
-- trees and provenance.
--
-- Facts come from the generated module Facts (gen_facts.py):
--   item <id> <family> <kind>          -- one fact per item
--   dependsOn <item> <dependency>      -- one fact per depends_on edge
-- The cyclic demonstration uses the separate hand-written module
-- FactsCyclic (a depends on b, b depends on a).
--
-- Clause inventory (every derived claim below cites these by name):
--
--   dependsTrans-base : dependsTrans x y  if dependsOn x y.
--   dependsTrans-step : dependsTrans x z  if dependsOn x y and
--                       dependsTrans y z, for some intermediate y
--                       (a free logic variable).
--   checkable         : an item is checkable if its kind, as recorded
--                       in families.json, is not "abstract-only".
--   blocked-base      : an item is blocked if it is abstract-only.
--   blocked-step      : an item is blocked if it dependsOn an item
--                       that is blocked.  (blocked-base + blocked-step
--                       together give exactly: abstract-only items,
--                       plus everything that transitively depends on
--                       one.)
--   resolvable-set    : resolvable = all items minus the blocked
--                       set.  This is negation-as-failure done at the
--                       set level: the blocked set is computed by the
--                       positive Horn clauses above and enumerated
--                       with getAllValues, and resolvable is its
--                       complement in the finite item set.  No
--                       negation is used inside a clause body, which
--                       is the sound route in Curry: a clause-level
--                       "not blocked x" guard would be evaluated
--                       under an incomplete search and could succeed
--                       for the wrong reason.
--   derivation-base   : derivation of resolvable(x) when x is
--                       checkable and has no dependencies: a single
--                       Node citing derivation-base.
--   derivation-step   : derivation of resolvable(x) when x is
--                       checkable and has dependencies d1..dn: a
--                       Node citing derivation-step whose children
--                       are the derivations of resolvable(d1)..(dn).
--   moonTrans-base    : transitive closure over the auxiliary
--                       moonshine chain (MoonshineChain.curry,
--                       mirroring the Alloy moonshine model):
--                       moonTrans x y if moonDependsOn x y.
--   moonTrans-step    : moonTrans x z if moonDependsOn x y and
--                       moonTrans y z.
--   cycTransN-base    : fuel-bounded closure on FactsCyclic,
--                       one step: cycTransN n x y if cycDependsOn x y
--                       (fuel not consumed by the base clause, as in
--                       the Phase 1 battery's reachN).
--   cycTransN-step    : cycTransN n x z if n > 0, cycDependsOn x y
--                       and cycTransN (n-1) y z.
--
-- Substitutions: the graph is propositional over string ids, so the
-- substitution recorded at each derivation node is the binding of
-- the goal variable X to that node's item id, written "X := <id>",
-- together with the premise used at that node, namely the item's
-- kind fact ("kind=<kind> (item fact)").
module Resolve where

import Control.Search.AllValues ( getAllValues )
import Data.List ( nub, sort )
import Facts ( item, dependsOn )
import FactsCyclic ( cycDependsOn )
import MoonshineChain ( moonDependsOn )

-- ----------------------------------------------------------------
-- Basic accessors over the facts (free variables constrained by
-- the ground item / dependsOn facts).

itemId :: String
itemId | item x fam k = x
  where x, fam, k free

itemKindValue :: String -> String
itemKindValue x | item x fam k = k
  where fam, k free

directDepOf :: String -> String
directDepOf x | dependsOn x y = y
  where y free

-- ----------------------------------------------------------------
-- dependsTrans: transitive closure of dependsOn.
-- Clauses: dependsTrans-base, dependsTrans-step.

dependsTrans :: String -> String -> Bool
dependsTrans x y | dependsOn x y = True
dependsTrans x z | dependsOn x y && dependsTrans y z = True
  where y free

transDepOf :: String -> String
transDepOf x | dependsTrans x y = y
  where y free

-- ----------------------------------------------------------------
-- checkable / blocked.  Clauses: blocked-base, blocked-step.
-- resolvable is the complement of blocked (clause resolvable-set),
-- computed in main.

checkable :: String -> Bool
checkable x | item x fam k && k /= "abstract-only" = True
  where fam, k free

abstractOnly :: String -> Bool
abstractOnly x | item x fam "abstract-only" = True
  where fam free

blocked :: String -> Bool
blocked x | abstractOnly x = True
blocked x | dependsOn x y && blocked y = True
  where y free

blockedItem :: String
blockedItem | item x fam k && blocked x = x
  where x, fam, k free

-- ----------------------------------------------------------------
-- Derivation trees.  A Node carries: the item id, the name of the
-- clause used at this step, the substitution binding the goal
-- variable X to this item id, the premise (the item's kind fact),
-- and the sub-derivations of the item's direct dependencies.
-- Clauses: derivation-base, derivation-step.

data Derivation = Node String String String String [Derivation]
  deriving Show

derivationIO :: String -> IO Derivation
derivationIO x = do
  deps <- getAllValues (directDepOf x)
  kinds <- getAllValues (itemKindValue x)
  let kind = case kinds of
               (k : _) -> k
               []      -> "unknown"
  children <- derivationsIO deps
  let clause = if null deps then "derivation-base"
                            else "derivation-step"
  return (Node x clause ("X := " ++ x)
               ("kind=" ++ kind ++ " (item fact)") children)

derivationsIO :: [String] -> IO [Derivation]
derivationsIO [] = return []
derivationsIO (d : ds) = do
  t <- derivationIO d
  ts <- derivationsIO ds
  return (t : ts)

printDerivation :: String -> IO ()
printDerivation x = do
  putStrLn ("BEGIN-DERIVATION " ++ x)
  tree <- derivationIO x
  printNode 0 tree
  putStrLn ("END-DERIVATION " ++ x)

printNode :: Int -> Derivation -> IO ()
printNode depth (Node x clause subst premise children) = do
  putStrLn (concat (replicate depth "  ")
            ++ "NODE item=" ++ x
            ++ " clause=" ++ clause
            ++ " subst=\"" ++ subst ++ "\""
            ++ " premise=\"" ++ premise ++ "\"")
  printNodes (depth + 1) children

printNodes :: Int -> [Derivation] -> IO ()
printNodes _ [] = return ()
printNodes depth (t : ts) = do
  printNode depth t
  printNodes depth ts

-- ----------------------------------------------------------------
-- Transitive closure over the auxiliary moonshine chain.
-- Clauses: moonTrans-base, moonTrans-step (the same Horn pattern
-- as dependsTrans, applied to the MoonshineChain facts).

moonTrans :: String -> String -> Bool
moonTrans x y | moonDependsOn x y = True
moonTrans x z | moonDependsOn x y && moonTrans y z = True
  where y free

moonTransDepOf :: String -> String
moonTransDepOf x | moonTrans x y = y
  where y free

-- ----------------------------------------------------------------
-- Fuel-bounded transitive closure over the cyclic fact set.
-- Clauses: cycTransN-base, cycTransN-step.  The unbounded closure
-- over FactsCyclic would loop a -> b -> a -> ... forever (the same
-- behaviour the Phase 1 battery recorded for its naive closure);
-- the fuel parameter bounds the recursion depth, so this query
-- terminates with a bounded result.

cycTransN :: Int -> String -> String -> Bool
cycTransN _ x y | cycDependsOn x y = True
cycTransN n x z | n > 0 && cycDependsOn x y && cycTransN (n - 1) y z = True
  where y free

cycReachTarget :: Int -> String -> String
cycReachTarget n a | cycTransN n a y = y
  where y free

-- ----------------------------------------------------------------
-- main: enumerate the sets with getAllValues, print them in a
-- machine-checkable form, print two derivation trees, and print
-- the bounded cyclic result.

main :: IO ()
main = do
  allIds <- getAllValues itemId
  let allSorted = sort (nub allIds)
  putStrLn ("ALL: " ++ show allSorted)
  blockedIds <- getAllValues blockedItem
  let blockedSorted = sort (nub blockedIds)
  putStrLn ("BLOCKED: " ++ show blockedSorted)
  let resolvableSorted = filter (\x -> not (x `elem` blockedSorted)) allSorted
  putStrLn ("RESOLVABLE: " ++ show resolvableSorted)
  transH <- getAllValues (transDepOf "MON-homomorphism")
  putStrLn ("TRANS MON-homomorphism: " ++ show (sort (nub transH)))
  transC <- getAllValues (transDepOf "MON-character-compat")
  putStrLn ("TRANS MON-character-compat: " ++ show (sort (nub transC)))
  printDerivation "MON-character-compat"
  printDerivation "GEO-reconstruction"
  moonT <- getAllValues (moonTransDepOf "GradedDim")
  putStrLn ("MOONCHAIN TRANS GradedDim: " ++ show (sort (nub moonT)))
  bounded <- getAllValues (cycReachTarget 5 "a")
  putStrLn ("BOUNDED CYCLIC: cycTransN 5 from \"a\": " ++ show bounded)
  putStrLn "BOUNDED CYCLIC NOTE: fuel-bounded closure over the cyclic facts a<->b terminated; the unbounded closure over the same facts does not terminate."
