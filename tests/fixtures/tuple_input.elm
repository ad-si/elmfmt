module Main exposing (multiTuple, tupleWithRecordUpdate)


multiTuple =
  (
    newModel, Cmd.batch
      [ setStorage base85Model
        , cmd
      ]
  )


tupleWithRecordUpdate =
    ({ model
      | repoChart = RepoChart numberOfDays
    }, Cmd.none)
