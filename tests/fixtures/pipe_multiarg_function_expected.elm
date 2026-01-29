module Main exposing (result)

result =
  record
    |> Debug.toString
    |> Rx.replace
        (Mb.withDefault Rx.never (Rx.fromString " = ([A-Za-z]+)?"))
        submatchReplace
    |> Rx.replace
        (Mb.withDefault Rx.never (Rx.fromString "{ "))
        (\_ -> "{ \"")
