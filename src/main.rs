use anyhow::{anyhow, Context, Result};
use clap::Parser;
use std::fs;
use std::io::{self, Read, Write};
use std::path::PathBuf;
use topiary_core::{formatter, Language, Operation, TopiaryQuery};

/// A formatter for Elm code, powered by Topiary
#[derive(Parser, Debug)]
#[command(name = "elmfmt")]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Input file to format. If not provided, reads from stdin
    #[arg(value_name = "FILE")]
    input: Option<PathBuf>,

    /// Write output to file instead of stdout
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
}

/// The Elm formatting query file
const ELM_QUERY: &str = include_str!("../queries/elm.scm");

fn main() -> Result<()> {
    let args = Args::parse();

    // Read input
    let input_content = if let Some(ref path) = args.input {
        fs::read_to_string(path)
            .with_context(|| format!("Failed to read file: {}", path.display()))?
    } else {
        let mut buffer = String::new();
        io::stdin()
            .read_to_string(&mut buffer)
            .context("Failed to read from stdin")?;
        buffer
    };

    // Get the tree-sitter grammar for Elm
    let grammar = tree_sitter_elm::LANGUAGE;

    // Create the Topiary query
    let query = TopiaryQuery::new(&grammar.into(), ELM_QUERY)
        .map_err(|e| anyhow!("Failed to parse Elm formatting query: {:?}", e))?;

    // Create the language configuration
    let language = Language {
        name: "elm".to_string(),
        query,
        grammar: grammar.into(),
        indent: Some("    ".to_string()), // Elm uses 4-space indentation
    };

    // Create the formatting operation
    let operation = Operation::Format {
        skip_idempotence: args.skip_idempotence,
        tolerate_parsing_errors: false,
    };

    // Format the code
    let mut input = input_content.as_bytes();
    let mut output = Vec::new();

    formatter(&mut input, &mut output, &language, operation)
        .map_err(|e| anyhow!("Failed to format Elm code: {:?}", e))?;

    let formatted = String::from_utf8(output).context("Formatter produced invalid UTF-8")?;

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
        if let Some(ref path) = args.input {
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

    Ok(())
}
