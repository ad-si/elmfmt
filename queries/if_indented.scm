; If expressions - Indented style
; Format:
;   if condition
;     then expr1
;     else expr2
;
; Or for nested (else-if chain):
;   if condition
;     then expr1
;     else
;       if condition2
;         then expr2
;         else expr3
;
; Note: In tree-sitter-elm, chained else-if is NOT a nested if_else_expr.
; Instead, it's: if_else_expr = "if" expr "then" expr ("else" "if" expr "then" expr)* "else" expr

; All "if": space after
(if_else_expr
  "if" @append_space
)

; First "if": start indent for the condition and branches
(if_else_expr
  . "if" @append_indent_start
)

; All "then": new line before, space after for single-line bodies
(if_else_expr
  "then" @prepend_hardline @append_space
)

; When "then" is followed by a let_in_expr, use newline and indent instead of space
(if_else_expr
  "then" @append_antispace @append_hardline @append_indent_start
  .
  (let_in_expr)
)

; Close indent before else when then body was a let_in_expr
(if_else_expr
  "then"
  .
  (let_in_expr)
  "else" @prepend_indent_end
)

; All "else": new line before
(if_else_expr
  "else" @prepend_hardline
)

; Close indent at the very end of the if_else_expr
(if_else_expr
  (_) @append_indent_end
  .
)

; Middle "else" (followed by "if"): add space after (for the "else if" to stay on same level conceptually)
; then add newline and indent for the nested structure
(if_else_expr
  "else" @append_space @append_indent_start
  .
  "if"
)

; (Middle "if" after "else" gets space from the "All if" rule above)

; Close the extra indent before middle "if" ends (when we have else if chains)
; This balances the indent opened at "else" above
(if_else_expr
  "else"
  .
  "if"
  (_)
  "then"
  (_)
  "else" @prepend_indent_end
)

; Final "else" (not followed by "if"): add space after for simple expressions
; Excludes let_in_expr which needs special handling
(if_else_expr
  "else" @append_space
  .
  [
    (value_expr)
    (number_constant_expr)
    (char_constant_expr)
    (string_constant_expr)
    (function_call_expr)
    (field_access_expr)
    (operator_as_function_expr)
    (negate_expr)
    (bin_op_expr)
    (parenthesized_expr)
    (tuple_expr)
    (list_expr)
    (record_expr)
    (case_of_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
)

; Final "else" followed by let_in_expr: use newline and indent
(if_else_expr
  "else" @append_hardline @append_indent_start
  .
  (let_in_expr) @append_indent_end
)
