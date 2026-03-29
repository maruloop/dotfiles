#!/usr/bin/env bash
set -euo pipefail

# checkstyle-wrapper.sh - Normalize Gradle checkstyle output
# This wrapper runs checkstyle via Gradle and normalizes the output
# to the format: file:line:col: message

FILE_PATH="${1:-}"

if [[ -z "$FILE_PATH" ]]; then
    echo "Error: file path required" >&2
    exit 1
fi

PROJECT_ROOT="{{PROJECT_ROOT}}"
cd "$PROJECT_ROOT"

# Run checkstyle via gradlew
if [[ ! -x "./gradlew" ]]; then
    echo "Error: gradlew not found" >&2
    exit 1
fi

# Run checkstyle and capture output
# Note: checkstyle task may fail with non-zero exit, but we want to parse errors
output=$(./gradlew checkstyleMain checkstyleTest --console=plain 2>&1 || true)

# Parse checkstyle XML output if available
# Checkstyle typically outputs to build/reports/checkstyle/
report_file="build/reports/checkstyle/main.xml"

if [[ -f "$report_file" ]]; then
    # Parse XML and output in format: file:line:col: message
    # This is a simplified parser - in production, you'd use xmllint or similar
    grep -E '<error|<file' "$report_file" | \
    awk -v file_filter="$FILE_PATH" '
        /<file/ {
            match($0, /name="([^"]+)"/, arr)
            current_file = arr[1]
        }
        /<error/ {
            if (current_file ~ file_filter || file_filter == current_file) {
                match($0, /line="([^"]+)"/, line_arr)
                match($0, /column="([^"]+)"/, col_arr)
                match($0, /message="([^"]+)"/, msg_arr)
                printf "%s:%s:%s: %s\n", current_file, line_arr[1], col_arr[1], msg_arr[1]
            }
        }
    '
else
    # Fallback: try to parse plain text output
    echo "$output" | grep -E '^\[ant:checkstyle\]' | \
    sed -E 's/^\[ant:checkstyle\] ([^:]+):([0-9]+):([0-9]+): (.*)$/\1:\2:\3: \4/' | \
    grep "$FILE_PATH" || true
fi
