---
name: handover
description: Type /handover at anypoint during a session, and Claude will look back thorough everything you two did together and generate a HANDOVER.md file in your current project folder.
allowed-tools:
  - Read
  - EDIT
  - WRITE
  - Bash(ls:*)
  - Bash(mkdir:*)
---

Think of it like a shift-change report - it tells the next Claude exactly where things stand so nothing gets lost between sessions.

What the handover doc covers:
 - What you were working on add what got done
 - What worked and what didn't (including bugs and how they were fixed)
 - Key decisions made and why
 - Lessons learned and gotchas
 - Clear next steps
 - A map of important files
