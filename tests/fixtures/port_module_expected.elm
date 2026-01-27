port module Main exposing (main, setStorage)

port setStorage : String -> Cmd msg


port onStorageChange : (String -> msg) -> Sub msg
