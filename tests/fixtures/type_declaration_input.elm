module Main exposing (Msg, ChartEvent)


type   Msg   =   Increment   |   Decrement   |   Reset


type ChartEvent
    = RenderPerRepoChart Int Int
    | RenderPerUserChart Int Int
    | UpdateWithData String (List Int)


type Codecs valueId valueTasks_state_String valueUpload
    = Codecs (RawCodecs valueId valueTasks_state_String valueUpload)
