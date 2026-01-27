; Elm formatting queries for Topiary
; Based on standard Elm formatting conventions (elm-format style)

; ==============================================================================
; Leaf nodes - don't format inside these
; ==============================================================================

[
  (line_comment)
  (block_comment)
  (string_constant_expr)
  (char_constant_expr)
  (glsl_code_expr)
] @leaf

; ==============================================================================
; Comments - preserve blank lines before comments
; ==============================================================================

[
  (line_comment)
  (block_comment)
] @allow_blank_line_before

(line_comment) @prepend_input_softline @append_hardline
(block_comment) @prepend_input_softline @append_hardline

; ==============================================================================
; Module declaration
; ==============================================================================

; module Main exposing (..)
(module_declaration
  (module) @append_space
  (exposing_list) @prepend_space
)

; Add newlines after module declaration
(file
  (module_declaration) @append_hardline @append_hardline
)

; ==============================================================================
; Imports
; ==============================================================================

; import Html exposing (div, text)
(import_clause
  (import) @append_space
)

(import_clause
  (exposing_list) @prepend_space
)

(import_clause
  (as_clause) @prepend_space
)

(as_clause
  (as) @append_space
)

; Newlines between imports
(
  (import_clause) @append_hardline
  .
  (import_clause)
)

; Blank line after all imports before declarations
(
  (import_clause) @append_hardline
  .
  [
    (value_declaration)
    (type_declaration)
    (type_alias_declaration)
    (type_annotation)
    (port_annotation)
  ]
)

; ==============================================================================
; Exposing lists
; ==============================================================================

(exposing_list
  (exposing) @append_space
  "(" @append_antispace
)

(exposing_list
  ")" @prepend_antispace
)

; Commas in exposing lists - add space after
(exposing_list
  "," @append_space
)

; ==============================================================================
; Type declarations
; ==============================================================================

; Allow blank lines before type declarations
[
  (type_declaration)
  (type_alias_declaration)
] @allow_blank_line_before

; type Msg = ...
(type_declaration
  (type) @append_space
  (upper_case_identifier) @append_space
)

; Indent union variants - use (eq) since = is a named node
(type_declaration
  (eq) @append_spaced_softline @append_indent_start
)

(type_declaration
  "|" @prepend_spaced_softline @append_space
)

; End indent after last union variant
(type_declaration
  (union_variant) @append_indent_end
  .
)

; Type alias
(type_alias_declaration
  (type) @append_space
  (alias) @append_space
)

(type_alias_declaration
  (upper_case_identifier) @append_space
)

(type_alias_declaration
  (eq) @prepend_space @append_spaced_softline @append_indent_start
)

(type_alias_declaration
  (type_expression) @append_indent_end
  .
)

; ==============================================================================
; Type annotations
; ==============================================================================

(type_annotation
  (colon) @prepend_space @append_spaced_softline @append_indent_start
)

(type_annotation
  (type_expression) @append_indent_end
  .
)

; Blank line after type annotation
(
  (type_annotation) @append_hardline
  .
  (value_declaration)
)

; ==============================================================================
; Type expressions (function types, etc.)
; ==============================================================================

; Arrow in type expressions: a -> b
(type_expression
  (arrow) @prepend_space @append_space
)

; Type application: List Int
(type_ref
  (_) @append_space
  .
  (_)
)

; ==============================================================================
; Value/function declarations
; ==============================================================================

; Allow blank lines between declarations
(value_declaration) @allow_blank_line_before

; Blank line between value declarations
(
  (value_declaration) @append_hardline
  .
  [
    (value_declaration)
    (type_annotation)
    (type_declaration)
    (type_alias_declaration)
  ]
)

; function name arg1 arg2 =
; The function name is a lower_case_identifier, patterns are the arguments
(function_declaration_left
  (lower_case_identifier) @append_space
  .
  (_)
)

; Add spaces between all patterns (arguments) in function declarations
(function_declaration_left
  pattern: (_) @append_space
  .
  pattern: (_)
)

; Space after the last pattern before the equals sign
(function_declaration_left
  pattern: (_) @append_space
  .
)

; Equals sign - (eq) is a named node
(value_declaration
  (eq) @prepend_space @append_spaced_softline @append_indent_start
)

(value_declaration
  .
  (function_declaration_left)
  (eq)
  (_) @append_indent_end
  .
)

; ==============================================================================
; Let expressions
; ==============================================================================

; let ... in - these are anonymous nodes
(let_in_expr
  "let" @append_hardline @append_indent_start
)

(let_in_expr
  "in" @prepend_indent_end @prepend_hardline @append_hardline @append_indent_start
)

(let_in_expr
  .
  "let"
  (_)
  "in"
  (_) @append_indent_end
  .
)

; Newlines between let declarations
(let_in_expr
  (value_declaration) @append_hardline
  .
  (value_declaration)
)

(let_in_expr
  (value_declaration) @append_hardline
  .
  "in"
)

; ==============================================================================
; Case expressions
; ==============================================================================

; case expr of - (case) and (of) are named nodes
(case_of_expr
  (case) @append_space
  (of) @prepend_space @append_hardline @append_indent_start
)

(case_of_expr
  (case_of_branch) @append_indent_end
  .
)

; Case branches
(case_of_branch
  (pattern) @append_space
  (arrow) @append_spaced_softline @append_indent_start
)

(case_of_branch
  (_) @append_indent_end
  .
)

; Newlines between case branches
(case_of_expr
  (case_of_branch) @append_hardline @append_hardline
  .
  (case_of_branch)
)

; ==============================================================================
; If expressions
; ==============================================================================

; NOTE: If expression formatting is handled by separate query files based on
; the configured if-style (hanging or indented). The rules are combined at
; runtime from queries/if_hanging.scm or queries/if_indented.scm.

; ==============================================================================
; Anonymous functions (lambdas)
; ==============================================================================

; \x -> expr
(anonymous_function_expr
  (backslash) @append_antispace
  (pattern) @append_space
  (arrow) @append_space
)

; ==============================================================================
; Function calls
; ==============================================================================

; func arg1 arg2
(function_call_expr
  target: (_) @append_space
)

(function_call_expr
  arg: (_) @append_spaced_softline
  .
  arg: (_)
)

; ==============================================================================
; Binary operators
; ==============================================================================

; a + b, a |> b, etc.
(bin_op_expr
  (operator) @prepend_space @append_space
)

; Pipe operators on new lines in multiline context
(bin_op_expr
  (operator) @prepend_spaced_softline
  (#match? @prepend_spaced_softline "^\\|>$")
)

; ==============================================================================
; Records
; ==============================================================================

; { field = value }
(record_expr
  "{" @append_spaced_softline @append_indent_start
  "}" @prepend_spaced_softline @prepend_indent_end
)

(record_expr
  "," @append_space
)

; Record update: { model | field = value }
(record_expr
  (record_base_identifier) @append_space
  "|" @append_spaced_softline
)

; Field assignment - (eq) is a named node
(field
  (eq) @prepend_space @append_space
)

; Record types
(record_type
  "{" @append_spaced_softline @append_indent_start
  "}" @prepend_spaced_softline @prepend_indent_end
)

(record_type
  "," @append_spaced_softline
)

(field_type
  (colon) @prepend_space @append_space
)

; ==============================================================================
; Lists
; ==============================================================================

; Lists - softlines for proper multiline handling
(list_expr
  "[" @append_spaced_softline @append_indent_start
  "]" @prepend_spaced_softline @prepend_indent_end
)

; Commas in lists
(list_expr
  "," @append_spaced_softline
)

; ==============================================================================
; Tuples
; ==============================================================================

(tuple_expr
  "(" @append_spaced_softline @append_indent_start
  ")" @prepend_spaced_softline @prepend_indent_end
)

(tuple_expr
  "," @append_space
)

(tuple_type
  "(" @append_antispace
  ")" @prepend_antispace
)

(tuple_type
  "," @append_space
)

; ==============================================================================
; Parenthesized expressions
; ==============================================================================

(parenthesized_expr
  "(" @append_antispace
  ")" @prepend_antispace
)

; ==============================================================================
; Patterns
; ==============================================================================

; Union patterns: Just x
(union_pattern
  (upper_case_qid) @append_space
  .
  (_)
)

; Tuple patterns
(tuple_pattern
  "," @append_space
)

; Record patterns
(record_pattern
  "," @append_space
)

; List patterns
(list_pattern
  "," @append_space
)

; ==============================================================================
; Port declarations
; ==============================================================================

(port_annotation
  (port) @append_space
)

; ==============================================================================
; Infix declarations
; ==============================================================================

(infix_declaration
  (infix) @append_space
)

; ==============================================================================
; General punctuation
; ==============================================================================

; Remove extra spaces before commas
"," @prepend_antispace

; Dot accessor: .field
(field_accessor_function_expr
  (dot) @append_antispace
)

; Field access: record.field
(field_access_expr
  (dot) @prepend_antispace @append_antispace
)

; Qualified names: Module.function
(upper_case_qid
  (dot) @prepend_antispace @append_antispace
)

(value_qid
  (dot) @prepend_antispace @append_antispace
)
