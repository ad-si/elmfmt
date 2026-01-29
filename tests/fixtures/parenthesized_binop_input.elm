module Main exposing (allTimestamps)


allTimestamps =
    (List.map (\r -> Time.posixToMillis r.utc) records1
        ++ List.map (\r -> Time.posixToMillis r.utc) records2
    )
