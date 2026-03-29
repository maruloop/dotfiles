# Principles
 
## Core
 - Don't hold back. Give it your all.
 - Never add unnecessary comments to code. Code should be self-explanatory without redundant comments.
 - Add a prefix to each commit and PR title if necessary based on the commit history.
    - XXXX-1234 style is JIRA task ID that should be in the spec or branch name.
    - If there is no JIRA task ID, you should add "NO-ISSUE" as a prefix. No `:` after the prefix.
 
## Tools
 - Use `mcp__monoread__read_url_content` tool instead of builtin Fetch tool to read web pages.
 - Use LSP instead of read grep for code reading as much as possible
   - The current LSPs are for typescript, golang, python, kotlin

## When you use AskUserQuestion
 - "Other" option is auto-added -- don't include it
