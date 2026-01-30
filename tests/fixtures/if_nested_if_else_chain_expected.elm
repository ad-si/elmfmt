module Test exposing (test)

test a b =
  if a == 0
    then
      -- comment 1
      if b == 0
        then 0
        else
          -- multi line comment
          -- second line
          let
            x = 1
            y = 2
          in
          ( x
          , y
          )
    else
      if a == 1
        then
          -- comment before let
          --
          -- more comments
          let
            z = 3
            w = 4
          in
          ( z
          , w
          )
        else
          -- final else comment
          0
