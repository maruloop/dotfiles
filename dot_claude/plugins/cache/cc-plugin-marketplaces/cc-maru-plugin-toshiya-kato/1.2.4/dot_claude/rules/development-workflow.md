@./project-overview.md

## Development Commands

- `git add . && git commit` - Version control for plugin changes
- Load plugin in Claude Code CLI - Test skills in actual environment
- Edit `skills/*/SKILL.md` or `agents/*/*.md` - Modify prompts

## Validation

Changes verified through:
1. Load plugin in Claude Code
2. Run the modified skill (e.g., `/initex`, `/fetch-review-comments`)
3. Test on sample repositories to verify behavior
4. Review markdown prompt logic for correctness

## Testing Strategy

Manual end-to-end testing in Claude Code CLI:
- Load the plugin
- Execute skills in real conversation contexts
- Validate outputs match expected behavior
- Test edge cases on sample projects

## Plugin Development Flow

1. Edit skill/agent prompts or scripts
2. Commit changes with conventional commit format (feat:, fix:, etc)
3. Load plugin in Claude Code to test
4. Verify skill behavior on test repositories
5. Push to plugin marketplace repository

## File Modification Guidelines

- Only modify files in `.claude/` during skill execution (skills should not touch project files)
- Shell scripts must be executable (`chmod +x`)
- SKILL.md files follow specific format (YAML frontmatter + prompt)
- Agent .md files require YAML frontmatter (name, description, model, allowed-tools)
