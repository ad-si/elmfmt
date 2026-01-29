module Main exposing (handleInput)


handleInput model trimmedInput isValidFormat alreadyExists maxRepos =
    if String.isEmpty trimmedInput
    then ( model, Cmd.none )
    else if not isValidFormat
    then
    ( { model | errorMessage = Just "a" }
    , Cmd.none
    )
    else if alreadyExists
    then ( { model | errorMessage = Just "b" }, Cmd.none )
    else if List.length model.repoNames >= maxRepos
    then ( { model | errorMessage = Just "c" }, Cmd.none )
    else ( { model | errorMessage = Nothing }, Cmd.none )
