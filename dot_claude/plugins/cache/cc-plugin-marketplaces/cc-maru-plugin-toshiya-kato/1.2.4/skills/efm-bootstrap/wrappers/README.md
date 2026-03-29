# EFM Wrappers

This directory contains wrapper scripts that normalize tool output into a standard format for EFM.

## Purpose

Some linting/formatting tools have non-standard output formats that EFM cannot parse directly. Wrappers normalize these outputs to the standard format:

```
file:line:col: message
```

## Available Wrappers

### checkstyle-wrapper.sh

Normalizes Gradle checkstyle output.

**Usage:**
```bash
./checkstyle-wrapper.sh <file_path>
```

**What it does:**
1. Runs `./gradlew checkstyleMain checkstyleTest`
2. Parses XML output from `build/reports/checkstyle/main.xml`
3. Converts to `file:line:col: message` format
4. Filters for the specified file

## Creating New Wrappers

To create a wrapper for a new tool:

1. Create a bash script in this directory
2. Accept file path as first argument
3. Run the tool and capture output
4. Parse and normalize to `file:line:col: message` format
5. Make it executable: `chmod +x wrapper.sh`
6. Create a template fragment in `templates/` that references it
7. Update `scripts/install-wrappers.sh` to install it

Example template:
```bash
#!/usr/bin/env bash
set -euo pipefail

FILE_PATH="${1:-}"
PROJECT_ROOT="{{PROJECT_ROOT}}"

cd "$PROJECT_ROOT"

# Run your tool
output=$(your-tool "$FILE_PATH" 2>&1)

# Parse and normalize
echo "$output" | awk '{print "file:line:col: message"}'
```
