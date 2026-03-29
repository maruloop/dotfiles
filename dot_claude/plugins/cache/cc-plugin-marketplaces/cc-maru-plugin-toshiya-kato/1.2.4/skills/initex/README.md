# /initex Skill

Advanced project initialization skill that generates optimal CLAUDE.md and .claude/rules/*.md files.

## Overview

**Problem:** Built-in `/init` generates verbose, single-file documentation with unnecessary information that LLMs often ignore.

**Solution:** `/initex` creates modular, minimal documentation following research-backed best practices:
- Progressive disclosure (separate rules/*.md files)
- Batched questioning (5 rounds instead of individual questions)
- Continuous refinement loop (keep asking until no more questions, ~5 loops suggested)
- WHAT/WHY/HOW structure in CLAUDE.md
- Brevity bias prevention (facts not instructions)
- Context engineering principles (pointers not copies)

## Usage

```bash
/initex
```

The skill will:
1. Auto-detect your project's tech stack, structure, and patterns
2. Ask clarifying questions in 5 batched rounds
3. Generate 3-4 core files + optional rules/*.md files based on your needs
4. Show previews of all files
5. Continue asking additional questions until you have no more (suggest ~5 loops)
6. Regenerate affected files after each question loop and show diffs
7. Enter plan mode to present all files for final review
8. Write files once you approve the plan

### Workflow

```
┌─────────────────────┐
│  Auto-Detection     │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  Round 1-5          │  ← 5 batched question rounds
│  Questions          │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  Generate All       │
│  Files              │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  Preview & Review   │
└──────────┬──────────┘
           │
      ┌────┴──────────┐
      │ More questions? │
      └─┬────────────┬─┘
   Yes  │            │  No
┌───────▼──────────┐ │
│ Ask what to      │ │
│ refine           │ │
└───────┬──────────┘ │
        │            │
┌───────▼──────────┐ │
│ Ask targeted     │ │
│ questions        │ │
└───────┬──────────┘ │
        │            │
┌───────▼──────────┐ │
│ Regenerate &     │ │
│ Show diffs       │ │
└───────┬──────────┘ │
        │            │
        └──────┐     │
               │     │
        (loop back)  │
        ~5 loops     │
        suggested    │
                     │
              ┌──────▼─────────┐
              │ Enter Plan Mode│
              │ for Review     │
              └──────┬─────────┘
                     │
              ┌──────▼─────────┐
              │ User Reviews   │
              │ Plan           │
              └──────┬─────────┘
                     │
              ┌──────▼─────────┐
              │ Approve or     │
              │ Request Changes│
              └──────┬─────────┘
                     │
              ┌──────▼──────┐
              │ Write Files │
              └─────────────┘
```

## Output Files

**Core (Always Generated):**
- `.claude/CLAUDE.md` - Minimal project summary with WHAT/WHY/HOW sections and pointers
- `.claude/rules/project-overview.md` - Tech stack, structure (WHAT)
- `.claude/rules/design-philosophy.md` - Architecture, decisions (WHY)
- `.claude/rules/development-workflow.md` - Commands, validation (HOW)

**Optional (Based on User Choice in Round 5):**
- `.claude/rules/security.md` - Mandatory security checks and patterns
- `.claude/rules/coding-style.md` - Immutability, file organization (NOT linter rules)
- `.claude/rules/testing.md` - TDD, coverage requirements
- `.claude/rules/git-workflow.md` - Commit format, PR process
- `.claude/rules/agents.md` - When to delegate to subagents
- `.claude/rules/performance.md` - Model selection, context management
- `.claude/rules/patterns.md` - API response formats, hooks
- `.claude/rules/hooks.md` - Hook documentation

## Key Features

- **Batched questioning** - 5 rounds of grouped questions for efficiency. 
- **Continuous refinement loop** - Keep asking questions until no more needed (~5 loops suggested). 
- **Incremental updates** - Regenerate only affected files and show diffs after each loop. 
- **Plan mode review** - Final review of all files in plan mode before writing. 
- **WHAT/WHY/HOW structure** - Clear organization in CLAUDE.md. 
- **Modular structure** - Separate files using @imports for cross-references. 
- **Minimal output** - Facts not instructions, pointers not copies. 
- **Smart detection** - Manifests, directory structure, architectural patterns. 
- **Extensive rules support** - 8 optional rules/*.md files covering security, testing, git workflow, etc.  
- **Monorepo support** - Per-workspace documentation. 
- **Multi-language support** - Primary + secondary language handling. 
- **Conditional rules** - Path-specific rules using YAML frontmatter. 
- **Dry-run preview** - See everything before writing.  

## Principles

1. **Write facts, not instructions** - "Uses bun" not "Use bun"
2. **Use pointers, not copies** - @package.json, never copy code
3. **Concise, key points only** - Target brevity, max 300 lines/file
4. **NO linter rules** - Skip all formatting/style questions
5. **Document as-is** - No judgment, no tech debt flagging
6. **High-level questions** - Infer details from concepts
7. **Top-down per category** - Context before specifics

## Reference

Based on: https://izanami.dev/post/47b08b5a-6e1c-4fb0-8342-06b8e627450a

Research papers:
- "The Prompt Report" (arxiv.org/abs/2406.06608)
- "A Survey of Context Engineering for LLMs" (arxiv.org/abs/2507.13334)
- "Agentic Context Engineering" (arxiv.org/abs/2510.04618)
