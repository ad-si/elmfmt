; Compact tuple style
; Single-line tuples and patterns have no spaces inside parentheses: (a, b)
; Multi-line tuples use leading comma style:
;   ( first
;   , second
;   )

; Tuple patterns: (a, b)
(tuple_pattern
  "(" @append_antispace
  ")" @prepend_antispace
)

; Tuple types: (Property, Value)
(tuple_type
  "(" @append_antispace
  ")" @prepend_antispace
)

; Multi-line formatting: space after (, closing ) on its own line
(tuple_expr
  "(" @append_space
  ")" @prepend_spaced_softline
)

; Single-line: no space inside parentheses
(tuple_expr
  "(" @append_antispace
  (#single_line_only!)
)
(tuple_expr
  ")" @prepend_antispace
  (#single_line_only!)
)

; Leading comma style for multi-line: newline before comma, space after
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
