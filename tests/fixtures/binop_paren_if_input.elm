module Main exposing (toV)


toV positive negative =
    (if positive then 1 else 0) - (if negative then 1 else 0)
