# elmfmt

A code formatter for the [Elm](https://elm-lang.org/) programming language, built on [Topiary](https://topiary.tweag.io/).

## Installation

### From source

Requires Rust toolchain.

```bash
# Clone the repository
git clone https://github.com/your-username/elmfmt.git
cd elmfmt

# Install
cargo install --path .
```

## Usage

```bash
# Format a file and print to stdout
elmfmt src/Main.elm

# Format a file in place
elmfmt -i src/Main.elm

# Write to a different file
elmfmt src/Main.elm -o formatted.elm

# Check if a file is formatted (exits with code 1 if not)
elmfmt -c src/Main.elm

# Format from stdin
cat src/Main.elm | elmfmt
```

### Options

| Option | Description |
|--------|-------------|
| `[FILE]` | Input file (reads from stdin if not provided) |
| `-o, --output <FILE>` | Write output to a file |
| `-i, --in-place` | Modify the file in place |
| `-c, --check` | Check if file is formatted without modifying |
| `--skip-idempotence` | Skip idempotence check |
| `-h, --help` | Show help |
| `-V, --version` | Show version |

## Configuration

Create an `elmfmt.yaml` file in your project directory. The formatter searches for this file starting from the input file's directory and moving upward.

```yaml
# Number of spaces for indentation (default: 2)
indentation: 2

# Style for if-then-else expressions: 'indented' or 'hanging' (default: indented)
if-style: indented
```

### If-Style Options

**Indented** (default):

```elm
if condition then
    expr1

else
    expr2
```

**Hanging**:

```elm
if condition
    then expr1
    else expr2
```


## Editor Integration

### VSCode

To use elmfmt with the
[Elm Language Server extension](https://marketplace.visualstudio.com/items?itemName=Elmtooling.elm-ls-vscode),
add the following to your VSCode settings:

```json
{
  "elmLS.elmFormatPath": "/Users/your-username/.cargo/bin/elmfmt"
}
```

Replace `/Users/your-username/.cargo/bin/elmfmt` with the actual path
to your elmfmt binary.
You can find it by running `which elmfmt` after installation.
