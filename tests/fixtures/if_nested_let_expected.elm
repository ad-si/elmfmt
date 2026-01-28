module Main exposing (test)

test msg =
  case msg of
    Foo1 ->
      if cond1
        then 1
        else if cond2
        then
          let
            x = 1
          in
          x
        else 2
    Foo2 ->
      0
