; If expressions - Indented style
; Format:
;   if condition
;     then expr1
;     else expr2
;
; Or for chained else-if:
;   if condition
;     then expr1
;     else if condition2
;       then expr2
;       else expr3
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

; When "then" is followed by a comment, use newline and indent
(if_else_expr
  "then" @append_antispace @append_hardline @append_indent_start
  .
  (line_comment)
)

(if_else_expr
  "then" @append_antispace @append_hardline @append_indent_start
  .
  (block_comment)
)

; Close indent before else when body was preceded by comment(s)
; This handles both first "then" and subsequent "then"s in chained if-else
; Handle 1 comment before body
(if_else_expr
  (line_comment)
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
  .
  "else" @prepend_indent_end
)

; Handle 2 comments before body
(if_else_expr
  (line_comment)
  (line_comment)
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
  .
  "else" @prepend_indent_end
)

; Handle 3 comments before body
(if_else_expr
  (line_comment)
  (line_comment)
  (line_comment)
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
  .
  "else" @prepend_indent_end
)

; Handle 4 comments before body
(if_else_expr
  (line_comment)
  (line_comment)
  (line_comment)
  (line_comment)
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
  .
  "else" @prepend_indent_end
)

; Same patterns with block_comment
(if_else_expr
  (block_comment)
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
  .
  "else" @prepend_indent_end
)

; Close indent from then-let before any else that immediately follows a let_in_expr
(if_else_expr
  (let_in_expr)
  .
  "else" @prepend_indent_end
)

; Same but with comments between let and else
(if_else_expr
  (let_in_expr)
  .
  (line_comment)
  "else" @prepend_indent_end
)

(if_else_expr
  (let_in_expr)
  .
  (line_comment)
  (line_comment)
  "else" @prepend_indent_end
)

(if_else_expr
  (let_in_expr)
  .
  (line_comment)
  (line_comment)
  (line_comment)
  "else" @prepend_indent_end
)

; Comments after then-body: ensure proper newline before the comment
(if_else_expr
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
  .
  (line_comment) @prepend_hardline
)

(if_else_expr
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ]
  .
  (block_comment) @prepend_hardline
)

; Multiple consecutive comments: ensure newlines between them
(if_else_expr
  (line_comment)
  .
  (line_comment) @prepend_hardline
)

(if_else_expr
  (block_comment)
  .
  (line_comment) @prepend_hardline
)

(if_else_expr
  (line_comment)
  .
  (block_comment) @prepend_hardline
)

(if_else_expr
  (block_comment)
  .
  (block_comment) @prepend_hardline
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

; Middle "else" (followed by "if"): add space after for "else if"
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

; Final "else" (not followed by "if"): add space after for simple expressions
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

; Final "else" followed by a comment then let_in_expr
(if_else_expr
  "else" @append_hardline @append_indent_start
  .
  (line_comment)
  (let_in_expr) @append_indent_end
)

(if_else_expr
  "else" @append_hardline @append_indent_start
  .
  (block_comment)
  (let_in_expr) @append_indent_end
)

; Final "else" followed by a comment then other expressions
; Start indent after else, and end it after the body (before the if's indent_end)
(if_else_expr
  "else" @append_hardline @append_indent_start
  .
  (line_comment)
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ] @append_indent_end
)

(if_else_expr
  "else" @append_hardline @append_indent_start
  .
  (block_comment)
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
    (if_else_expr)
    (anonymous_function_expr)
    (glsl_code_expr)
    (unit_expr)
  ] @append_indent_end
)
