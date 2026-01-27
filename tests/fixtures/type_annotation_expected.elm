module Main exposing (add, result, program)
add : Int -> Int -> Int
add a b = a + b
result : Result Error Value
result = Ok value
program : Program (Maybe Base85) Model Msg
program = Browser.application {}
