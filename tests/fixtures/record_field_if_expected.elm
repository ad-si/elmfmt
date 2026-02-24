module Main exposing (update)

-- Simple record with if-expression value
update msg model =
  case msg of
    DragMove isDown fraction ->
      ( { model
          | dragState =
              if isDown
                then Moving fraction
                else Static (toFraction model.dragState)
        }
      , Cmd.none
      )
    DragStop fraction ->
      ( { model | dragState = Static fraction }
      , Cmd.none
      )


-- Record literal with if-expression value
config =
  { enabled =
      if isProduction
        then True
        else False
  , name = "test"
  }
