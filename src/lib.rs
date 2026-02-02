use anyhow::{anyhow, Result};
use serde::{Deserialize, Serialize};
use topiary_core::{formatter, Language, Operation, TopiaryQuery};

/// The base Elm formatting query file (without if-expression rules)
const ELM_QUERY_BASE: &str = include_str!("../queries/elm.scm");

/// The hanging style if-expression query
const IF_HANGING_QUERY: &str = include_str!("../queries/if_hanging.scm");

/// The indented style if-expression query
const IF_INDENTED_QUERY: &str = include_str!("../queries/if_indented.scm");

/// The spaced tuple style query
const TUPLE_SPACED_QUERY: &str = include_str!("../queries/tuple_spaced.scm");

/// The compact tuple style query
const TUPLE_COMPACT_QUERY: &str = include_str!("../queries/tuple_compact.scm");

/// Default number of spaces for indentation
const DEFAULT_INDENT_SPACES: u8 = 2;

/// Default number of newlines between top-level declarations
const DEFAULT_NEWLINES_BETWEEN_DECLS: u8 = 2;

/// Style for if-then-else expressions
#[derive(Debug, Deserialize, Serialize, Clone, Copy, PartialEq, Eq, Default)]
#[serde(rename_all = "lowercase")]
pub enum IfStyle {
    #[default]
    Indented,
    Hanging,
}

/// Style for tuple expressions
#[derive(Debug, Deserialize, Serialize, Clone, Copy, PartialEq, Eq, Default)]
#[serde(rename_all = "lowercase")]
pub enum TupleStyle {
    Compact,
    #[default]
    Spaced,
}

/// Configuration for the formatter
#[derive(Debug, Deserialize, Serialize, Default, Clone)]
pub struct FormatterConfig {
    pub indentation: u8,
    pub if_style: IfStyle,
    pub tuple_style: TupleStyle,
    pub newlines_between_decls: u8,
}

impl FormatterConfig {
    pub fn new() -> Self {
        Self {
            indentation: DEFAULT_INDENT_SPACES,
            if_style: IfStyle::default(),
            tuple_style: TupleStyle::default(),
            newlines_between_decls: DEFAULT_NEWLINES_BETWEEN_DECLS,
        }
    }
}

impl FormatterConfig {
    /// Get the indentation string based on configuration
    fn indent_string(&self) -> String {
        " ".repeat(self.indentation as usize)
    }

    /// Get the delimiter string for newlines between declarations (escaped for query syntax)
    fn decl_delimiter(&self) -> String {
        "\\n".repeat((self.newlines_between_decls + 1) as usize)
    }
}

fn build_query(config: &FormatterConfig) -> String {
    let if_query = match config.if_style {
        IfStyle::Hanging => IF_HANGING_QUERY,
        IfStyle::Indented => IF_INDENTED_QUERY,
    };
    let tuple_query = match config.tuple_style {
        TupleStyle::Spaced => TUPLE_SPACED_QUERY,
        TupleStyle::Compact => TUPLE_COMPACT_QUERY,
    };
    let base_query = format!("{}\n\n{}\n\n{}", ELM_QUERY_BASE, if_query, tuple_query);

    // Replace the placeholder with the configured delimiter for declaration spacing
    let decl_delimiter = config.decl_delimiter();
    base_query.replace("__DECL_DELIMITER__", &decl_delimiter)
}

/// Format Elm code with the given configuration
pub fn format_elm(content: &str, config: &FormatterConfig) -> Result<String> {
    let grammar = tree_sitter_elm::LANGUAGE;
    let query_str = build_query(config);
    let query = TopiaryQuery::new(&grammar.into(), &query_str)
        .map_err(|e| anyhow!("Failed to parse Elm formatting query: {:?}", e))?;

    let language = Language {
        name: "elm".to_string(),
        query,
        grammar: grammar.into(),
        indent: Some(config.indent_string()),
    };

    let operation = Operation::Format {
        skip_idempotence: false,
        tolerate_parsing_errors: false,
    };

    let mut input = content.as_bytes();
    let mut output = Vec::new();

    formatter(&mut input, &mut output, &language, operation)
        .map_err(|e| anyhow!("Failed to format Elm code: {:?}", e))?;

    String::from_utf8(output).map_err(|e| anyhow!("Formatter produced invalid UTF-8: {}", e))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_simple() {
        let config = FormatterConfig::new();
        let input = "module Main exposing (main)\n\nmain = text \"Hello\"\n";
        let result = format_elm(input, &config);
        assert!(result.is_ok());
    }
}
