module Main exposing (result)

result = [ 1, 2, 3 ] |> List.map (\x -> x * 2) |> List.filter (\x -> x > 2)
