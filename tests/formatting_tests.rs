use anyhow::{anyhow, Result};
use std::fs;
use std::path::PathBuf;
use topiary_core::{formatter, Language, Operation, TopiaryQuery};

const ELM_QUERY_BASE: &str = include_str!("../queries/elm.scm");
const IF_HANGING_QUERY: &str = include_str!("../queries/if_hanging.scm");
const IF_INDENTED_QUERY: &str = include_str!("../queries/if_indented.scm");
const TUPLE_SPACED_QUERY: &str = include_str!("../queries/tuple_spaced.scm");
const TUPLE_COMPACT_QUERY: &str = include_str!("../queries/tuple_compact.scm");

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IfStyle {
    Indented,
    Hanging,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TupleStyle {
    Compact,
    Spaced,
}

fn build_query(if_style: IfStyle, tuple_style: TupleStyle, newlines_between_decls: u8) -> String {
    let if_query = match if_style {
        IfStyle::Hanging => IF_HANGING_QUERY,
        IfStyle::Indented => IF_INDENTED_QUERY,
    };
    let tuple_query = match tuple_style {
        TupleStyle::Spaced => TUPLE_SPACED_QUERY,
        TupleStyle::Compact => TUPLE_COMPACT_QUERY,
    };
    let base_query = format!("{}\n\n{}\n\n{}", ELM_QUERY_BASE, if_query, tuple_query);

    // Replace the placeholder with the configured delimiter for declaration spacing
    // The config value represents blank lines, so we add 1 for the line-ending newline.
    let decl_delimiter = "\\n".repeat((newlines_between_decls + 1) as usize);
    base_query.replace("__DECL_DELIMITER__", &decl_delimiter)
}

/// Standard test configuration: 2-space indent, indented if-style, compact tuple-style
/// These are explicit values chosen for test stability - they don't track the CLI defaults.
fn format_elm(input: &str) -> Result<String> {
    format_elm_with_options(input, "  ", IfStyle::Indented, TupleStyle::Compact)
}

fn format_elm_with_indent(input: &str, indent: &str) -> Result<String> {
    format_elm_with_options(input, indent, IfStyle::Indented, TupleStyle::Compact)
}

fn format_elm_with_if_style(input: &str, if_style: IfStyle) -> Result<String> {
    format_elm_with_options(input, "  ", if_style, TupleStyle::Compact)
}

fn format_elm_with_tuple_style(input: &str, tuple_style: TupleStyle) -> Result<String> {
    format_elm_with_options(input, "  ", IfStyle::Indented, tuple_style)
}

fn format_elm_with_newlines(input: &str, newlines_between_decls: u8) -> Result<String> {
    format_elm_full(
        input,
        "  ",
        IfStyle::Indented,
        TupleStyle::Compact,
        newlines_between_decls,
    )
}

fn format_elm_with_options(
    input: &str,
    indent: &str,
    if_style: IfStyle,
    tuple_style: TupleStyle,
) -> Result<String> {
    format_elm_full(input, indent, if_style, tuple_style, 2)
}

fn format_elm_full(
    input: &str,
    indent: &str,
    if_style: IfStyle,
    tuple_style: TupleStyle,
    newlines_between_decls: u8,
) -> Result<String> {
    let grammar = tree_sitter_elm::LANGUAGE;
    let query_str = build_query(if_style, tuple_style, newlines_between_decls);
    let query = TopiaryQuery::new(&grammar.into(), &query_str)
        .map_err(|e| anyhow!("Failed to parse Elm formatting query: {:?}", e))?;

    let language = Language {
        name: "elm".to_string(),
        query,
        grammar: grammar.into(),
        indent: Some(indent.to_string()),
    };

    let operation = Operation::Format {
        skip_idempotence: false,
        tolerate_parsing_errors: false,
    };

    let mut input_bytes = input.as_bytes();
    let mut output = Vec::new();

    formatter(&mut input_bytes, &mut output, &language, operation)
        .map_err(|e| anyhow!("Failed to format Elm code: {:?}", e))?;

    String::from_utf8(output).map_err(|e| anyhow!("Invalid UTF-8: {}", e))
}

fn fixtures_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures")
}

fn run_fixture_test(name: &str) {
    let input_path = fixtures_dir().join(format!("{}_input.elm", name));
    let expected_path = fixtures_dir().join(format!("{}_expected.elm", name));

    let input = fs::read_to_string(&input_path)
        .unwrap_or_else(|e| panic!("Failed to read {}: {}", input_path.display(), e));
    let expected = fs::read_to_string(&expected_path)
        .unwrap_or_else(|e| panic!("Failed to read {}: {}", expected_path.display(), e));

    let actual = format_elm(&input).unwrap_or_else(|e| panic!("Formatting failed: {}", e));

    assert_eq!(
        actual, expected,
        "\n\nFormatting mismatch for '{}':\n\n--- Expected ---\n{}\n--- Actual ---\n{}\n",
        name, expected, actual
    );
}

// ============================================================================
// Module and Import Tests
// ============================================================================

#[test]
fn test_module_declaration_formatting() {
    run_fixture_test("module_declaration");
}

#[test]
fn test_port_module_formatting() {
    run_fixture_test("port_module");
}

#[test]
fn test_imports_formatting() {
    run_fixture_test("imports");
}

#[test]
fn test_multiline_imports_formatting() {
    run_fixture_test("multiline_imports");
}

#[test]
fn test_blank_lines_formatting() {
    run_fixture_test("blank_lines");
}

// ============================================================================
// Type Tests
// ============================================================================

#[test]
fn test_type_declaration_formatting() {
    run_fixture_test("type_declaration");
}

#[test]
fn test_type_alias_formatting() {
    run_fixture_test("type_alias");
}

#[test]
fn test_type_annotation_formatting() {
    run_fixture_test("type_annotation");
}

// ============================================================================
// Expression Tests
// ============================================================================

#[test]
fn test_function_declaration_formatting() {
    run_fixture_test("function_declaration");
}

#[test]
fn test_case_expression_formatting() {
    run_fixture_test("case_expression");
}

#[test]
fn test_let_expression_formatting() {
    run_fixture_test("let_expression");
}

#[test]
fn test_anonymous_function_formatting() {
    run_fixture_test("anonymous_function");
}

#[test]
fn test_lambda_let_formatting() {
    run_fixture_test("lambda_let");
}

// ============================================================================
// Data Structure Tests
// ============================================================================

#[test]
fn test_record_formatting() {
    run_fixture_test("record");
}

#[test]
fn test_record_field_multiline_formatting() {
    run_fixture_test("record_field_multiline");
}

#[test]
fn test_record_type_multiline_formatting() {
    run_fixture_test("record_type_multiline");
}

#[test]
fn test_list_formatting() {
    run_fixture_test("list");
}

#[test]
fn test_list_let_formatting() {
    run_fixture_test("list_let");
}

#[test]
fn test_list_backpipe_formatting() {
    run_fixture_test("list_backpipe");
}

#[test]
fn test_tuple_formatting() {
    run_fixture_test("tuple");
}

// ============================================================================
// Operator Tests
// ============================================================================

#[test]
fn test_pipe_operators_formatting() {
    run_fixture_test("pipe_operators");
}

#[test]
fn test_parenthesized_pipe_formatting() {
    run_fixture_test("parenthesized_pipe");
}

#[test]
fn test_parenthesized_binop_formatting() {
    run_fixture_test("parenthesized_binop");
}

#[test]
fn test_pipe_let_binding_formatting() {
    run_fixture_test("pipe_let_binding");
}

#[test]
fn test_pipe_multiarg_function_formatting() {
    run_fixture_test("pipe_multiarg_function");
}

#[test]
fn test_backpipe_multiline_formatting() {
    run_fixture_test("backpipe_multiline");
}

// ============================================================================
// Comment Tests
// ============================================================================

#[test]
fn test_comments_formatting() {
    run_fixture_test("comments");
}

#[test]
fn test_if_comment_formatting() {
    run_fixture_test("if_comment");
}

#[test]
fn test_if_nested_let_formatting() {
    run_fixture_test("if_nested_let");
}

#[test]
fn test_if_else_chain_formatting() {
    run_fixture_test("if_else_chain");
}

// ============================================================================
// Idempotence Tests
// ============================================================================

#[test]
fn test_already_formatted_is_unchanged() {
    run_fixture_test("already_formatted");
}

#[test]
fn test_formatting_is_idempotent() {
    // NOTE: let_expression and if_expression are excluded due to known Topiary query issues
    let test_cases = [
        "module_declaration",
        "imports",
        "type_declaration",
        "function_declaration",
        "case_expression",
        "record",
        "list",
        "pipe_operators",
        "type_annotation",
        "comments",
        "anonymous_function",
        "type_alias",
    ];

    for name in test_cases {
        let expected_path = fixtures_dir().join(format!("{}_expected.elm", name));
        let expected = fs::read_to_string(&expected_path)
            .unwrap_or_else(|e| panic!("Failed to read {}: {}", expected_path.display(), e));

        let reformatted = format_elm(&expected)
            .unwrap_or_else(|e| panic!("Formatting failed for {}: {}", name, e));

        assert_eq!(
            reformatted, expected,
            "Formatting is not idempotent for '{}': formatting the expected output produces different result",
            name
        );
    }
}

// ============================================================================
// Edge Case Tests
// ============================================================================

#[test]
fn test_empty_module() {
    let input = "module Empty exposing (..)";
    let result = format_elm(input);
    assert!(result.is_ok(), "Should handle minimal module");
    let formatted = result.unwrap();
    assert!(formatted.contains("module Empty exposing (..)"));
}

#[test]
fn test_deeply_nested_expressions() {
    let input = r#"module Main exposing (nested)


nested =
    case x of
        Just y ->
            case y of
                Just z ->
                    z

                Nothing ->
                    0

        Nothing ->
            -1
"#;
    let result = format_elm(input);
    assert!(
        result.is_ok(),
        "Should handle deeply nested case expressions"
    );
}

#[test]
fn test_long_function_call() {
    let input = r#"module Main exposing (view)


view model =
    div [ class "container", id "main", style "color" "red" ]
        [ text "Hello"
        , span [] [ text "World" ]
        ]
"#;
    let result = format_elm(input);
    assert!(
        result.is_ok(),
        "Should handle long function calls with multiple arguments"
    );
}

#[test]
fn test_multiline_string() {
    let input = r#"module Main exposing (text)


text =
    """
    This is a
    multiline string
    """
"#;
    let result = format_elm(input);
    assert!(result.is_ok(), "Should handle multiline strings");
}

#[test]
fn test_qualified_names() {
    let input =
        "module Main exposing (main)\n\n\nmain =\n    Html.div [] [ Html.text \"hello\" ]\n";
    let result = format_elm(input);
    assert!(result.is_ok(), "Should handle qualified names");
    let formatted = result.unwrap();
    assert!(formatted.contains("Html.div"));
    assert!(formatted.contains("Html.text"));
}

#[test]
fn test_binary_operators_spacing() {
    let input = "module Main exposing (expr)\n\n\nexpr =\n    1 + 2 * 3 - 4 / 5\n";
    let result = format_elm(input);
    assert!(result.is_ok(), "Should handle binary operators");
    let formatted = result.unwrap();
    assert!(formatted.contains("1 + 2 * 3 - 4 / 5"));
}

#[test]
fn test_record_update_syntax() {
    let input = r#"module Main exposing (update)


update model =
    { model | count = model.count + 1 }
"#;
    let result = format_elm(input);
    assert!(result.is_ok(), "Should handle record update syntax");
}

#[test]
fn test_pattern_matching_in_function_args() {
    let input = r#"module Main exposing (first)


first ( a, b ) =
    a
"#;
    let result = format_elm(input);
    assert!(
        result.is_ok(),
        "Should handle pattern matching in function arguments"
    );
}

#[test]
fn test_function_call_in_if_else_branch() {
    // Issue: Function calls inside if-then-else branches like:
    //   else interpolate "{0}" [ arg1, arg2 ]
    // were being formatted with the list argument at wrong indentation:
    //   else interpolate "{0}"
    //   [ arg1, arg2 ]
    // which breaks the function application
    let input = r#"module Main exposing (url)


url =
    if isDevelopmentMode then
        "/fixtures/repos.json"
    else
        interpolate "{0}/repos/{1}/{2}"
            [ githubApiUrl, accountName, repoName ]
"#;
    let result = format_elm(input);
    assert!(
        result.is_ok(),
        "Should format function call in if-else branch"
    );
    let formatted = result.unwrap();
    // The list argument should be properly indented as a continuation of the function call
    // NOT at the same level as 'else'
    assert!(
        !formatted.contains("else interpolate \"{0}/repos/{1}/{2}\"\n    ["),
        "Function argument should not be at same indent level as 'else', got:\n{}",
        formatted
    );
}

#[test]
fn test_case_pattern_with_multiple_args() {
    // Issue: Case patterns like `Http.BadStatus_ metadata _` were being
    // formatted as `Http.BadStatus_ metadata_` (missing space)
    let input = r#"module Main exposing (handle)


handle response =
    case response of
        Http.BadStatus_ metadata _ ->
            metadata.statusCode

        Http.GoodStatus_ metadata body ->
            body
"#;
    let result = format_elm(input);
    assert!(
        result.is_ok(),
        "Should format case patterns with multiple args"
    );
    let formatted = result.unwrap();
    // Space should be preserved between pattern arguments
    assert!(
        formatted.contains("Http.BadStatus_ metadata _"),
        "Should preserve space between pattern arguments, got:\n{}",
        formatted
    );
    assert!(
        formatted.contains("Http.GoodStatus_ metadata body"),
        "Should preserve space between pattern arguments, got:\n{}",
        formatted
    );
}

#[test]
fn test_let_in_if_then_branch_indented() {
    // let...in inside if...then should be properly indented
    let input = r#"module Main exposing (test)


test =
    if condition then
        let
            x = 1
        in
        x
    else
        0
"#;
    let result = format_elm_with_if_style(input, IfStyle::Indented);
    assert!(result.is_ok(), "Should format let-in inside if-then");
    let formatted = result.unwrap();
    // In indented style, let should be on its own line under then
    assert!(
        formatted.contains("then\n      let"),
        "let should be on its own line under then, got:\n{}",
        formatted
    );
}

#[test]
fn test_multiline_record_update() {
    // Multi-line record updates should have the base on its own line
    let input = r#"module Main exposing (test)


test = { baseConfig
    | privateRepos = True, repoChart = RepoChart 365 100
    }
"#;
    let result = format_elm(input);
    assert!(result.is_ok(), "Should format multiline record update");
    let formatted = result.unwrap();
    // Base identifier on first line, fields indented with leading comma style
    assert!(
        formatted.contains("{ baseConfig\n    | privateRepos = True\n    , repoChart"),
        "Record update should have base on first line with fields indented, got:\n{}",
        formatted
    );
}

#[test]
fn test_lambda_in_parentheses_same_line() {
    // Lambda inside parentheses should start on same line as (
    let input = r#"module Main exposing (test)


test =
    foo
        (
            \x -> doSomething x
        )
"#;
    let result = format_elm(input);
    assert!(result.is_ok(), "Should format lambda in parentheses");
    let formatted = result.unwrap();
    // Lambda should start on same line as opening paren
    assert!(
        formatted.contains("(\\x -> doSomething x"),
        "Lambda should start on same line as opening paren, got:\n{}",
        formatted
    );
}

// ============================================================================
// Error Handling Tests
// ============================================================================

#[test]
fn test_invalid_syntax_fails() {
    let input = "module Main exposing ("; // Invalid - unclosed parenthesis
    let result = format_elm(input);
    assert!(result.is_err(), "Should fail on invalid syntax");
}

// ============================================================================
// Configuration Tests
// ============================================================================

#[test]
fn test_custom_indent_2_spaces() {
    let input = r#"module Main exposing (msg)


type Msg
    = Click
    | Hover
"#;
    let result = format_elm_with_indent(input, "  ");
    assert!(result.is_ok(), "Should format with 2-space indent");
    let formatted = result.unwrap();
    // Type variants are indented under the type declaration, with = on same line as first variant
    assert!(
        formatted.contains("\n  = Click"),
        "Should use 2-space indent for type variants, got:\n{}",
        formatted
    );
}

#[test]
fn test_custom_indent_8_spaces() {
    let input = r#"module Main exposing (msg)


type Msg
    = Click
    | Hover
"#;
    let result = format_elm_with_indent(input, "        ");
    assert!(result.is_ok(), "Should format with 8-space indent");
    let formatted = result.unwrap();
    // Type variants are indented under the type declaration, with = on same line as first variant
    assert!(
        formatted.contains("\n        = Click"),
        "Should use 8-space indent for type variants, got:\n{}",
        formatted
    );
}

#[test]
fn test_default_indent_2_spaces() {
    let input = r#"module Main exposing (msg)


type Msg
    = Click
    | Hover
"#;
    let result = format_elm(input);
    assert!(result.is_ok(), "Should format with default 2-space indent");
    let formatted = result.unwrap();
    // Type variants are indented under the type declaration, with = on same line as first variant
    assert!(
        formatted.contains("\n  = Click"),
        "Should use 2-space indent for type variants, got:\n{}",
        formatted
    );
}

// ============================================================================
// If-Style Configuration Tests
// ============================================================================

#[test]
fn test_if_style_indented_simple() {
    let input = r#"module Main exposing (abs)


abs n =
    if n < 0 then -n else n
"#;
    let result = format_elm_with_if_style(input, IfStyle::Indented);
    assert!(result.is_ok(), "Should format with indented if-style");
    let formatted = result.unwrap();
    // Indented style: "then" and "else" are on their own lines, indented
    assert!(
        formatted.contains("if n < 0\n    then"),
        "Should have 'then' on new line after condition, got:\n{}",
        formatted
    );
    assert!(
        formatted.contains("\n    else"),
        "Should have 'else' on new line, indented, got:\n{}",
        formatted
    );
}

#[test]
fn test_if_style_hanging_simple() {
    let input = r#"module Main exposing (abs)


abs n =
    if n < 0 then -n else n
"#;
    let result = format_elm_with_if_style(input, IfStyle::Hanging);
    assert!(result.is_ok(), "Should format with hanging if-style");
    let formatted = result.unwrap();
    // Hanging style: "then" is on same line as condition
    assert!(
        formatted.contains("if n < 0 then"),
        "Should have 'then' on same line as condition, got:\n{}",
        formatted
    );
}

#[test]
fn test_if_style_indented_nested() {
    let input = r#"module Main exposing (sign)


sign n =
    if n > 0 then 1 else if n < 0 then -1 else 0
"#;
    let result = format_elm_with_if_style(input, IfStyle::Indented);
    assert!(
        result.is_ok(),
        "Should format nested if with indented style"
    );
    let formatted = result.unwrap();
    // Should have the indented style pattern
    assert!(
        formatted.contains("if n > 0\n"),
        "Should have condition followed by newline, got:\n{}",
        formatted
    );
    assert!(
        formatted.contains("then 1"),
        "Should have 'then' with value, got:\n{}",
        formatted
    );
}

#[test]
fn test_if_style_hanging_nested() {
    let input = r#"module Main exposing (sign)


sign n =
    if n > 0 then 1 else if n < 0 then -1 else 0
"#;
    let result = format_elm_with_if_style(input, IfStyle::Hanging);
    assert!(result.is_ok(), "Should format nested if with hanging style");
    let formatted = result.unwrap();
    // Should have hanging style pattern
    assert!(
        formatted.contains("if n > 0 then"),
        "Should have 'then' on same line, got:\n{}",
        formatted
    );
}

// ============================================================================
// Newlines Between Declarations Tests
// ============================================================================

#[test]
fn test_newlines_between_decls_default() {
    let input = r#"module Main exposing (foo, bar)
foo = 1
bar = 2
"#;
    let result = format_elm(input);
    assert!(result.is_ok(), "Should format with default newlines");
    let formatted = result.unwrap();
    // Default is 2 blank lines between declarations
    assert!(
        formatted.contains("foo = 1\n\n\nbar = 2"),
        "Default should have 2 blank lines between declarations, got:\n{}",
        formatted
    );
}

#[test]
fn test_newlines_between_decls_one() {
    let input = r#"module Main exposing (foo, bar)
foo = 1
bar = 2
"#;
    let result = format_elm_with_newlines(input, 1);
    assert!(result.is_ok(), "Should format with 1 blank line");
    let formatted = result.unwrap();
    // 1 blank line between declarations
    assert!(
        formatted.contains("foo = 1\n\nbar = 2"),
        "Should have 1 blank line between declarations, got:\n{}",
        formatted
    );
}

#[test]
fn test_newlines_between_decls_zero() {
    let input = r#"module Main exposing (foo, bar)
foo = 1
bar = 2
"#;
    let result = format_elm_with_newlines(input, 0);
    assert!(result.is_ok(), "Should format with 0 blank lines");
    let formatted = result.unwrap();
    // 0 blank lines means declarations are directly adjacent
    assert!(
        formatted.contains("foo = 1\nbar = 2"),
        "Should have 0 blank lines between declarations, got:\n{}",
        formatted
    );
}

// ============================================================================
// Tuple Style Configuration Tests
// ============================================================================

#[test]
fn test_tuple_style_spaced() {
    let input = r#"module Main exposing (pair)


pair = (1, 2)
"#;
    let result = format_elm_with_tuple_style(input, TupleStyle::Spaced);
    assert!(result.is_ok(), "Should format with spaced tuple style");
    let formatted = result.unwrap();
    assert!(
        formatted.contains("( 1, 2 )"),
        "Spaced style should have spaces inside parentheses, got:\n{}",
        formatted
    );
}

#[test]
fn test_tuple_style_compact() {
    let input = r#"module Main exposing (pair)


pair = ( 1, 2 )
"#;
    let result = format_elm_with_tuple_style(input, TupleStyle::Compact);
    assert!(result.is_ok(), "Should format with compact tuple style");
    let formatted = result.unwrap();
    assert!(
        formatted.contains("(1, 2)"),
        "Compact style should have no spaces inside parentheses, got:\n{}",
        formatted
    );
}

#[test]
fn test_function_call_paren_same_line_as_content() {
    // When a function call has a parenthesized argument with a pipe expression,
    // the opening paren should have the first expression on the same line,
    // not on its own line.
    // WRONG:
    //   Cmd.batch
    //     (
    //       Dict.toList repoDict
    //       |> List.map ...
    //     )
    // RIGHT:
    //   Cmd.batch
    //     (Dict.toList repoDict
    //       |> List.map ...
    //     )
    let input = r#"module Main exposing (loadAuthorDicts)


loadAuthorDicts accessToken repoDict =
    Cmd.batch
        (
            Dict.toList repoDict
                |> List.map (\(repoName, _) -> loadAuthorDictSingle accessToken repoName)
        )
"#;
    let result = format_elm(input);
    assert!(result.is_ok(), "Should format function call with paren");
    let formatted = result.unwrap();
    // The opening paren should have Dict.toList on the same line
    assert!(
        formatted.contains("(Dict.toList repoDict"),
        "Opening paren should have content on same line, got:\n{}",
        formatted
    );
    // Should not have opening paren on its own line
    assert!(
        !formatted.contains("(\n"),
        "Opening paren should not be on its own line, got:\n{}",
        formatted
    );
}

#[test]
fn test_if_then_else_with_comment_body_indentation() {
    // When then/else are on their own lines and followed by a comment,
    // the comment and body should be indented relative to then/else
    // INPUT:
    //   if keyCode == 13
    //     then
    //     -- Enter key pressed, trigger function
    //     update AddRepo model
    //     else model
    // EXPECTED:
    //   if keyCode == 13
    //     then
    //       -- Enter key pressed, trigger function
    //       update AddRepo model
    //     else model
    let input = r#"module Main exposing (handleKey)


handleKey keyCode model =
    if keyCode == 13
      then
      -- Enter key pressed, trigger function
      update AddRepo model
      else model
"#;
    let result = format_elm_with_if_style(input, IfStyle::Indented);
    assert!(result.is_ok(), "Should format if with comment after then");
    let formatted = result.unwrap();
    // The comment and body after "then" should be indented
    assert!(
        formatted.contains("then\n      -- Enter key pressed"),
        "Comment after 'then' should be indented, got:\n{}",
        formatted
    );
    assert!(
        formatted.contains("-- Enter key pressed, trigger function\n      update AddRepo model"),
        "Body after comment should be indented, got:\n{}",
        formatted
    );
}

#[test]
fn test_chained_if_else_with_multiple_comments() {
    // In chained if-else, when then is followed by multiple comments,
    // the comments and body should be indented, and the next else should
    // be at the same level as its paired then (nested style)
    let input = r#"module Main exposing (test)


test error =
    if isRateLimitError error
      then ( model, Cmd.none )
      else if is404Error error
      then -- For 404 errors
      -- Second comment
      -- Third comment
      -- Fourth comment
      ( model, Cmd.none )
      else
      -- Other errors
      ( model, Cmd.none )
"#;
    let result = format_elm_with_if_style(input, IfStyle::Indented);
    assert!(result.is_ok(), "Should format chained if with comments");
    let formatted = result.unwrap();
    // In nested style, the final else is at the same level as its paired then
    // which is indented under "if is404Error"
    assert!(
        formatted.contains(")\n        else\n          -- Other errors"),
        "Final else should be at same level as its then (nested style), got:\n{}",
        formatted
    );
    // Check that comments after final else are indented
    assert!(
        formatted.contains("else\n          -- Other errors\n          (model"),
        "Body after final else with comment should be indented, got:\n{}",
        formatted
    );
}

#[test]
fn test_tuple_pattern_follows_tuple_style() {
    // Tuple patterns (destructuring) should follow the tuple-style setting
    let input = r#"module Main exposing (first)


first ( a, b ) = a
"#;
    let result_spaced = format_elm_with_tuple_style(input, TupleStyle::Spaced);
    let result_compact = format_elm_with_tuple_style(input, TupleStyle::Compact);

    assert!(result_spaced.is_ok() && result_compact.is_ok());
    let formatted_spaced = result_spaced.unwrap();
    let formatted_compact = result_compact.unwrap();

    // Spaced style should have spaces in tuple pattern
    assert!(
        formatted_spaced.contains("first ( a, b )"),
        "Tuple pattern should be spaced with spaced style, got:\n{}",
        formatted_spaced
    );
    // Compact style should have no spaces in tuple pattern
    assert!(
        formatted_compact.contains("first (a, b)"),
        "Tuple pattern should be compact with compact style, got:\n{}",
        formatted_compact
    );
}
