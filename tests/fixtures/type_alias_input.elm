module Main exposing (Model)


type   alias   Model   =   {   count   :   Int   ,   name   :   String   }


type alias RawCodecs valueId valueTasks_state_String valueUpload =
    {codecId : Codec valueId
 , codecTasks_state_String : Codec valueTasks_state_String
 , codecUpload : Codec valueUpload}
