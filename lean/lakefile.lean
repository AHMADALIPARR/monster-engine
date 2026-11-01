import Lake
open Lake DSL

package monsterBridge where

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.9.0"

@[default_target]
lean_lib MonsterBridge where
