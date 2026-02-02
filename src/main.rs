use anyhow::{anyhow, Context, Result};
use clap::Parser;
use serde::Deserialize;
use std::fs;
use std::io::{self, Read, Write};
use std::path::{Path, PathBuf};
use topiary_core::{formatter, Language, Operation, TopiaryQuery};
use walkdir::WalkDir;

/// Configuration file name
const CONFIG_FILE_NAME: &str = "elmfmt.yaml";

/// Default number of spaces for indentation
const DEFAULT_INDENT_SPACES: u8 = 2;

/// Style for if-then-else expressions
#[derive(Debug, Deserialize, Clone, Copy, PartialEq, Eq, Default)]
#[serde(rename_all = "lowercase")]
pub enum IfStyle {
    /// Indented style (default):
    /// ```elm
    /// if condition
    ///   then expr1
    ///   else expr2
    /// ```
    #[default]
    Indented,
    /// Hanging style:
    /// ```elm
    /// if condition then
    ///     expr1
    /// else
    ///     expr2
    /// ```
    Hanging,
}

/// Style for tuple expressions
#[derive(Debug, Deserialize, Clone, Copy, PartialEq, Eq, Default)]
#[serde(rename_all = "lowercase")]
pub enum TupleStyle {
    /// Compact style (no spaces inside parentheses):
    /// ```elm
    /// (a, b)
    /// ```
    Compact,
    /// Spaced style (default, elm-format compatible):
    /// ```elm
    /// ( a, b )
    /// ```
    #[default]
    Spaced,
}

/// Default number of newlines between top-level declarations
const DEFAULT_NEWLINES_BETWEEN_DECLS: u8 = 2;

/// Configuration for elmfmt
#[derive(Debug, Deserialize, Default)]
#[serde(default)]
struct Config {
    /// Number of spaces to use for indentation
    indentation: Option<u8>,
    /// Style for if-then-else expressions
    #[serde(rename = "if-style")]
    if_style: IfStyle,
    /// Style for tuple expressions
    #[serde(rename = "tuple-style")]
    tuple_style: TupleStyle,
    /// Number of newlines between top-level declarations (default: 2)
    #[serde(rename = "newlines-between-decls")]
    newlines_between_decls: Option<u8>,
}

impl Config {
    /// Load configuration from elmfmt.yaml, searching from the given directory upward
    fn load(start_dir: Option<&Path>) -> Result<Self> {
        let start = start_dir
            .map(|p| p.to_path_buf())
            .or_else(|| std::env::current_dir().ok())
            .unwrap_or_else(|| PathBuf::from("."));

        // Search for config file from start directory up to root
        let mut current = start.as_path();
        loop {
            let config_path = current.join(CONFIG_FILE_NAME);
            if config_path.exists() {
                let content = fs::read_to_string(&config_path).with_context(|| {
                    format!("Failed to read config file: {}", config_path.display())
                })?;
                let config: Config = serde_yaml::from_str(&content).with_context(|| {
                    format!("Failed to parse config file: {}", config_path.display())
                })?;
                return Ok(config);
            }

            match current.parent() {
                Some(parent) => current = parent,
                None => break,
            }
        }

        // No config file found, use defaults
        Ok(Config::default())
    }

    /// Get the indentation string based on configuration
    fn indent_string(&self) -> String {
        let spaces = self.indentation.unwrap_or(DEFAULT_INDENT_SPACES);
        " ".repeat(spaces as usize)
    }

    /// Get the delimiter string for newlines between declarations (escaped for query syntax)
    /// The config value represents blank lines, so we add 1 for the line-ending newline.
    fn decl_delimiter(&self) -> String {
        let blank_lines = self
            .newlines_between_decls
            .unwrap_or(DEFAULT_NEWLINES_BETWEEN_DECLS);
        "\\n".repeat((blank_lines + 1) as usize)
    }

    /// Get the delimiter string for section comments (one less newline than decl_delimiter,
    /// since line_comment already has @append_hardline adding one newline)
    fn section_comment_delimiter(&self) -> String {
        let blank_lines = self
            .newlines_between_decls
            .unwrap_or(DEFAULT_NEWLINES_BETWEEN_DECLS);
        "\\n".repeat(blank_lines as usize)
    }
}

/// A formatter for Elm code, powered by Topiary
#[derive(Parser, Debug)]
#[command(name = "elmfmt")]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Input files or directories to format. If not provided, reads from stdin
    #[arg(value_name = "FILE")]
    input: Vec<PathBuf>,

    /// Write output to file instead of stdout (only valid with a single input file)
    #[arg(short, long, value_name = "FILE")]
    output: Option<PathBuf>,

    /// Modify the file in place
    #[arg(short, long)]
    in_place: bool,

    /// Check if the file is already formatted (exit with 1 if not)
    #[arg(short, long)]
    check: bool,

    /// Skip idempotence check
    #[arg(long)]
    skip_idempotence: bool,

    /// Read from stdin (for compatibility with elm-format)
    #[arg(long)]
    stdin: bool,

    /// Elm version (ignored, for compatibility with elm-format)
    #[arg(long, value_name = "VERSION")]
    elm_version: Option<String>,

    /// Auto-confirm (ignored, for compatibility with elm-format)
    #[arg(long)]
    yes: bool,
}

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

fn build_query(config: &Config) -> String {
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
    let section_comment_delimiter = config.section_comment_delimiter();
    base_query
        .replace("__DECL_DELIMITER__", &decl_delimiter)
        .replace("__SECTION_COMMENT_DELIMITER__", &section_comment_delimiter)
}

/// Find all .elm files in a directory recursively
fn find_elm_files(dir: &Path) -> Result<Vec<PathBuf>> {
    let mut files = Vec::new();
    for entry in WalkDir::new(dir).follow_links(true) {
        let entry =
            entry.with_context(|| format!("Failed to read directory: {}", dir.display()))?;
        let path = entry.path();
        if path.is_file() && path.extension().is_some_and(|ext| ext == "elm") {
            files.push(path.to_path_buf());
        }
    }
    files.sort();
    Ok(files)
}

/// Format a single file's content and return the formatted string
fn format_content(content: &str, language: &Language, skip_idempotence: bool) -> Result<String> {
    let operation = Operation::Format {
        skip_idempotence,
        tolerate_parsing_errors: false,
    };

    let mut input = content.as_bytes();
    let mut output = Vec::new();

    formatter(&mut input, &mut output, language, operation)
        .map_err(|e| anyhow!("Failed to format Elm code: {:?}", e))?;

    String::from_utf8(output).context("Formatter produced invalid UTF-8")
}

fn main() -> Result<()> {
    let args = Args::parse();

    // Determine if we're in multi-file mode (multiple inputs or any directories)
    let has_multiple_inputs = args.input.len() > 1;
    let has_directory = !args.stdin && args.input.iter().any(|p| p.is_dir());
    let multi_file_mode = !args.stdin && (has_multiple_inputs || has_directory);

    if multi_file_mode {
        // Multi-file mode: format all specified files and directories
        if args.output.is_some() {
            anyhow::bail!("Cannot use --output with multiple inputs or directories");
        }
        if !args.in_place && !args.check {
            anyhow::bail!(
                "When formatting multiple files or directories, you must use --in-place or --check"
            );
        }

        // Collect all files from all inputs
        let mut files = Vec::new();
        for input in &args.input {
            if input.is_dir() {
                files.extend(find_elm_files(input)?);
            } else if input.is_file() {
                files.push(input.clone());
            } else {
                anyhow::bail!("Input path does not exist: {}", input.display());
            }
        }

        if files.is_empty() {
            eprintln!("No .elm files found");
            return Ok(());
        }

        // Remove duplicates and sort
        files.sort();
        files.dedup();

        let mut needs_formatting = false;

        for file in &files {
            // Load configuration for each file (may differ by directory)
            let config = Config::load(file.parent())?;

            // Set up the language configuration
            let grammar = tree_sitter_elm::LANGUAGE;
            let query_str = build_query(&config);
            let query = TopiaryQuery::new(&grammar.into(), &query_str)
                .map_err(|e| anyhow!("Failed to parse Elm formatting query: {:?}", e))?;
            let language = Language {
                name: "elm".to_string(),
                query,
                grammar: grammar.into(),
                indent: Some(config.indent_string()),
            };

            let content = fs::read_to_string(file)
                .with_context(|| format!("Failed to read file: {}", file.display()))?;

            let formatted = format_content(&content, &language, args.skip_idempotence)
                .with_context(|| format!("Failed to format: {}", file.display()))?;

            if args.check {
                if formatted != content {
                    eprintln!("Would reformat: {}", file.display());
                    needs_formatting = true;
                }
            } else if args.in_place && formatted != content {
                fs::write(file, &formatted)
                    .with_context(|| format!("Failed to write file: {}", file.display()))?;
                eprintln!("Formatted: {}", file.display());
            }
        }

        if args.check && needs_formatting {
            std::process::exit(1);
        }
    } else {
        // Single file or stdin mode
        let single_input = args.input.first();
        let config_search_dir = single_input.and_then(|p| p.parent());
        let config = Config::load(config_search_dir)?;

        // Read input (--stdin flag takes precedence over input file)
        let input_content = if args.stdin {
            let mut buffer = String::new();
            io::stdin()
                .read_to_string(&mut buffer)
                .context("Failed to read from stdin")?;
            buffer
        } else if let Some(ref path) = single_input {
            fs::read_to_string(path)
                .with_context(|| format!("Failed to read file: {}", path.display()))?
        } else {
            let mut buffer = String::new();
            io::stdin()
                .read_to_string(&mut buffer)
                .context("Failed to read from stdin")?;
            buffer
        };

        // Set up the language configuration
        let grammar = tree_sitter_elm::LANGUAGE;
        let query_str = build_query(&config);
        let query = TopiaryQuery::new(&grammar.into(), &query_str)
            .map_err(|e| anyhow!("Failed to parse Elm formatting query: {:?}", e))?;
        let language = Language {
            name: "elm".to_string(),
            query,
            grammar: grammar.into(),
            indent: Some(config.indent_string()),
        };

        let formatted = format_content(&input_content, &language, args.skip_idempotence)?;

        // Handle check mode
        if args.check {
            if formatted != input_content {
                eprintln!("File would be reformatted");
                std::process::exit(1);
            }
            return Ok(());
        }

        // Write output
        if args.in_place {
            if let Some(ref path) = single_input {
                fs::write(path, &formatted)
                    .with_context(|| format!("Failed to write file: {}", path.display()))?;
            } else {
                anyhow::bail!("Cannot use --in-place without an input file");
            }
        } else if let Some(ref path) = args.output {
            fs::write(path, &formatted)
                .with_context(|| format!("Failed to write file: {}", path.display()))?;
        } else {
            io::stdout()
                .write_all(formatted.as_bytes())
                .context("Failed to write to stdout")?;
        }
    }

    Ok(())
}
