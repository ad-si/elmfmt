module Test exposing (..)

filter : (a -> Bool) -> Array a -> Array a
filter isGood array =
  fromList
    (foldr
        (\x xs ->
            if isGood x
              then x :: xs
              else xs
        )
        []
        array
    )
