module Test exposing (..)

test x y =
  if x
    then 1
    -- comment between then-body and else-if
    else
      if y
        then 2
        else 3
