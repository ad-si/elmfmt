module Test exposing (..)

viewLeft model =
  [ style
      "pointer-events"
      (if isMoving model
          then "none"
          else "auto"
      )
  , style
      "user-select"
      (if isMoving model
          then "none"
          else "auto"
      )
  ]


rightMost window =
  100
  - toPercentage
    window
    (if Window.isMobile window
        then 25
        else 35
    )


jump window percent =
  if percent <= leftMost window
    then
      (if Window.isMobile window
          then rightMost window
          else halfPoint
      )
    else leftMost window
