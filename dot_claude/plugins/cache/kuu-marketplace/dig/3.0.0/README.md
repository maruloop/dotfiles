# dig

Deep exploratory interview to discover unknowns and strengthen plans using the AskUserQuestion tool.

## Overview

This plugin conducts deep, iterative interviews to uncover hidden assumptions, undiscovered risks, and unconsidered decisions in your plans. Unlike simple clarification, dig probes beneath the surface -- challenging premises and finding what you haven't thought of yet.

## Installation

```
/plugin marketplace add fumiya-kume/claude-code
/plugin install dig@fumiya-kume/claude-code
```

## Usage

```
/dig
```

## Features

- **Assumption Mapping** - Identifies and categorizes implicit assumptions by risk level before questioning
- **Depth-first investigation** - Goes 2+ levels deep on each topic before moving to the next
- **Structured questioning** - Generates 2-3 focused questions per round with concrete options including pros/cons
- **Iterative deepening** - Discovers new questions from previous answers, creating a deepening spiral
- **Completeness evaluation** - Uses a structured checklist to determine when investigation is thorough
- **Plan integration** - Writes all decisions directly to the plan file

## How it works

1. **Context Gathering** - Read plan files, CLAUDE.md, and related documentation
2. **Assumption Mapping** - Identify implicit assumptions and rank by risk
3. **Deep Investigation** - Iterative rounds of structured questioning via AskUserQuestion
4. **Apply & Integrate** - Document discoveries and update the plan file
5. **Completeness Evaluation** - Check coverage and loop back if gaps remain

## Allowed Tools

This command uses the following tools:
- Write
- Edit
- Read
- Grep
- Glob
- TodoRead
- TodoWrite
- AskUserQuestion

## Plugin Structure

```
dig/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── dig.md
└── README.md
```

## License

GPL-3.0
