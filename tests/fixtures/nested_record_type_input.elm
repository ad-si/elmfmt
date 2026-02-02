module Main exposing (Config)


type alias Config state msg =
  { name : String
  , state : state
  , setter : state -> msg
  , options : List
    { title : String
    , getter : state -> Bool
    , setter : state -> Bool -> state
    }
  , styles : List Style
  }
