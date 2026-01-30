module Main exposing (..)


-- Test: comment followed by let in then branch
test1 =
    if True then
        -- This comment causes the bug
        let
            x = 1
        in
        x

    else
        0


-- Test: comment followed by let in else branch (should work)
test2 =
    if True then
        1

    else
        -- Comment
        let
            x = 2
        in
        x


-- Test: nested - comment then let inside outer let
test3 =
    let
        fn =
            if True then
                -- Comment here
                let
                    y = 1
                in
                y

            else
                0
    in
    fn
