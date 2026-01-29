module Main exposing (example)


example =
  let
    x =
      nameDict
      |> Dict.keys
      |> Set.fromList
  in
  x
