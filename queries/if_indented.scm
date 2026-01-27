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

; First "if": space after
(if_else_expr
  . "if" @append_space
)

; All "then": new line before, start indent, space after
(if_else_expr
  "then" @prepend_hardline @prepend_indent_start @append_space
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

; Middle "else" (followed by "if"): add newline after and start new indent block
(if_else_expr
  "else" @append_hardline @append_indent_start
  .
  "if"
)

; Middle "if" (after "else"): space after
(if_else_expr
  "else"
  .
  "if" @append_space
)

; Final "else" (not followed by "if"): add space after
; This rule only matches the final else because it's followed by a non-"if" expression
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
    (let_in_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
)
