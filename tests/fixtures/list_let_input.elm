module Main exposing (test)

test model =
    [ let
          expectedRepos =
              List.length model.repoNames
      in
          expectedRepos
    ]
