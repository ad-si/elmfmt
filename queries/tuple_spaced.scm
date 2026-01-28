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
