---
name: initex
description: Generate optimal CLAUDE.md with WHAT/WHY/HOW sections and .claude/rules/*.md files through 5 rounds of batched questioning with continuous refinement loop (until no questions, ~5 loops suggested), following research-backed best practices for LLM context engineering.
allowed-tools:
  - Write
  - Edit
  - Read
  - Bash(ls:*)
  - Bash(mkdir:*)
  - AskUserQuestion
  - EnterPlanMode
---

**Key Principle:** Create minimal, modular documentation using progressive disclosure, batched questioning, and continuous refinement loop - NOT verbose single-file output like /init.

## Your Task

Generate project documentation files in `.claude/` directory:
1. `.claude/CLAUDE.md` - Minimal project summary with WHAT/WHY/HOW sections and pointers
2. `.claude/rules/project-overview.md` (WHAT) - Tech stack, structure, map
3. `.claude/rules/design-philosophy.md` (WHY) - Architecture patterns, decisions
4. `.claude/rules/development-workflow.md` (HOW) - Commands, validation tools
5. Optional rules/*.md files:
   - security.md - Mandatory security checks
   - coding-style.md - Immutability, file organization (NOT linter rules)
   - testing.md - TDD, coverage requirements
   - git-workflow.md - Commit format, PR process
   - agents.md - When to delegate to subagents
   - performance.md - Model selection, context management
   - patterns.md - API response formats, hooks
   - hooks.md - Hook documentation

## Execution Process

### Phase 1: Auto-Detection

Scan the codebase using Glob and Grep:
- **Manifest files:** package.json, go.mod, requirements.txt, Cargo.toml, etc.
- **Directory structure:** src/, apps/, packages/, cmd/, internal/, tests/, etc.
- **Config files:** tsconfig.json, docker-compose.yml, .github/workflows/, etc.
- **Architectural patterns:** routes/, controllers/, schema/, resolvers/, domain/, etc.

**Detection Rules:**
- Present all detected items in first batch of questions
- If conflicts detected (e.g., both npm and yarn), include in questions
- For monorepos: Include workspace/app questions in batched format
- For multi-language: Include language priority questions
- If detection fails, ask manual input (graceful fallback)

### Phase 2: Batched Questioning (5 Rounds)

**Round 1: Project Basics**

Ask all foundational questions at once using AskUserQuestion:
1. Project type (web app, CLI, library, API, monorepo?)
2. Primary tech stack confirmation (from auto-detection)
3. Primary language (if multi-language detected)
4. Package manager (if multiple detected: npm/yarn/pnpm/bun)
5. Monorepo workspaces confirmation (if detected)

**Round 2: Architecture & Design (WHY)**

Ask all architecture questions together:
1. Architecture pattern (MVC, DDD, Clean Architecture, layered, etc.)
2. Why this structure was chosen
3. Key design decisions and their rationale
4. For monorepos: bounded contexts explanation
5. Any domain-driven design boundaries

**Round 3: Development Workflow (HOW)**

Ask all workflow questions together:
1. Build command
2. Test command
3. Type checking command (if TypeScript/typed language)
4. Linting command
5. Other critical commands (deploy, migrate, etc.)
6. Project-specific tooling or workflows

**Round 4: Testing & Quality**

Ask all quality-related questions together:
1. Test strategy (unit, integration, e2e)
2. Coverage requirements (if any)
3. Security requirements or critical security patterns
4. Performance considerations
5. CI/CD workflow (if .github/workflows or similar detected)

**Round 5: Optional Rules Files**

Present all optional rules files and ask which to generate:
- security.md - Security checks and patterns
- coding-style.md - High-level coding patterns (NOT linter rules)
- testing.md - Test strategy and requirements
- git-workflow.md - Commit format and PR process
- agents.md - When to delegate to subagents
- performance.md - Model selection and context management
- patterns.md - API response formats and hooks
- hooks.md - Hook documentation

Ask: "Which optional rules files would you like to generate?"

### Phase 2.5: Generate All Files

After collecting all answers from 5 rounds, generate all files at once:

1. **project-overview.md (WHAT)**
```markdown
@./design-philosophy.md

## Tech Stack
[Languages, frameworks with versions]

## Project Structure
- `dir/` - [Description]

## Key Dependencies
[Critical dependencies with purpose]
```

2. **design-philosophy.md (WHY)**
```markdown
@./project-overview.md

## Architecture Pattern
[Pattern name and description]

## Design Decisions
- [Decision]: [Rationale]

## Why This Structure
[Explanation of organization]

[For monorepos:]
## Bounded Contexts
- `apps/name`: [Purpose and boundaries]
```

3. **development-workflow.md (HOW)**
```markdown
@./project-overview.md

## Development Commands
- `command` - [Purpose]

## Validation
[How to verify changes]

## Project-Specific Tools
[Unique tooling or workflows]
```

4. **Optional rules files** (based on Round 5 selections)

Show all generated files in preview before proceeding to Phase 3.

### Phase 3: Generate CLAUDE.md

Create minimal file with explicit WHAT/WHY/HOW sections:
```markdown
## WHAT: Project Overview

[1-2 sentence project summary]

### Tech Stack
- [Primary language and framework]
- [Key libraries/tools]

### Directory Structure
- `dir/` - [Description]
- `dir2/` - [Description]

## WHY: Design Philosophy

### Architecture Pattern
[Pattern name - e.g., MVC, DDD, Clean Architecture]

### Key Design Decisions
- [Decision 1]: [Brief rationale]
- [Decision 2]: [Brief rationale]

## HOW: Development Workflow

### Development Commands
- `[build command]` - [Purpose]
- `[test command]` - [Purpose]
- `[other critical commands]` - [Purpose]

### Validation
[How to verify changes work]

## Detailed Documentation

### Core Documentation
- @./rules/project-overview.md
- @./rules/design-philosophy.md
- @./rules/development-workflow.md

### Additional Rules
[Include generated optional rules files]
- @./rules/security.md
- @./rules/testing.md
- etc.

### Configuration References
- @package.json
- @tsconfig.json
[+ other key config files]
```

### Phase 4: Apply Advanced Features

**Add Import Statements:**
- In CLAUDE.md: Use `@./rules/<filename>`
- In rules/*.md files: Use `@./<filename>` for cross-references

**Conditional Rules (Ask User):**
- "Would you like path-specific rules for any file types?"
- If yes, add YAML frontmatter:
```yaml
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
[Rules that only apply to API files]
```

**Subdirectories for Monorepos (Ask User):**
- "Organize rules in subdirectories (frontend/, backend/, shared/)?"
- If yes, create structure accordingly

### Phase 5: Final Preview & Iterative Refinement

Show comprehensive preview:

1. **Full content of all files** (display each file completely)

2. **Structure overview:**
```
.claude/
├── CLAUDE.md (50-70 lines)
│   Sections: WHAT (Project Overview), WHY (Design Philosophy), HOW (Development Workflow)
└── rules/
    ├── project-overview.md (120 lines)
    ├── design-philosophy.md (80 lines)
    ├── development-workflow.md (60 lines)
    └── [optional files based on Round 5 selections]
        ├── security.md
        ├── testing.md
        ├── git-workflow.md
        └── etc.
```

3. **Validation checklist:**
```
✓ WHY/WHAT/HOW coverage complete
✓ No linter/formatter rules included
✓ Uses @imports, no code snippets copied
✓ Conditional rules applied where appropriate
✓ All detected technologies documented
✓ Max 300 lines per file
```

**Ask using AskUserQuestion:** "Do you have any additional questions to refine the documentation?"
- Option 1: "No, proceed to plan mode review"
- Option 2: "Yes, I have additional questions"

### Phase 5.5: Additional Question Loops (If Needed)

**Loop until user has no more questions (suggest ~5 loops as reasonable limit):**

**Each loop iteration:**

1. **Ask:** "What would you like to clarify or refine?"
   - Use AskUserQuestion to present options:
     - "Project overview details"
     - "Architecture/design decisions"
     - "Development workflow"
     - "Testing strategy"
     - "Security requirements"
     - "Git workflow/commit format"
     - "Performance/context management"
     - "Other specific aspect"

2. **Based on selection, ask targeted follow-up questions**
   - Batch related questions together (like initial rounds)
   - Can be 1-5 questions depending on the aspect

3. **Regenerate affected files**
   - Update only the files impacted by new information
   - Show diff of changes using +/-/~ format
   - Show updated preview of modified files

4. **Ask again:** "Do you have any additional questions to refine the documentation?"
   - Option 1: "No, proceed to plan mode review" → Exit loop, go to Phase 6
   - Option 2: "Yes, I have additional questions" → Continue loop

**Loop tracking:**
- Track loop count (1st refinement, 2nd refinement, etc.)
- After 5 loops, suggest: "We've done 5 refinement rounds. Continue or finalize?"
- User can continue beyond 5 if needed, but suggest wrapping up

### Phase 6: Enter Plan Mode for Final Review

**Use EnterPlanMode tool to present the generated documentation as a plan:**

1. **Create a plan file** that includes:
   - Complete content of CLAUDE.md
   - Complete content of all rules/*.md files
   - File structure overview
   - Validation checklist

2. **The plan shows what will be written** - user can review all files before they're created

3. **User reviews the plan** and can:
   - Auto-approve: Files get written automatically
   - Manual approve: Proceed to write files
   - Request changes: Update files based on feedback and present updated plan

**After plan approval, write files** using Write tool

**If .claude/ or files exist:**
- Check if .claude/CLAUDE.md or .claude/rules/*.md exist
- Warn in plan: "Files already exist and will be overwritten"
- After approval, overwrite the files

## Writing Principles (CRITICAL)

### 1. Write Facts, Not Instructions

✓ GOOD: "This project uses bun"
✗ BAD: "Use bun for all commands"

### 2. Use Pointers, Not Copies

✓ GOOD: "@package.json for dependencies"
✗ BAD: Copying code snippets (they become stale)

### 3. Concise, Key Points Only

- Target: As brief as possible while complete
- Max: 300 lines per file
- Avoid verbose explanations

### 4. NO Linter/Formatter Rules

- Skip ALL formatting/style questions entirely
- Do NOT ask about: indentation, semicolons, quotes, line length
- Rationale: Claude learns style from codebase naturally

### 5. Document As-Is (No Judgment)

- NO anti-pattern flagging
- NO technical debt documentation
- NO improvement suggestions

### 6. High-Level Questions, Infer Details

✓ GOOD: "What architecture pattern?" → User: "DDD" → Infer bounded contexts
✗ BAD: "What's in controller layer?" "What's in service layer?"

### 7. Top-Down Per Category

1. High-level context (purpose, main tech)
2. Structure (directories, organization)
3. Specifics (conventions, tooling)

## Example Outputs

### project-overview.md
```markdown
@./design-philosophy.md

## Tech Stack

TypeScript: 5.3
Next.js: 15 (App Router)
Tailwind CSS: 3.4

## Project Structure

- `src/app/` - Next.js App Router pages and layouts
- `src/components/` - React UI components
- `src/lib/` - Utility functions and shared logic

## Key Dependencies

- Drizzle ORM for database access
- Zod for schema validation
```

### design-philosophy.md
```markdown
@./project-overview.md

## Architecture Pattern

Component-based architecture with Next.js App Router

## Design Decisions

- Server Components prioritized for better performance
- Client state management uses Zustand for simplicity
- API calls handled through Next.js Server Actions

## Why This Structure

The app/ directory follows Next.js 15 conventions with file-based routing. Components are co-located with their usage. Shared utilities are centralized in lib/.
```

### development-workflow.md
```markdown
@./project-overview.md

## Development Commands

- `bun run dev` - Start development server (http://localhost:3000)
- `bun run build` - Create production build
- `bun run test` - Run test suite with Vitest

## Validation

Changes verified through:
- TypeScript type checking (no errors)
- Test suite passing
- Production build succeeding

## Project-Specific Tools

This project uses Bun as the package manager and runtime, not npm or Node.js
```

### .claude/CLAUDE.md
```markdown
## WHAT: Project Overview

E-commerce site frontend. Next.js 15 App Router + Tailwind CSS + shadcn/ui

### Tech Stack
- Next.js 15 (App Router)
- TypeScript 5.3
- Tailwind CSS + shadcn/ui

### Directory Structure
- `src/app/` - App Router pages
- `src/components/` - UI components
- `src/lib/` - Utility functions
- `src/hooks/` - Custom hooks

## WHY: Design Philosophy

### Architecture Pattern
Component-based architecture with Next.js App Router

### Key Design Decisions
- Server Components prioritized for better performance
- Client state uses Zustand for simplicity
- API calls use Server Actions

## HOW: Development Workflow

### Development Commands
- `bun run dev` - Development server
- `bun run build` - Production build
- `bun run test` - Run tests

### Validation
Changes verified through TypeScript type checking, test suite, and production build

## Detailed Documentation

### Core Documentation
- @./rules/project-overview.md
- @./rules/design-philosophy.md
- @./rules/development-workflow.md

### Configuration References
- @package.json
- @tsconfig.json
```

## Error Handling

| Scenario | Action |
|----------|--------|
| No manifest files found | Ask: "What is your tech stack?" |
| Cannot detect project type | Ask: "Is this a web app, CLI, library, or API?" |
| No write permissions | Show error: "Cannot write to .claude/. Check permissions." |
| Conflicting package managers | Ask: "Found both npm and yarn. Which is primary?" |
| Multi-language detected | Ask: "Primary language? Secondary languages?" |
| Monorepo detected | Ask about each workspace/app individually |
| No tests found | Skip testing.md, don't ask |
| Detection tool fails | Continue with manual questions, inform user |

## Key Reminders

1. **ALWAYS use AskUserQuestion tool** - Not conversational yes/no questions
2. **Batch questions into 5 rounds** - Collect all related info at once
3. **Generate all files after questions complete** - Don't generate incrementally
4. **CLAUDE.md must have WHAT/WHY/HOW sections** - Explicitly labeled
5. **Support all optional rules/*.md files** - Ask which ones to generate in Round 5
6. **Preview before write** - Full content + structure + checklist
7. **Continuous refinement loop** - Keep asking "More questions?" until user says no
8. **Track loop count** - Suggest wrapping up after ~5 loops
9. **Show diffs when regenerating** - Use +/-/~ format to highlight changes
10. **Regenerate only affected files** - Don't regenerate everything on each loop
11. **Enter plan mode for final review** - Use EnterPlanMode to present all generated files as a plan for user approval

## Start Now

Begin by scanning the codebase for detection. Use Glob and Grep tools to find manifest files, directories, and patterns. Then start the interactive questioning process.

Remember: Create minimal, modular documentation that follows progressive disclosure principles.

## Iterative Process Flow

```
1. Auto-detect → 2. Ask 5 rounds → 3. Generate files → 4. Preview
                                                            ↓
                      ┌─────────────────────────────────────┘
                      │
        5. More questions? ─→ No → 6. Enter Plan Mode
                  ↓ Yes                      ↓
            7. Ask what to refine        User reviews plan
                  ↓                           ↓
            8. Ask targeted questions     Approve/Request changes
                  ↓                           ↓
            9. Regenerate affected        If approved:
               files (show diffs)         Write files ✓
                  ↓                           ↓
       (Loop back to step 5)             If changes requested:
       (Suggest ~5 loops)                Update & re-enter plan mode
```
