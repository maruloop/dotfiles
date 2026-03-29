# fetch-review-comments

Fetch unresolved PR review comments with file paths and line numbers for easy discussion.

## Usage

```bash
/fetch-review-comments
```

## What It Does

This skill automatically:
1. Detects the pull request associated with your current git branch
2. Fetches all review comment threads from the PR
3. Organizes comments by file and separates current vs outdated comments
4. Displays them in a readable format with full conversation threads

After displaying comments, you can discuss with Claude how to address specific feedback.

## Prerequisites

- GitHub CLI (`gh`) must be installed and authenticated
- Must be run from a git branch that has an associated pull request

## Output Format

Comments are grouped into two sections:
- **Current Comments**: Comments that apply to the current code
- **Outdated Comments**: Comments where the code has changed since the comment was made

Each comment shows:
- File path and line numbers
- Comment author and timestamp
- Full conversation thread with replies indented

## Example

```
## Review Comments

### Current Comments

#### In src/components/Button.tsx lines 25-30

**@reviewer1** (2024-01-23 14:30:00):
This component should handle loading state better.

  → **@author** (2024-01-23 15:00:00):
  Good point, I'll add a loading spinner.
```
