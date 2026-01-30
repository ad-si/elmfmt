module Layouts.PlayLayout exposing (ColorScheme, sepiaColors)

type ColorScheme
  = Light
  | Dark
  | Sepia


{-| Solarized colors <https://ethanschoonover.com/solarized/>
-}
sepiaColors : { fg : Css.Color, bg : Css.Color }
sepiaColors =
  { fg = Css.hex "657b83"
  , bg = Css.hex "fdf6e3"
  }
