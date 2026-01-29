; Spaced tuple style (elm-format compatible)
; Tuples have spaces inside parentheses: ( a, b )
; Multi-line uses leading comma style:
;   ( first
;   , second
;   )

(tuple_expr
  "(" @append_space
  ")" @prepend_spaced_softline
)

; Leading comma style: newline before comma, space after
(tuple_expr
  "," @prepend_empty_softline @append_space
)

; Indent the first tuple element (start after opening paren)
(tuple_expr
  "(" @append_indent_start
  .
  (_) @append_indent_end
)

; Indent subsequent tuple elements (after comma)
(tuple_expr
  "," @append_indent_start
  .
  (_) @append_indent_end
)
