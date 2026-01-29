module Main exposing (main)

import Json.Decode as Decode
  exposing
    ( Decoder
    , andThen
    , bool
    , fail
    , field
    , int
    , list
    , string
    , succeed
    )
import Html exposing (Html, div, text)


main =
  text "hello"
