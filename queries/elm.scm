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
; Comments
; ==============================================================================

(line_comment) @append_hardline
(block_comment) @append_hardline

; ==============================================================================
; Module declaration
; ==============================================================================

; module Main exposing (..)
(module_declaration
  (module) @append_space
  (exposing_list) @prepend_space
)

; port module Main exposing (..)
(module_declaration
  (port) @append_space
)

; Add blank line after module declaration
(file
  (module_declaration) @append_delimiter
  (#delimiter! "\n\n")
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
  (import_clause) @append_delimiter
  .
  [
    (value_declaration)
    (type_declaration)
    (type_alias_declaration)
    (type_annotation)
    (port_annotation)
  ]
  (#delimiter! "__DECL_DELIMITER__")
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

; type Msg = ...
(type_declaration
  (type) @append_space
  (upper_case_identifier) @append_space
)

; Indent union variants - use (eq) since = is a named node
; In multiline types, the = goes on a new line before the first variant:
;   type ChartEvent
;     = RenderPerRepoChart Int Int
;     | RenderPerUserChart Int Int
(type_declaration
  (eq) @prepend_spaced_softline @prepend_indent_start @append_space
)

(type_declaration
  "|" @prepend_spaced_softline @append_space
)

; End indent after last union variant
(type_declaration
  (union_variant) @append_indent_end
  .
)

; Union variant with type arguments: RenderPerRepoChart Int Int
; Space after the constructor name when followed by type arguments
(union_variant
  (upper_case_identifier) @append_space
  .
  (_)
)

; Space between consecutive type arguments in union variants
(union_variant
  (_) @append_space
  .
  (_)
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

; Blank line after type declaration when followed by other declarations
(
  (type_declaration) @append_delimiter
  .
  [
    (value_declaration)
    (type_annotation)
    (type_declaration)
    (type_alias_declaration)
    (port_annotation)
  ]
  (#delimiter! "__DECL_DELIMITER__")
)

; Blank line after type alias when followed by other declarations
(
  (type_alias_declaration) @append_delimiter
  .
  [
    (value_declaration)
    (type_annotation)
    (type_declaration)
    (type_alias_declaration)
    (port_annotation)
  ]
  (#delimiter! "__DECL_DELIMITER__")
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
; Space after the type name when followed by arguments
(type_ref
  (upper_case_qid) @append_space
  .
  (_)
)

; Space between type arguments
; This handles: Program Model Msg, Result Error Value, etc.
; Using wildcards without field names to properly match repeated siblings
(type_ref
  (_) @append_space
  .
  (_)
)

; Space after ) when followed by another type argument
(type_ref
  ")" @append_space
  .
  (_)
)

; No extra space inside parentheses in type expressions
(type_ref
  "(" @append_antispace
)
(type_ref
  ")" @prepend_antispace
)

; ==============================================================================
; Value/function declarations
; ==============================================================================

; Blank line between top-level value declarations (not in let expressions)
(file
  (value_declaration) @append_delimiter
  .
  [
    (value_declaration)
    (type_annotation)
    (type_declaration)
    (type_alias_declaration)
    (port_annotation)
    (line_comment)
    (block_comment)
  ]
  (#delimiter! "__DECL_DELIMITER__")
)

; function name arg1 arg2 =
; The function name is a lower_case_identifier, patterns are the arguments
(function_declaration_left
  (lower_case_identifier) @append_space
  .
  (_)
)

; Add spaces between all patterns (arguments) in function declarations
; Use wildcards without field names to properly match repeated siblings
(function_declaration_left
  (_) @append_space
  .
  (_)
)

; Space after the last pattern before the equals sign
(function_declaration_left
  (_) @append_space
  .
)

; Equals sign - (eq) is a named node
(value_declaration
  (eq) @prepend_space @append_spaced_softline @append_indent_start
)

; Close indent for function declarations: f x = body
(value_declaration
  .
  (function_declaration_left)
  (eq)
  (_) @append_indent_end
  .
)

; Close indent for pattern declarations: (a, b) = body
(value_declaration
  .
  (pattern)
  (eq)
  (_) @append_indent_end
  .
)

; ==============================================================================
; Let expressions
; ==============================================================================

; let ... in - these are anonymous nodes
; Open indent after let for the declarations
(let_in_expr
  "let" @append_hardline @append_indent_start
)

; Close indent from let before in, add newlines around in
; Note: elm-format style does NOT indent the body after in
(let_in_expr
  "in" @prepend_indent_end @prepend_hardline @append_hardline
)

; Newlines between let declarations, allowing blank lines to be preserved
; value_declaration -> value_declaration
(let_in_expr
  (value_declaration) @append_hardline
  .
  (value_declaration) @allow_blank_line_before
)

; value_declaration -> type_annotation (new binding group with type sig)
(let_in_expr
  (value_declaration) @append_hardline
  .
  (type_annotation) @allow_blank_line_before
)

; type_annotation -> value_declaration (type sig followed by its implementation)
(let_in_expr
  (type_annotation) @append_hardline
  .
  (value_declaration)
)

; type_annotation -> type_annotation (consecutive type sigs, rare but possible)
(let_in_expr
  (type_annotation) @append_hardline
  .
  (type_annotation) @allow_blank_line_before
)

; Handle "in" after value_declaration
(let_in_expr
  (value_declaration) @append_hardline
  .
  "in"
)

; Handle "in" after type_annotation (orphan type sig, shouldn't happen but handle gracefully)
(let_in_expr
  (type_annotation) @append_hardline
  .
  "in"
)

; Comments in let expressions: ensure proper newlines
; value_declaration -> comment
(let_in_expr
  (value_declaration) @append_hardline
  .
  (line_comment) @allow_blank_line_before
)

(let_in_expr
  (value_declaration) @append_hardline
  .
  (block_comment) @allow_blank_line_before
)

; comment -> value_declaration
(let_in_expr
  (line_comment)
  .
  (value_declaration)
)

(let_in_expr
  (block_comment)
  .
  (value_declaration)
)

; comment -> "in" (comment at end of let bindings, before in)
(let_in_expr
  (line_comment) @append_hardline
  .
  "in"
)

(let_in_expr
  (block_comment) @append_hardline
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

; Spaced softline between consecutive children in function calls (target and args)
; In single-line mode: space between args
; In multi-line mode: each arg on its own line
(function_call_expr
  (_) @append_spaced_softline
  .
  (_)
)

; Indent the arguments when multi-line
; Start indent after the first child (the function being called)
(function_call_expr
  .
  (_) @append_indent_start
  (_)
)

; End indent after the last child
(function_call_expr
  (_) @append_indent_end
  .
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

; Indent pipe chains - add indent before the pipe, end after its operand
(bin_op_expr
  (operator) @prepend_indent_start
  (#match? @prepend_indent_start "^\\|>$")
  .
  (_) @append_indent_end
)

; Cancel pipe indentation when inside a multi-line parenthesized expression
; (parentheses already provide indentation)
(parenthesized_expr
  (bin_op_expr
    (operator) @prepend_indent_end
    (#match? @prepend_indent_end "^\\|>$")
    .
    (_) @append_indent_start
  )
  (#multi_line_only!)
)


; ==============================================================================
; Records
; ==============================================================================

; { field = value }
; elm-format style uses leading commas:
;   { name = "Bob"
;   , age = 25
;   }
(record_expr
  "{" @append_space
  "}" @prepend_spaced_softline
)

; Empty record {} - no spacing inside
(record_expr
  "{" @append_antispace
  .
  "}"
)
(record_expr
  "{"
  .
  "}" @prepend_antispace
)

; Leading comma style: newline before comma, space after
(record_expr
  "," @prepend_empty_softline @append_space
)

; Record update: { baseConfig | field = value }
; Multi-line format:
;   { baseConfig
;       | field1 = value1
;       , field2 = value2
;   }
(record_expr
  (record_base_identifier) @append_spaced_softline @append_indent_start
  "|" @append_space
)

; End indent before } in record updates
(record_expr
  (record_base_identifier)
  "}" @prepend_indent_end
)

; Field assignment - (eq) is a named node
; When the field expression spans multiple lines, indent the continuation
(field
  (eq) @prepend_space @append_space @append_indent_start
  (_) @append_indent_end
  .
)

; Comments inside records: ensure newline before comments that follow fields
(record_expr
  (field)
  .
  (line_comment) @prepend_hardline
)

(record_expr
  (field)
  .
  (block_comment) @prepend_hardline
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

; Lists - elm-format style uses leading commas:
;   [ first
;   , second
;   , third
;   ]
(list_expr
  "[" @append_space
  "]" @prepend_spaced_softline
)

; Empty list [] - no spacing inside
(list_expr
  "[" @append_antispace
  .
  "]"
)
(list_expr
  "["
  .
  "]" @prepend_antispace
)

; Leading comma style: newline before comma, space after
(list_expr
  "," @prepend_empty_softline @append_space
)

; ==============================================================================
; Tuples
; ==============================================================================

; NOTE: Tuple expression formatting is handled by separate query files based on
; the configured tuple-style (spaced or compact). The rules are combined at
; runtime from queries/tuple_spaced.scm or queries/tuple_compact.scm.

; Tuple types always use compact style (no spaces): (Int, String)
(tuple_type
  "(" @append_antispace
  ")" @prepend_antispace
)

(tuple_type
  "," @append_space
)

; Tuple patterns always use compact style (no spaces): (a, b)
(tuple_pattern
  "(" @append_antispace
  ")" @prepend_antispace
)

; ==============================================================================
; Parenthesized expressions
; ==============================================================================

; Multi-line parenthesized expressions: content starts on same line as (
; Closing ) goes on its own line when multi-line
; elm-format style:
;   (Dict.toList repoDict
;     |> List.map ...
;   )
; Define a scope so pipes inside don't add extra indentation
(parenthesized_expr
  "(" @append_indent_start @append_begin_scope
  ")" @prepend_empty_softline @prepend_indent_end @prepend_end_scope
  (#scope_id! "paren")
)

; For single-line parenthesized expressions, no extra space: (foo)
(parenthesized_expr
  ")" @prepend_antispace
  (#single_line_only!)
)

; ==============================================================================
; Patterns
; ==============================================================================

; Union patterns: Just x, Result.Ok value, Http.BadStatus_ metadata _
(union_pattern
  (upper_case_qid) @append_space
  .
  (_)
)

; Add spaces between all pattern arguments in union patterns
; Handles patterns like: Http.BadStatus_ metadata _
(union_pattern
  (_) @append_space
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

; Space around the colon in port annotations
(port_annotation
  (lower_case_identifier) @append_space
  (colon) @append_space
)

; Blank line after port annotation
(
  (port_annotation) @append_delimiter
  .
  [
    (value_declaration)
    (type_annotation)
    (type_declaration)
    (type_alias_declaration)
    (port_annotation)
    (line_comment)
    (block_comment)
  ]
  (#delimiter! "__DECL_DELIMITER__")
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
