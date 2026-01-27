module Main exposing (compute, tuplePattern, nextDeclaration)

compute x =
  let
    y = x + 1
    z = y * 2
  in
  z + 3


tuplePattern =
  let
    (a, b) = ( 1, 2 )
  in
  a + b


nextDeclaration = 42


-- Test case: blank line between let bindings should be preserved
multipleLetBindings =
  let
    first x =
      { value = x + 1
      }

    second y =
      first y
  in
  second 42
