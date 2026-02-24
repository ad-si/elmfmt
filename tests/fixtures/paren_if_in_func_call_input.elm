module Test exposing (..)


withHidden : (Visibility -> msg) -> Bool -> msg
withHidden func isHidden =
  func (if isHidden then Hidden else Visible)
