module Main exposing (combineDicts)


combineDicts dict1 dict2 allTimestamps =
    allTimestamps
        |> List.map
            (\timestamp -> let
                value1 =
                    Dict.get timestamp dict1
                        |> Maybe.map .value
                        |> Maybe.withDefault 0

                value2 =
                    Dict.get timestamp dict2
                        |> Maybe.map .value
                        |> Maybe.withDefault 0
            in
            TimeRecord (millisToPosix timestamp) (value1 + value2) 0
            )
