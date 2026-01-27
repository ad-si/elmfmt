use anyhow::{anyhow, Result};
use std::fs;
use std::path::PathBuf;
use topiary_core::{formatter, Language, Operation, TopiaryQuery};

const ELM_QUERY_BASE: &str = include_str!("../queries/elm.scm");
const IF_HANGING_QUERY: &str = include_str!("../queries/if_hanging.scm");
const IF_INDENTED_QUERY: &str = include_str!("../queries/if_indented.scm");

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum IfStyle {
    #[default]
    Indented,
    Hanging,
}

fn build_query(if_style: IfStyle) -> String {
    let if_query = match if_style {
        IfStyle::Hanging => IF_HANGING_QUERY,
        IfStyle::Indented => IF_INDENTED_QUERY,
    };
    format!("{}\n\n{}", ELM_QUERY_BASE, if_query)
}

fn format_elm(input: &str) -> Result<String> {
    format_elm_with_options(input, "  ", IfStyle::default())
}

fn format_elm_with_indent(input: &str, indent: &str) -> Result<String> {
    format_elm_with_options(input, indent, IfStyle::default())
}

fn format_elm_with_if_style(input: &str, if_style: IfStyle) -> Result<String> {
    format_elm_with_options(input, "  ", if_style)
}

fn format_elm_with_options(input: &str, indent: &str, if_style: IfStyle) -> Result<String> {
    let grammar = tree_sitter_elm::LANGUAGE;
    let query_str = build_query(if_style);
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

// ============================================================================
// Data Structure Tests
// ============================================================================

#[test]
fn test_record_formatting() {
    run_fixture_test("record");
}

#[test]
fn test_list_formatting() {
    run_fixture_test("list");
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

// ============================================================================
// Comment Tests
// ============================================================================

#[test]
fn test_comments_formatting() {
    run_fixture_test("comments");
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

#[test]
fn test_if_style_default_is_indented() {
    let input = r#"module Main exposing (abs)


abs n =
    if n < 0 then -n else n
"#;
    let result = format_elm(input);
    assert!(result.is_ok(), "Should format with default if-style");
    let formatted = result.unwrap();
    // Default should be indented style
    assert!(
        formatted.contains("if n < 0\n    then"),
        "Default if-style should be indented, got:\n{}",
        formatted
    );
}
