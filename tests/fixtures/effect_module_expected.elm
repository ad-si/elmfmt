effect module Task where { command = MyCmd } exposing
  ( Task
  , succeed
  , fail
  )

import Basics exposing (..)


succeed : a -> Task x a
succeed a =
  a
