module Main exposing (main)


-- Function call with inline block comment between arguments
main =
  isAsciiCode 0x30 {- 0 -} s.offset s.src


-- If condition with function call containing block comment
number c =
  if isAsciiCode 0x30 {- 0 -} s.offset s.src
    then foo
    else bar


-- Binary operator with function calls containing block comments
consumeExp offset src =
  if isAsciiCode 0x65 {- e -} offset src || isAsciiCode 0x45 {- E -} offset src
    then eOffset + 1
    else eOffset


-- Nested if with block comments in function calls
nested c =
  if isAsciiCode 0x30 {- 0 -} s.offset s.src
    then
      if isAsciiCode 0x78 {- x -} zeroOffset s.src
        then foo
        else bar
    else baz
