module Main exposing (toCivil)

toCivil minutes =
  let
    era =
      (if minutes >= 0
          then minutes
          else minutes - 146096
      )
      // 146097
    month =
      mp
      + (if mp < 10
          then 3
          else -9
      )
  in
  { era = era, month = month }
