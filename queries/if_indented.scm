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

; When a multi-line tuple or parenthesized expr follows then DIRECTLY, add newline and indent
; We detect multi-line using #multi_line_only! which checks if the matched nodes span
; multiple lines in the input.
;
; We need separate patterns for the first "then" (using . "if" anchor) and else-if "then"s.
; The anchor (.) ensures this only matches when then is directly followed by the
; tuple/parenthesized expr, not when there are comments in between.

; First then (after initial "if")
(if_else_expr
  . "if"
  (_)
  "then"
  .
  (tuple_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

(if_else_expr
  . "if"
  (_)
  "then"
  .
  (parenthesized_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

; Else-if then (after "else if") - 1st else-if
(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (tuple_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (parenthesized_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

; 2nd else-if
(if_else_expr
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (tuple_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

(if_else_expr
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (parenthesized_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

; 3rd else-if
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (tuple_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (parenthesized_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

; 4th else-if
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (tuple_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
  (#multi_line_only!)
)

(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
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

; Close indent before else when the corresponding then was followed by a comment.
; We use "then . (comment)" to identify then-branches that opened an indent,
; then match to the else that should close it.
;
; Pattern: then . comment ... body . else
; The "then . comment" part ensures we're matching a then that opened indent.
; The "body . else" part ensures we close before the right else.
; Without anchors between comment and body, this matches any number of comments/bodies
; between the then-comment and body-else.

; Close indent before else when the then branch had a comment.
; This pattern ONLY matches the FIRST then (with `. "if"` anchor).
; Using (line_comment)+ to match one or more comments.
(if_else_expr
  . "if"
  (_)
  "then"
  .
  (line_comment)+
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

; block_comment - first then only
(if_else_expr
  . "if"
  (_)
  "then"
  .
  (block_comment)+
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


; Close indent before else when an else-if's then was followed by comments.
; These patterns match else-if branches where then has comments.
; Using (line_comment)+ to match one or more comments.
;
; NOTE: We need patterns for each else-if position (1st, 2nd, 3rd, 4th) because
; without position-specific prefixes, the pattern could match the wrong "else".
; The prefix "else" "if" (_) "then" (_) skips past earlier else-if branches.
;
; For the 1st else-if, we need to ensure the matched "else" is the final one
; (not followed by "if"). We do this by requiring "else" to be directly followed
; by a body expression OR a comment (which indicates a final else, not else-if).

; 1st else-if with line_comments, final else has direct body
(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (line_comment)+
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
)

; 1st else-if with line_comments, final else has comment before body
(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (line_comment)+
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
  .
  (line_comment)
)

; 1st else-if with line_comments, final else has block_comment before body
(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (line_comment)+
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
  .
  (block_comment)
)

; 1st else-if with block_comments, final else has direct body
(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (block_comment)+
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
)

; 1st else-if with block_comments, final else has comment before body
(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (block_comment)+
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
  .
  (line_comment)
)

(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (block_comment)+
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
  .
  (block_comment)
)

; 2nd else-if with line_comments
(if_else_expr
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (line_comment)+
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

; 2nd else-if with block_comments
(if_else_expr
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (block_comment)+
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

; 3rd else-if with line_comments
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (line_comment)+
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

; 3rd else-if with block_comments
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (block_comment)+
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

; 4th else-if with line_comments
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (line_comment)+
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

; 4th else-if with block_comments
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (block_comment)+
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


; Close indent from then-let before else that immediately follows let_in_expr
; This ONLY applies when "then" is DIRECTLY followed by let_in_expr (no comment).
; When there's a comment before let, the comment pattern (above) handles closing.
;
; We need separate patterns because tree-sitter query matching seems to struggle
; with finding patterns when there are multiple instances of the same token type.

; Simple if-then-let-else (no else-if)
(if_else_expr
  . "if"
  (_)
  "then"
  .
  (let_in_expr)
  .
  "else" @prepend_indent_end
)

; 1 else-if pair where the else-if branch has let
(if_else_expr
  "else"
  "if"
  (_)
  "then"
  .
  (let_in_expr)
  .
  "else" @prepend_indent_end
)

; 2 else-if pairs where the last else-if branch has let
(if_else_expr
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (let_in_expr)
  .
  "else" @prepend_indent_end
)

; 3 else-if pairs where the last else-if branch has let
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (let_in_expr)
  .
  "else" @prepend_indent_end
)

; 4 else-if pairs where the last else-if branch has let
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  "if"
  (_)
  "then"
  .
  (let_in_expr)
  .
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
; NOTE: Tree-sitter queries cannot match arbitrary repetitions, so we must
; enumerate rules for each chain length. Currently supported up to 15 else-if
; pairs (16 total conditions). If you encounter a longer chain, add more rules.

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

; 5 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 6 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 7 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 8 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 9 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 10 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 11 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 12 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 13 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 14 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else"
  (_) @append_indent_end @append_indent_end
  .
)

; 15 else-if pairs: close 2 more
(if_else_expr
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
  "else" "if" (_) "then" (_)
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

; Final else followed by tuple - add indent handling
; The @prepend_empty_softline expands to newline only if parent tuple_expr is multi-line
; For single-line tuples, this adds nothing; for multi-line, it adds newline+indent
; Use @allow_blank_line_before on else to make the pattern match (quirk of Topiary)
(if_else_expr
  "else" @allow_blank_line_before
  .
  (tuple_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
)

(if_else_expr
  "else" @allow_blank_line_before
  .
  (parenthesized_expr
    "(" @prepend_empty_softline @prepend_indent_start
    ")" @append_indent_end
  )
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
; Start indent after else, end it after the body
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


