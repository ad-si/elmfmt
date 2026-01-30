module Shared.Model exposing (Model)

import GraphQL
import Types.Song exposing (Song)


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own separate files.
-}
type alias Model =
  { songs : GraphQL.Response (List Song)
  }
