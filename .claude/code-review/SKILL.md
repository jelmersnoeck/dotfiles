---
name: code-review
description: "Run 3 parallel code reviews (security, maintenance, quality) in tmux panes. Usage: /code-review [PR] [--comment]"
disable-model-invocation: true
---

# Code Review — Parallel tmux Reviewers

Run three independent Claude instances in tmux panes, each focused on a different review dimension: **security**, **maintenance**, and **code quality**.

## Arguments

| Input | Mode | Example |
|-------|------|---------|
| (none) | Local — review uncommitted changes | `/code-review` |
| PR number | PR — review in worktree, output only | `/code-review 123` |
| PR number + `--comment` | PR — review + post line-level GH comments | `/code-review 123 --comment` |
| PR URL | PR — extract number from URL | `/code-review https://github.com/.../pull/123` |

Error if `--comment` is used without a PR number.

---

## Phase 1: Pre-flight & Parse

Parse the arguments to determine the mode:

```bash
# Extract PR number from args (handles both "123" and "https://github.com/.../pull/123")
# Extract --comment flag
# Set MODE to "local" or "pr"
# Set COMMENT_MODE to true/false
```

Validate prerequisites:

```bash
# Always required
command -v tmux >/dev/null || { echo "Error: tmux is required"; exit 1; }
command -v claude >/dev/null || { echo "Error: claude CLI is required"; exit 1; }

# PR mode only
if [ "$MODE" = "pr" ]; then
  command -v gh >/dev/null || { echo "Error: gh CLI is required for PR review"; exit 1; }
  gh pr view "$PR_NUMBER" --json number > /dev/null 2>&1 || { echo "Error: PR #$PR_NUMBER not found"; exit 1; }
fi
```

Get repo context (PR mode):

```bash
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
```

If `--comment` is set but `MODE` is `local`, print an error: `"Error: --comment requires a PR number"` and stop.

---

## Phase 2: Prepare Code

### Local mode

```bash
# Try unstaged changes first, then staged, then HEAD
DIFF=$(git diff HEAD)
if [ -z "$DIFF" ]; then
  DIFF=$(git diff --staged)
fi
if [ -z "$DIFF" ]; then
  DIFF=$(git diff)
fi

if [ -z "$DIFF" ]; then
  echo "No changes to review."
  # Stop here
fi

echo "$DIFF" > /tmp/code-review-diff.patch
```

### PR mode

```bash
PR_BASE=$(gh pr view "$PR_NUMBER" --json baseRefName -q .baseRefName)
PR_HEAD=$(gh pr view "$PR_NUMBER" --json headRefName -q .headRefName)
PR_HEAD_SHA=$(gh pr view "$PR_NUMBER" --json headRefOid -q .headRefOid)

# Ensure .worktrees/ is in .gitignore
grep -qxF '.worktrees/' .gitignore || echo '.worktrees/' >> .gitignore

# Fetch the PR head
git fetch origin "$PR_HEAD"

# Remove existing worktree if present
if [ -d ".worktrees/pr-${PR_NUMBER}" ]; then
  git worktree remove ".worktrees/pr-${PR_NUMBER}" --force
fi

# Create worktree at the PR head (detached)
git worktree add ".worktrees/pr-${PR_NUMBER}" "origin/${PR_HEAD}" --detach

# Three-dot diff (matches what GitHub shows)
git diff "origin/${PR_BASE}...origin/${PR_HEAD}" > /tmp/code-review-diff.patch
```

---

## Phase 3: Assemble Prompts

For each reviewer type (`security`, `maintenance`, `quality`), create a temp file at `/tmp/code-review-{type}.md` containing the sections below. Use heredocs or the Write tool.

### 3a. Project Context Header (same for all 3)

```markdown
# Code Review — {Type} Dimension

## Project Context
- **Stack**: Next.js 16, Auth.js v5, Prisma 6, PostgreSQL, Tailwind CSS v4, Zod v4
- **Mode**: {local|pr}
- **Repo**: {OWNER_REPO or "local"}
{if PR mode:}
- **PR**: #{PR_NUMBER}
- **Head SHA**: {PR_HEAD_SHA}
- **Worktree**: .worktrees/pr-{PR_NUMBER} (use this path to read full files for context)
{endif}
- **Comment mode**: {true|false}

## Key Conventions
- Zod v4 is imported as `zod/v4` (not `zod`)
- Auth: `auth()` from `lib/auth.ts`, JWT sessions, Strava OAuth only
- Prisma client singleton from `lib/prisma.ts`
- Intensity: watts (cycling) or sec/km (running, displayed as m:ss)
- All API routes must verify `session.user.id === resource.userId`

## Diff to Review

\`\`\`diff
{contents of /tmp/code-review-diff.patch}
\`\`\`
```

### 3b. Reviewer-Specific Prompt

Append the contents of the corresponding prompt file:
- Security: `.claude/skills/code-review/prompts/security.md`
- Maintenance: `.claude/skills/code-review/prompts/maintenance.md`
- Quality: `.claude/skills/code-review/prompts/quality.md`

### 3c. GitHub Comment Instructions (only if `--comment` is true)

Append the following:

```markdown
## GitHub Comment Instructions

Post line-level comments on the PR for each finding. Use this command for EACH comment:

\`\`\`bash
gh api repos/{OWNER_REPO}/pulls/{PR_NUMBER}/comments \
  -f body="**[{Type} - {Severity}]** {Description}

**Fix:** {Recommendation}" \
  -f commit_id="{PR_HEAD_SHA}" \
  -f path="{file_path}" \
  -F line={line_number} \
  -f side="RIGHT"
\`\`\`

Rules:
- Post each comment individually (not batched into a review)
- Only comment on findings with High confidence
- Use the exact file path as shown in the diff (relative to repo root)
- Use the line number from the NEW side of the diff (the + lines)
- Replace {Type}, {Severity}, {Description}, {Recommendation} with actual values
```

Fill in `{OWNER_REPO}`, `{PR_NUMBER}`, and `{PR_HEAD_SHA}` with concrete values.

---

## Phase 4: Launch tmux Panes

```bash
# Detect tmux context
if [ -n "$TMUX" ]; then
  # Inside tmux — create new window
  tmux new-window -n "code-review"
  TARGET="$(tmux display-message -p '#S'):code-review"
else
  # Outside tmux — create new session
  tmux new-session -d -s code-review -n reviews
  TARGET="code-review:reviews"
fi

# Create 3 panes (pane 0 already exists from the new window/session)
tmux split-window -h -t "${TARGET}.0"
tmux split-window -v -t "${TARGET}.1"
tmux select-layout -t "$TARGET" even-horizontal

# Set pane titles
tmux select-pane -t "${TARGET}.0" -T "Security"
tmux select-pane -t "${TARGET}.1" -T "Maintenance"
tmux select-pane -t "${TARGET}.2" -T "Quality"
```

---

## Phase 5: Launch Claude Instances

Determine allowed tools:

```bash
# Base tools for all reviewers
BASE_TOOLS="Read,Grep,Glob,Bash(git diff:*),Bash(git log:*),Bash(git show:*)"

# Add gh api tool if comment mode
if [ "$COMMENT_MODE" = true ]; then
  ALLOWED_TOOLS="${BASE_TOOLS},Bash(gh api:*)"
else
  ALLOWED_TOOLS="$BASE_TOOLS"
fi

# Add worktree directory if PR mode
if [ "$MODE" = "pr" ]; then
  ADD_DIR="--add-dir .worktrees/pr-${PR_NUMBER}"
else
  ADD_DIR=""
fi
```

Send commands to each pane:

```bash
# Security (pane 0)
tmux send-keys -t "${TARGET}.0" \
  "cat /tmp/code-review-security.md | claude -p --model opus --allowedTools '${ALLOWED_TOOLS}' --permission-mode bypassPermissions ${ADD_DIR} 2>&1 | tee /tmp/code-review-security-output.txt; echo '--- REVIEW COMPLETE ---'" Enter

# Maintenance (pane 1)
tmux send-keys -t "${TARGET}.1" \
  "cat /tmp/code-review-maintenance.md | claude -p --model opus --allowedTools '${ALLOWED_TOOLS}' --permission-mode bypassPermissions ${ADD_DIR} 2>&1 | tee /tmp/code-review-maintenance-output.txt; echo '--- REVIEW COMPLETE ---'" Enter

# Quality (pane 2)
tmux send-keys -t "${TARGET}.2" \
  "cat /tmp/code-review-quality.md | claude -p --model opus --allowedTools '${ALLOWED_TOOLS}' --permission-mode bypassPermissions ${ADD_DIR} 2>&1 | tee /tmp/code-review-quality-output.txt; echo '--- REVIEW COMPLETE ---'" Enter
```

---

## Phase 6: Report

Tell the user where the reviews are running:

**If inside tmux**: "Three reviews are running in the **code-review** window. Switch to it to watch progress. When all panes show `--- REVIEW COMPLETE ---`, come back and I'll summarize the results."

**If outside tmux**: "Three reviews are running in a tmux session. Attach with: `tmux attach -t code-review`. When all panes show `--- REVIEW COMPLETE ---`, come back and I'll summarize the results."

Also tell the user: "Output is being saved to `/tmp/code-review-{security,maintenance,quality}-output.txt`. You can ask me to summarize these when the reviews complete."

---

## Phase 7: Cleanup (user-triggered)

When the user returns and asks for a summary or cleanup:

1. Read the three output files and provide a consolidated summary
2. Clean up:

**PR mode** (automatic):
```bash
git worktree remove ".worktrees/pr-${PR_NUMBER}" --force 2>/dev/null
rm -f /tmp/code-review-security.md /tmp/code-review-maintenance.md /tmp/code-review-quality.md
rm -f /tmp/code-review-diff.patch
rm -f /tmp/code-review-security-output.txt /tmp/code-review-maintenance-output.txt /tmp/code-review-quality-output.txt
```

**Local mode**: Ask the user before cleaning up temp files.
