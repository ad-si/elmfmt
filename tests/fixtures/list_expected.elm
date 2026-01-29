module Main exposing (numbers)

numbers = [ 1, 2, 3, 4, 5 ]


headers accessToken =
  [ Http.header
      "Authorization"
      ("token " ++ accessToken)
  ]


colors =
  [ "hsl(176, 100%, 81%)" -- color 0
  , "hsl(346, 100%, 88%)" -- color 1
  , "hsl(79, 100%, 86%)" -- color 2
  ]
