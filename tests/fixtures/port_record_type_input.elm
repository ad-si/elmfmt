module Effect exposing (sendToLocalStorage)

port sendToLocalStorage : { key : String
, value : Json.Encode.Value
} -> Cmd msg
