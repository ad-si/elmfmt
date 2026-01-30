module Test exposing (test)

test str =
  if str == "a"
    then 0
    else
      if str == "b"
        then 1
        else
          if str == "c"
            then
              let
                y = 1
              in
              2
            else 3
