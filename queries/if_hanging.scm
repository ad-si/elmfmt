; If expressions - Hanging style
; Format:
;   if condition then
;       expr1
;   else
;       expr2
;
; Or for chained else-if:
;   if condition then
;       expr1
;   else if condition2 then
;       expr2
;   else
;       expr3
;
; Note: In tree-sitter-elm, chained else-if is NOT a nested if_else_expr.
; Instead, it's: if_else_expr = "if" expr "then" expr ("else" "if" expr "then" expr)* "else" expr

; First "if": add space after
(if_else_expr
  . "if" @append_space
)

; All "then": space before, spaced softline after, start indent
(if_else_expr
  "then" @prepend_space @append_spaced_softline @append_indent_start
)

; All "else": end indent before, spaced softline before
(if_else_expr
  "else" @prepend_indent_end @prepend_spaced_softline
)

; Close indent at the very end of the if_else_expr
(if_else_expr
  (_) @append_indent_end
  .
)

; Middle "else" (followed by "if"): space after for "else if" on same line
(if_else_expr
  "else" @append_space
  .
  "if"
)

; Middle "if" (after "else"): space after
(if_else_expr
  "else"
  .
  "if" @append_space
)

; Final "else" (not followed by "if"): spaced softline after and start indent
(if_else_expr
  "else" @append_spaced_softline @append_indent_start
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
