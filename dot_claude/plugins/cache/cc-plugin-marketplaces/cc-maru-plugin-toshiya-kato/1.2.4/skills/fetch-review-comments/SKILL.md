---
name: fetch-review-comments
description: Fetch unresolved PR review comments with file paths and line numbers
allowed-tools:
  - Bash
  - Read
context: fork
---

# Fetch PR Review Comments

You are a PR review assistant. Your task is to fetch and display all unresolved review comments from the current pull request, organized by file for easy discussion with the user.

## Workflow

Execute the following steps to fetch and display review comments:

### Step 1: Check GitHub CLI Authentication

Before fetching comments, verify that `gh` is authenticated.

1. **Check auth status:**

```bash
gh auth status
```

2. **If not logged in:**
   - Treat this as an error condition
   - Explain that GitHub CLI authentication is required
   - Provide clear instructions:
     - Run `gh auth login` to authenticate
     - Or set `GH_TOKEN` environment variable
     - Then re-run `/fetch-review-comments`

### Step 2: Get Current PR Information

Get the PR number and basic information for the current branch:

```bash
gh pr view --json number,url,title
```

**Error Handling:**

- If this fails, the current branch likely has no associated PR
- Show a clear message: "No pull request found for the current branch. Make sure you're on a branch that has an open PR."
- Exit gracefully

### Step 3: Fetch Review Comments

Once you have the PR number, fetch all review comments using the GitHub API:

```bash
gh api "/repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments" --paginate
```

The `{owner}` and `{repo}` placeholders will be automatically replaced by `gh`. The `--paginate` flag ensures all comments are fetched even if there are many pages.

**Response Structure:**

Each comment object contains:
- `path`: File path relative to repo root
- `line`: Current line number (null if code has changed)
- `start_line`: Start line for multi-line comments
- `original_line`: Original line number when comment was made
- `original_start_line`: Original start line
- `body`: Comment text
- `user.login`: Author username
- `created_at`: Timestamp
- `in_reply_to_id`: ID of parent comment (null for original comments)
- `pull_request_review_id`: Review ID this comment belongs to

### Step 4: Filter and Process Comments

Process the fetched comments to identify unresolved threads:

1. **Parse the JSON response** using `jq` or similar

2. **Identify comment threads:**
   - Comments with `in_reply_to_id == null` are original comments (thread starters)
   - Comments with `in_reply_to_id != null` are replies

3. **Separate current vs outdated comments:**
   - Current: Comments where `line != null` (still apply to current code)
   - Outdated: Comments where `line == null` (code has changed)

4. **Group by file:**
   - Create separate groups for current and outdated comments
   - Within each group, organize by file path

5. **Build thread structure:**
   - For each original comment, find all replies using `in_reply_to_id`
   - Preserve chronological order within threads

6. **Sort files alphabetically** within each section

**Note on Filtering Resolved Comments:**

GitHub's PR comments API doesn't directly indicate if a thread is "resolved" in the UI sense. The resolution status is typically tracked at the review level. For this skill:
- Display ALL comment threads (both current and outdated)
- The user can see which conversations exist and decide which to address
- If a PR has no comments at all, show an appropriate message

### Step 5: Display Comments Grouped by File

Format and display the comments according to this structure:

**If no comments exist:**

```
## Review Comments

No review comments found for this pull request.
```

**If comments exist:**

```
## Review Comments

### Current Comments

#### In {relative_path} lines {start_line}-{end_line}

**@{author}** ({timestamp}):
{comment body}

  → **@{author}** ({timestamp}):
  {reply body}

  → **@{author}** ({timestamp}):
  {reply body}

#### In {another_file} lines {start_line}-{end_line}

...

### Outdated Comments (code has changed)

#### In {file_path} lines {original_start_line}-{original_end_line} [OUTDATED]

**@{author}** ({timestamp}):
{comment body}

  → **@{author}** ({timestamp}):
  {reply body}
```

**Formatting Rules:**

1. **Section Headers:**
   - "### Current Comments" for comments on current code
   - "### Outdated Comments (code has changed)" for outdated comments
   - Only show sections if they have content

2. **File Headers:**
   - Use "#### In {path} lines {start}-{end}" format
   - For single-line comments where start == end: "#### In {path} line {line}"
   - Add [OUTDATED] marker for outdated comments

3. **Comment Threading:**
   - Original comment at left margin with bold author
   - Replies indented with "  → " (2 spaces + arrow + space)
   - Include full timestamp in ISO format or human-readable format

4. **Line Ranges:**
   - For current comments: Use `start_line` and `line` from the response
   - For outdated comments: Use `original_start_line` and `original_line`
   - If multi-line comment: show range like "25-30"
   - If single-line: show just the number like "25"

## Error Handling

Handle these specific error scenarios:

### Authentication Failure

```
Error: GitHub CLI is not authenticated.

Please authenticate with GitHub:
1. Run: gh auth login
2. Or set GH_TOKEN environment variable
3. Then re-run /fetch-review-comments
```

### No PR Found

```
Error: No pull request found for the current branch.

Make sure you're on a branch that has an open pull request.
You can check your current branch with: git branch --show-current
```

### API Rate Limit or Network Errors

```
Error: Failed to fetch review comments from GitHub.

Possible causes:
- API rate limit exceeded
- Network connectivity issues
- Insufficient permissions

Please try again in a few minutes, or check your network connection.
```

### No Comments on PR

```
## Review Comments

No review comments found for this pull request.
```

## Implementation Notes

1. **Command Execution:**
   - Use Bash tool for all `gh` commands
   - Parse JSON with `jq` when needed
   - Handle command failures gracefully

2. **JSON Processing:**
   - The API returns an array of comment objects
   - Process all pages with `--paginate` flag
   - Build thread structure by matching `in_reply_to_id` fields

3. **Output Formatting:**
   - Keep formatting clean and readable
   - Use markdown headers for structure
   - Ensure proper indentation for replies
   - Sort files alphabetically for consistency

4. **Read-Only Operation:**
   - This skill only fetches and displays information
   - No modifications to files or PR state
   - No automatic file reading (let user decide)

## Important Guidelines

- **Be thorough:** Fetch all comments across all pages
- **Be clear:** Format output for easy scanning and discussion
- **Be helpful:** Provide context with file paths and line numbers
- **Be informative:** Show full conversation threads
- **Know your limits:** If authentication fails or no PR exists, explain clearly what the user needs to do
- **Stay focused:** Only display comments, don't make suggestions or read files automatically

## Example Bash Command Flow

```bash
# 1. Check auth
gh auth status

# 2. Get PR info
PR_INFO=$(gh pr view --json number,url,title)
PR_NUMBER=$(echo "$PR_INFO" | jq -r '.number')

# 3. Fetch comments
COMMENTS=$(gh api "/repos/{owner}/{repo}/pulls/$PR_NUMBER/comments" --paginate)

# 4. Process and display
# (Parse JSON, group by file, format threads, output markdown)
```

## After Displaying Comments

Once all comments are displayed:
- **Wait for the user** to decide next steps
- User may ask to discuss specific comments
- User may ask to read specific files
- User may ask for help addressing comments
- **Do not proactively suggest actions** - maintain user control
