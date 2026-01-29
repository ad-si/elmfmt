module ConsPattern exposing (main)


extractFirst list =
    case list of
        x::xs ->
            Just x

        [] ->
            Nothing


extractSubmatch match =
    case match.submatches of
        (Just submatch)::_ ->
            submatch

        _ ->
            ""


nestedCons list =
    case list of
        a::b::c::rest ->
            a + b + c

        _ ->
            0
