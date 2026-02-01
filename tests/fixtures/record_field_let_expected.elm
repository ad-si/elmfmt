module Main exposing (mobileNavigation, simpleExample)

-- Simple example: let in record field
simpleExample =
  { value =
      let
        x = 1
      in
      x + 2
  }


-- Complex example: let in nested record field
mobileNavigation =
  stringSelect
    { selected =
        let
          routeWithDefault =
            cfg.currentRoute |> Maybe.withDefault cfg.baseRoute
        in
        menuEntries
          |> List.concat
          |> List.findMap
              (\(title, route) -> if route == routeWithDefault
                  then Just title
                  else Nothing
              )
          |> Maybe.withDefault ""
    , attributes = []
    }
