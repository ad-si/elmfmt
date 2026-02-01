module Test exposing (test)


test model error =
    if isRateLimitError error
        then
            ( { model | rateLimitError = True }
            , Cmd.none
            )
        else if is401Error error
            then
                ( { model | authError = True }
                , Cmd.none
                )
            else if is404Error error
                then
                    -- Comment before the body in else-if branch
                    -- This causes the indent to not be properly closed
                    ( { model | notFoundError = True }
                    , Cmd.none
                    )
                else
                    ( model
                    , Cmd.none
                    )


isRateLimitError _ = False
is401Error _ = False
is404Error _ = False
