-- Battery (c): recursive Horn clauses.
-- parent/2 is a set of ground facts. ancestor/2 has a base clause and a
-- recursive clause: ancestor(x,z) holds when parent(x,y) and
-- ancestor(y,z) for some intermediate y (a free logic variable).
-- The query enumerates every descendant of "abe" in the family graph,
-- which requires genuine recursion through the clause.
module Family where

import Control.Search.AllValues ( getAllValues )

parent :: String -> String -> Bool
parent "abe" "bob" = True
parent "bob" "cy"  = True
parent "cy"  "dee" = True
parent "abe" "ada" = True
parent "ada" "eli" = True

ancestor :: String -> String -> Bool
ancestor x y | parent x y = True
ancestor x z | parent x y && ancestor y z = True
  where y free

descendantOf :: String -> String
descendantOf a | ancestor a y = y
  where y free

main :: IO ()
main = do
  ds <- getAllValues (descendantOf "abe")
  print ds
