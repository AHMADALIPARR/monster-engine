-- Battery (f), print driver: attempt to print the cyclic term itself.
-- main forces the value of cyc (defined by x =:= N x (L 7)) to printed
-- normal form. The raw behaviour (termination, output, or divergence
-- stopped by an external timeout) is recorded in the battery output.
module OccursPrint where

import Control.Search.AllValues ( getAllValues )
import Occurs ( T(..) )

cyc :: T
cyc | x =:= N x (L 7) = x
  where x free

main :: IO ()
main = do
  vals <- getAllValues cyc
  print vals
