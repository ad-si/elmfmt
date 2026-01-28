; Compact tuple style
; Tuples have no spaces inside parentheses: (a, b)

(tuple_expr
  "(" @append_antispace
  ")" @prepend_antispace
)

; Space after comma in tuples
(tuple_expr
  "," @append_space
)
