module Main exposing (decodeGithubWeek)


decodeGithubWeek =
    Decode.map3 Week
        (field "week" int
            |> Decode.map secondsToTime
            |> Decode.map DateTime.fromPosix
        )
        (field "total" int)
        (field "days" (list int))
