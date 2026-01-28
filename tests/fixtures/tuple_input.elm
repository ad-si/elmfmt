module Main exposing (multiTuple)


multiTuple =
  (
    newModel, Cmd.batch
      [ setStorage base85Model
        , cmd
      ]
  )
