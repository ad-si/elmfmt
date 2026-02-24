module Main exposing (floorMonth, floorYear)

floorMonth zone mult stamp =
  let
    parts = posixToParts zone (floor Month zone stamp)
    monthInt = monthAsInt parts.month
    rem = remainderBy mult (monthInt - 1)
    newMonth =
      if rem == 0
        then monthInt
        else monthInt - rem
  in
  partsToPosix zone { parts | month = intAsMonth newMonth }


floorYear zone mult stamp =
  let
    parts = posixToParts zone (ceiling Year zone stamp)
    rem = remainderBy mult parts.year
    newYear =
      if rem == 0
        then parts.year
        else parts.year - rem
  in
  partsToPosix zone { parts | year = newYear }
