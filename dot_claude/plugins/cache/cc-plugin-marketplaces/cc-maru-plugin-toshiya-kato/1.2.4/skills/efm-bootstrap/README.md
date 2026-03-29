# EFM Bootstrapper Skill

Automatically provision and manage an **efm-langserver** instance per project to expose project-specific lint/format tools via LSP without manual configuration.

## What This Does

This skill:
- 🔍 **Detects** languages and tools in your project automatically
- 🛠️ **Resolves** tool paths (local binaries, virtualenvs, package managers)
- ⚙️ **Generates** EFM configuration tailored to your project
- 🚀 **Starts** and monitors efm-langserver with auto-restart
- 🔗 **Registers** the server with ClaudeCode LSP automatically
- 💾 **Caches** configuration (skips regeneration if nothing changed)

## Prerequisites

**Required:**
- `efm-langserver` - Install with:
  ```bash
  go install github.com/mattn/efm-langserver@latest
  ```
- `jq` - For JSON parsing (usually available on most systems)

**Recommended:**
- `bash` 4.0+ (included on macOS/Linux)
- Tools you want to lint/format with (eslint, prettier, ruff, etc.)

## Usage

Run the skill from your project root:

```bash
/efm-bootstrap
```

That's it! The skill will:
1. Detect all linting/formatting tools in your project
2. Generate EFM configuration
3. Start the server
4. Register with ClaudeCode

## Supported Tools

### JavaScript/TypeScript
- **Linters:** ESLint
- **Formatters:** Prettier, Biome
- **Detection:** `package.json`, `.eslintrc.*`, `.prettierrc`, `biome.json`

### Python
- **Linters:** Ruff, Mypy, Flake8
- **Formatters:** Ruff, Black
- **Detection:** `pyproject.toml`, `ruff.toml`, `mypy.ini`

### Go
- **Linters:** golangci-lint
- **Formatters:** gofmt
- **Detection:** `go.mod`, `.golangci.yml`

### Java
- **Linters:** Checkstyle (via Gradle wrapper)
- **Detection:** `build.gradle`, `checkstyle.xml`

## Customization

### User Overrides

Create `.claude/efm/overrides.yaml` in your project:

```yaml
# Override tool paths
tools:
  eslint:
    path: /custom/path/to/eslint
    args: ["--custom-flag"]
  ruff:
    disabled: true  # Disable a tool

# Control formatters per language
languages:
  typescript:
    formatters: ["prettier"]  # Exclude biome
```

### Custom Tools

Create `.claude/efm/tool-registry.json` in your project:

```json
{
  "tools": {
    "custom-linter": {
      "language": "javascript",
      "type": "linter",
      "command": "custom-linter",
      "args": ["--format", "compact"],
      "stdin": true,
      "errorFormat": "%f:%l:%c: %m"
    }
  }
}
```

Fields:
- `language`: Target language (javascript, python, go, java, etc.)
- `type`: Tool type (linter or formatter)
- `command`: Tool command name
- `args`: Default arguments (array)
- `stdin`: Whether tool supports stdin (true/false)
- `errorFormat`: Output format for linters (using printf-style specifiers)

## Project Structure

After running the skill, your project will have:

```
.claude/efm/
├── config.yaml          # Generated EFM configuration
├── metadata.json        # Fingerprint for change detection
├── efm.pid              # Server process ID
├── efm.log              # Server logs
├── start.sh             # Server startup script
├── overrides.yaml       # (Optional) User overrides
├── tool-registry.json   # (Optional) Custom tool definitions
└── tools/               # Wrapper scripts
    └── checkstyle-wrapper.sh
```

## How It Works

### Detection

1. **Config file detection** - Scans for `package.json`, `pyproject.toml`, `go.mod`, etc.
2. **Tool extraction** - Parses config files to find tools (e.g., eslint in devDependencies)
3. **File validation** - Confirms languages with file extension scan
4. **Custom tools** - Merges `tool-registry.json` if present

### Tool Resolution

Priority order:
1. **Project-local** - `node_modules/.bin/*`, `./gradlew`
2. **Package manager** - `pnpm exec`, `poetry run`, etc.
3. **Virtual environment** - `.venv/bin/*`, `venv/bin/*`
4. **System** - `which <tool>`

### Formatter Chaining

When multiple formatters are detected (e.g., eslint + prettier), they're chained via stdin:

```bash
eslint --fix --stdin | prettier --stdin-filepath ${INPUT}
```

### Change Detection

The skill calculates a fingerprint hash of:
- Config files (package.json, pyproject.toml, etc.)
- Resolved tool paths
- Generated config.yaml

If the hash matches the previous run, regeneration is skipped.

### Server Monitoring

The server runs with automatic restart on crash:
- Exponential backoff: 1s, 2s, 4s, 8s
- Maximum 5 retry attempts
- Graceful shutdown on manual stop

## Troubleshooting

### efm-langserver not found

```bash
# Install efm-langserver
go install github.com/mattn/efm-langserver@latest

# Ensure $GOPATH/bin is in PATH
export PATH="$PATH:$(go env GOPATH)/bin"
```

### Tools not detected

Check if:
- Config files exist (`package.json`, `pyproject.toml`, etc.)
- Dependencies are installed (`node_modules`, `.venv`)
- Tools are in PATH or project-local binaries

Run detection manually:
```bash
./scripts/detect-tools.sh .
```

### Config validation fails

```bash
# Validate manually
./scripts/validate-efm.sh .

# Check logs
cat .claude/efm/efm.log
```

### Server won't start

1. Check if efm-langserver is installed: `which efm-langserver`
2. Validate config: `./scripts/validate-efm.sh .`
3. Check logs: `cat .claude/efm/efm.log`
4. Try manual start: `./.claude/efm/start.sh`

## Manual Operations

### Check server status
```bash
./scripts/manage-server.sh status .
```

### Restart server
```bash
./scripts/manage-server.sh restart .
```

### Stop server
```bash
./scripts/manage-server.sh stop .
```

### Force regeneration
Delete the metadata file and run the skill again:
```bash
rm .claude/efm/metadata.json
/efm-bootstrap
```

## Environment Variables

- `CLAUDE_CODE_CONFIG` - Override ClaudeCode config location
- `.env` file - Parsed for tool authentication (API keys, etc.)

## Limitations

- EFM does not provide semantic analysis (types, symbols) - use native language servers for that
- Some tools cannot operate reliably on single files (e.g., some type checkers need full project context)
- Windows support is limited (bash wrappers require WSL or Git Bash)
- Monorepo sub-project configs may not be detected (root-level EFM only)

## Advanced

### Adding New Tool Templates

1. Create `templates/<tool>.yaml`:
```yaml
lint-command: '{{TOOL_PATH}} --format unix ${INPUT}'
lint-stdin: true
lint-formats:
  - '%f:%l:%c: %m'
root-markers:
  - .tool-config
```

2. Update `scripts/detect-tools.sh` to detect the tool
3. Update `scripts/generate-config.sh` if special handling is needed

### Creating Wrappers

See [wrappers/README.md](wrappers/README.md) for details on creating wrapper scripts for tools with non-standard output.

## Support

For issues or questions:
- Check logs: `.claude/efm/efm.log`
- Review config: `.claude/efm/config.yaml`
- Validate manually: `./scripts/validate-efm.sh .`
