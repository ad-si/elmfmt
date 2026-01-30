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

; When a multi-line tuple or parenthesized expr follows then, add newline and indent
; We detect multi-line using #multi_line_only! which checks if the matched nodes span
; multiple lines in the input
(if_else_expr
  "then"
  (tuple_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

(if_else_expr
  "then"
  (parenthesized_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
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
; This only fires when there's no comment before the let_in_expr.
; We need to handle both first "then" and middle "then"s in else-if chains.
;
; First "then" case: if ... then let ... in ... else
(if_else_expr
  . "if" (_)
  "then"
  .
  (let_in_expr)
  .
  "else" @prepend_indent_end
)

; Middle "then" case: else if ... then let ... in ... else
; This matches when there's an else-if pattern before the then-let
(if_else_expr
  "else"
  "if" (_)
  "then"
  .
  (let_in_expr)
  .
  "else" @prepend_indent_end
)

; Same but with comments between let and else (for first "then")
(if_else_expr
  . "if" (_)
  "then"
  .
  (let_in_expr)
  .
  (line_comment)
  "else" @prepend_indent_end
)

(if_else_expr
  . "if" (_)
  "then"
  .
  (let_in_expr)
  .
  (line_comment)
  (line_comment)
  "else" @prepend_indent_end
)

(if_else_expr
  . "if" (_)
  "then"
  .
  (let_in_expr)
  .
  (line_comment)
  (line_comment)
  (line_comment)
  "else" @prepend_indent_end
)

; Same but with comments between let and else (for middle "then"s)
(if_else_expr
  "else"
  "if" (_)
  "then"
  .
  (let_in_expr)
  .
  (line_comment)
  "else" @prepend_indent_end
)

(if_else_expr
  "else"
  "if" (_)
  "then"
  .
  (let_in_expr)
  .
  (line_comment)
  (line_comment)
  "else" @prepend_indent_end
)

(if_else_expr
  "else"
  "if" (_)
  "then"
  .
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

; Close indents at the very end of the if_else_expr
; With deeply nested format, we accumulate 2 indents per else-if pair.
; Total indents = 1 (first if) + 2 * N (else-if pairs)
; We need separate rules for different chain lengths.

; Simple if-then-else (no else-if): close 1 indent
(if_else_expr
  (_) @append_indent_end
  .
)

; 1 else-if pair: close 2 more (total 3, but basic rule adds 1, so add 2 here)
(if_else_expr
  "else"
  "if"
  (_)
  "then"
  (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 2 else-if pairs: close 4 more (basic + 1-pair rules already fire, so add 2 more)
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 3 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 4 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; Middle "else" (followed by "if"): newline and indent for nested if block
; Only one indent_start here - the nested if-then-else block is indented as a whole
; NOTE: No anchor between else and if - anchors prevent matching multiple occurrences
(if_else_expr
  "else" @append_hardline @append_indent_start
  "if"
)

; Middle "if" (after "else"): space after, start indent for the nested if body (then/else)
; This provides the indentation for then/else to be under the if
; NOTE: No anchor (.) between else and if - tree-sitter should still match consecutive siblings
(if_else_expr
  "else"
  "if" @append_space @append_indent_start
)

; Do NOT close indents before middle "else" - this gives the deeply nested format
; where each else stays at the same level as its paired then, and indents accumulate.

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
