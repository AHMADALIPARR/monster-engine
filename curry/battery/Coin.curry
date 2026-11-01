-- Battery (d): nondeterministic alternatives.
-- coin is defined by two overlapping rules, so it is a nondeterministic
-- operation with two values. pairFlip combines two independent flips,
-- giving 2 x 2 = 4 combinations. The nondeterminism is encapsulated and
-- enumerated with getAllValues from Control.Search.AllValues (PAKCS's
-- library mechanism for collecting every value of a nondeterministic
-- expression); without encapsulation, an evaluation yields one value.
module Coin where

import Control.Search.AllValues ( getAllValues )

data Coin = Heads | Tails
  deriving (Eq, Show)

coin :: Coin
coin = Heads
coin = Tails

pairFlip :: (Coin, Coin)
pairFlip = (coin, coin)

main :: IO ()
main = do
  single <- getAllValues coin
  print single
  pairs <- getAllValues pairFlip
  print pairs
