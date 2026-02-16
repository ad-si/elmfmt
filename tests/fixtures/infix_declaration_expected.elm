module Basics exposing (..)

import Elm.Kernel.Basics
import Elm.Kernel.Utils


infix right 0 (<|) = apL
infix left 0 (|>) = apR
infix right 2 (||) = or
infix right 3 (&&) = and
infix non 4 (==) = eq


apL : (a -> b) -> a -> b
apL f x =
  f x


apR : a -> (a -> b) -> b
apR x f =
  f x
