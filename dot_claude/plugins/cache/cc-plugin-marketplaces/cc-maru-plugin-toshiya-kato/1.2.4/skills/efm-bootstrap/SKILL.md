---
name: efm-bootstrap
description: Automatically provision and manage efm-langserver for project lint/format tools
allowed-tools:
  - Bash
  - Read
  - Write
context: fork
---

# EFM Bootstrapper Skill

You are a ClaudeCode skill that automatically sets up and manages efm-langserver for a project. Your goal is to provide seamless LSP-based linting and formatting without manual configuration.

## Workflow

Execute the following steps in order:

### Step 1: Check efm-langserver Installation

Run the following command to check if efm-langserver is installed:

```bash
which efm-langserver
```

**If not found:**
- Display error message:
  ```
  ❌ efm-langserver not found

  Install with:
    go install github.com/mattn/efm-langserver@latest

  Make sure $GOPATH/bin is in your PATH
  ```
- Exit the skill

### Step 2: Detect Project Tools

Get the skill directory path:
```bash
SKILL_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
```

Note: On macOS, use `readlink` without `-f` or use `greadlink -f` if GNU coreutils is installed.

Run the detection script:
```bash
cd <project_root>
DETECTION_OUTPUT=$(<skill_dir>/scripts/detect-tools.sh .)
```

Parse the JSON output to extract:
- `languages` array
- `tools` object (tool name → language)

**Display results** as a markdown table:

```markdown
## Detected Tools

| Language   | Tools              |
|------------|--------------------|
| JavaScript | eslint, prettier   |
| Python     | ruff, black        |
```

If no tools detected:
- Display: "⚠️  No linting/formatting tools detected in this project"
- Ask user if they want to continue anyway
- If no, exit skill

### Step 3: Check Dependencies

Run the dependency check script:
```bash
CHECK_OUTPUT=$(<skill_dir>/scripts/check-dependencies.sh . "$DETECTION_OUTPUT")
```

Parse the JSON output. If `hasWarnings: true`:
- Display each warning from the `warnings` array
- These are non-blocking - continue regardless

### Step 4: Resolve Tool Paths

For each tool in the detected tools:

```bash
TOOL_PATH=$(<skill_dir>/scripts/resolve-tool-path.sh <tool_name> <language> . 2>&1)
```

Collect successful resolutions into a JSON object:
```json
{
  "eslint": "/path/to/node_modules/.bin/eslint",
  "prettier": "pnpm exec prettier",
  "ruff": ".venv/bin/ruff"
}
```

If any tools fail to resolve:
- Display: "⚠️  Could not resolve path for: <tool_name>"
- Continue with remaining tools

### Step 5: Check Fingerprint

Run fingerprint check:
```bash
FINGERPRINT_OUTPUT=$(<skill_dir>/scripts/check-fingerprint.sh .)
```

Parse the JSON output. If `changed: false`:
- Display: "✅ Configuration unchanged, reusing existing server"
- Skip to Step 8 (ClaudeCode integration)

If `changed: true`:
- Display: "🔄 Changes detected: <reason>"
- Continue to next step

### Step 6: Generate Configuration

First, install wrappers if needed (checkstyle, etc.):
```bash
TOOLS_LIST=$(echo "$DETECTION_OUTPUT" | jq -r '.tools | keys | join(",")')
<skill_dir>/scripts/install-wrappers.sh . "$TOOLS_LIST"
```

Then generate the EFM config:
```bash
TOOLS_JSON=$(echo "$DETECTION_OUTPUT" | jq -c '.tools')
PATHS_JSON=$(echo "$RESOLVED_PATHS" | jq -c '.')
<skill_dir>/scripts/generate-config.sh . "$TOOLS_JSON" "$PATHS_JSON"
```

Display: "✅ Generated config at .claude/efm/config.yaml"

### Step 7: Start EFM Server

Validate the config:
```bash
<skill_dir>/scripts/validate-efm.sh .
```

If validation fails:
- Display error and exit

Start the server:
```bash
<skill_dir>/scripts/manage-server.sh start .
```

Display: "🚀 EFM server started (check .claude/efm/efm.log for details)"

### Step 8: Update ClaudeCode Config

Prepare languages JSON array:
```bash
LANGUAGES_JSON=$(echo "$DETECTION_OUTPUT" | jq -c '.languages')
```

Update ClaudeCode configuration:
```bash
<skill_dir>/scripts/update-claude-config.sh . "$LANGUAGES_JSON"
```

If this fails (e.g., jq not available):
- Display the manual registration instructions shown by the script
- This is non-fatal, continue

### Step 9: Save Metadata

Now that everything is successful, save the fingerprint metadata:

```bash
# Extract current fingerprint hash
FINGERPRINT_HASH=$(echo "$FINGERPRINT_OUTPUT" | jq -r '.hash')

# Build metadata
cat > .claude/efm/metadata.json <<EOF
{
  "hash": "$FINGERPRINT_HASH",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "tools": $(echo "$TOOLS_JSON" | jq 'keys'),
  "languages": $LANGUAGES_JSON
}
EOF
```

### Step 10: Final Summary

Display final summary:

```markdown
## ✅ EFM Server Ready

### Configured Tools
<display markdown table of tools and languages>

### Files Created
- `.claude/efm/config.yaml` - EFM configuration
- `.claude/efm/start.sh` - Server startup script
- `.claude/efm/metadata.json` - Change detection cache
- `.claude/efm/efm.log` - Server logs

### Customization
To customize tool paths or disable tools, create:
- `.claude/efm/overrides.yaml` - User overrides
- `.claude/efm/tool-registry.json` - Custom tool definitions

See README.md for details.

### Next Steps
- Your editor should now show lint/format diagnostics
- Re-run `/efm-bootstrap` if you change project config files
- Check server status: `./scripts/manage-server.sh status .`
```

## Error Handling

Throughout the workflow:
- Capture stderr from all script executions
- If a critical script fails (non-zero exit code):
  - Display the error output
  - Explain what failed
  - Suggest troubleshooting steps
  - Exit gracefully

Non-critical failures (warnings):
- Display but continue execution
- Examples: missing dependencies, optional tool not found

## Script Path Resolution

Always resolve the skill directory path at the start:

```bash
# Get the directory where SKILL.md resides
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

Then use `$SKILL_DIR/scripts/<script>.sh` for all script invocations.

## Notes

- All scripts are designed to be idempotent - safe to run multiple times
- Scripts output JSON where possible for easy parsing
- The skill should be conversational and explain what it's doing at each step
- Use emoji to make output more readable (✅ ❌ ⚠️  🔄 🚀)
- Always display markdown tables for structured data
- Show file paths relative to project root when possible
