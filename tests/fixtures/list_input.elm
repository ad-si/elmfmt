module Main exposing (numbers)


numbers = [   1   ,   2   ,   3   ,   4   ,   5   ]


headers accessToken =
  [
    Http.header
      "Authorization"
      ("token " ++ accessToken)
  ]
