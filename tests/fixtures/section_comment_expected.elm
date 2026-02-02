module Main exposing (main)

import Tailwind.Theme exposing (..)
import Tailwind.Utilities exposing (..)


-- MAIN


main : Program () Model Msg
main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }
