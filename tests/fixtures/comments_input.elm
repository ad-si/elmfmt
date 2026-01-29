module Main exposing (main)
-- This is a line comment
{- This is a block comment -}


main =
    -- inline comment
    text "hello"


-- Comments in lists
listWithComments =
  [ "first"-- after first
  , "second"-- after second
  , "third"-- after third
  ]


-- Comments in records
recordWithComments =
  { name = "Alice"-- name comment
  , age = 30-- age comment
  }


-- Comments in tuples
tupleWithComments =
  ( "a"-- first element
  , "b"-- second element
  )


-- Comments after a record
type alias Person =
    { name : String
    , color : String
    }


-- This is a multi-line comment
-- after a type alias.
-- It should not be moved.
