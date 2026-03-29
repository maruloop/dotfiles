#!/usr/bin/env bash
set -euo pipefail

# detect-tools.sh - Detect languages and linting/formatting tools in a project
# Usage: ./detect-tools.sh <project_root>

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

# Output arrays
declare -A LANGUAGES
declare -A TOOLS

# Helper function to add language
add_language() {
    LANGUAGES["$1"]=1
}

# Helper function to add tool
add_tool() {
    local tool="$1"
    local language="$2"
    TOOLS["$tool"]="$language"
}

# Detect JavaScript/TypeScript
detect_js_ts() {
    if [[ -f "package.json" ]]; then
        add_language "javascript"
        add_language "typescript"

        # Check for specific tools in package.json
        if command -v jq >/dev/null 2>&1 && [[ -f "package.json" ]]; then
            local pkg_content
            pkg_content=$(cat package.json)

            # Check devDependencies and dependencies
            if echo "$pkg_content" | jq -e '.devDependencies.eslint // .dependencies.eslint' >/dev/null 2>&1; then
                add_tool "eslint" "javascript"
            fi

            if echo "$pkg_content" | jq -e '.devDependencies.prettier // .dependencies.prettier' >/dev/null 2>&1; then
                add_tool "prettier" "javascript"
            fi

            if echo "$pkg_content" | jq -e '.devDependencies."@biomejs/biome" // .dependencies."@biomejs/biome"' >/dev/null 2>&1; then
                add_tool "biome" "javascript"
            fi

            if echo "$pkg_content" | jq -e '.devDependencies.typescript // .dependencies.typescript' >/dev/null 2>&1; then
                add_tool "tsc" "typescript"
            fi
        fi

        # Check for config files
        [[ -f ".eslintrc.js" || -f ".eslintrc.json" || -f ".eslintrc.yml" || -f "eslint.config.js" ]] && add_tool "eslint" "javascript"
        [[ -f ".prettierrc" || -f ".prettierrc.json" || -f ".prettierrc.yml" || -f "prettier.config.js" ]] && add_tool "prettier" "javascript"
        [[ -f "biome.json" || -f "biome.jsonc" ]] && add_tool "biome" "javascript"
    fi

    # Validate with file extensions
    if find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) \
        -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" \
        | head -1 | grep -q .; then
        add_language "javascript"
    fi
}

# Detect Python
detect_python() {
    if [[ -f "pyproject.toml" || -f "setup.py" || -f "requirements.txt" || -f "Pipfile" ]]; then
        add_language "python"

        # Check pyproject.toml for tools
        if [[ -f "pyproject.toml" ]]; then
            if grep -q '\[tool.ruff\]' pyproject.toml 2>/dev/null; then
                add_tool "ruff" "python"
            fi
            if grep -q '\[tool.black\]' pyproject.toml 2>/dev/null; then
                add_tool "black" "python"
            fi
            if grep -q '\[tool.mypy\]' pyproject.toml 2>/dev/null; then
                add_tool "mypy" "python"
            fi
        fi

        # Check for config files
        [[ -f "ruff.toml" || -f ".ruff.toml" ]] && add_tool "ruff" "python"
        [[ -f ".flake8" ]] && add_tool "flake8" "python"
        [[ -f "mypy.ini" || -f ".mypy.ini" ]] && add_tool "mypy" "python"
    fi

    # Validate with file extensions
    if find . -type f -name "*.py" \
        -not -path "*/.venv/*" -not -path "*/venv/*" -not -path "*/.git/*" -not -path "*/build/*" \
        | head -1 | grep -q .; then
        add_language "python"
    fi
}

# Detect Go
detect_go() {
    if [[ -f "go.mod" ]]; then
        add_language "go"

        # Check for config files
        [[ -f ".golangci.yml" || -f ".golangci.yaml" ]] && add_tool "golangci-lint" "go"

        # gofmt is standard with Go
        add_tool "gofmt" "go"
    fi

    # Validate with file extensions
    if find . -type f -name "*.go" \
        -not -path "*/vendor/*" -not -path "*/.git/*" \
        | head -1 | grep -q .; then
        add_language "go"
    fi
}

# Detect Java
detect_java() {
    if [[ -f "build.gradle" || -f "build.gradle.kts" || -f "pom.xml" ]]; then
        add_language "java"

        # Check for checkstyle
        if [[ -f "checkstyle.xml" ]] || grep -q "checkstyle" build.gradle* pom.xml 2>/dev/null; then
            add_tool "checkstyle" "java"
        fi
    fi

    # Validate with file extensions
    if find . -type f -name "*.java" \
        -not -path "*/build/*" -not -path "*/target/*" -not -path "*/.git/*" \
        | head -1 | grep -q .; then
        add_language "java"
    fi
}

# Load custom tool registry if exists
load_custom_tools() {
    local registry_file=".claude/efm/tool-registry.json"
    if [[ -f "$registry_file" ]] && command -v jq >/dev/null 2>&1; then
        # Parse custom tools from registry
        local tools_json
        tools_json=$(jq -r '.tools | to_entries[] | "\(.key):\(.value.language)"' "$registry_file" 2>/dev/null || echo "")

        while IFS=: read -r tool language; do
            [[ -n "$tool" && -n "$language" ]] && add_tool "$tool" "$language"
            add_language "$language"
        done <<< "$tools_json"
    fi
}

# Main detection flow
main() {
    detect_js_ts
    detect_python
    detect_go
    detect_java
    load_custom_tools

    # Build JSON output
    local languages_json="[]"
    local tools_json="{}"

    # Convert languages to JSON array
    if command -v jq >/dev/null 2>&1; then
        languages_json=$(printf '%s\n' "${!LANGUAGES[@]}" | jq -R . | jq -s .)

        # Convert tools to JSON object
        tools_json="{"
        local first=true
        for tool in "${!TOOLS[@]}"; do
            if [[ "$first" == true ]]; then
                first=false
            else
                tools_json+=","
            fi
            tools_json+="\"$tool\":\"${TOOLS[$tool]}\""
        done
        tools_json+="}"
    else
        # Fallback without jq
        languages_json="["
        local first=true
        for lang in "${!LANGUAGES[@]}"; do
            if [[ "$first" == true ]]; then
                first=false
            else
                languages_json+=","
            fi
            languages_json+="\"$lang\""
        done
        languages_json+="]"

        tools_json="{"
        first=true
        for tool in "${!TOOLS[@]}"; do
            if [[ "$first" == true ]]; then
                first=false
            else
                tools_json+=","
            fi
            tools_json+="\"$tool\":\"${TOOLS[$tool]}\""
        done
        tools_json+="}"
    fi

    # Output final JSON
    echo "{\"languages\":$languages_json,\"tools\":$tools_json}"
}

main
