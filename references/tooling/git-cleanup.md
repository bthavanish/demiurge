# Git Cleanup Reference

Safely analyze and clean up accumulated git worktrees and local branches by categorizing them into safely deletable, potentially related, and active work.

## 6-Phase Workflow

### Phase 1: Comprehensive Analysis

Gather ALL information upfront before any categorization:

```bash
# Get default branch name
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD \
  2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Protected branches - never analyze or delete
protected='^(main|master|develop|release/.*)$'

# List all local branches with tracking info
git branch -vv

# List all worktrees
git worktree list

# Fetch and prune to sync remote state
git fetch --prune

# Get merged branches (into default branch)
git branch --merged "$default_branch"

# Get recent PR merge history (squash-merge detection)
git log --oneline "$default_branch" | grep -iE "#[0-9]+" | head -30

# For EACH non-protected branch, get unique commits and sync status
for branch in $(git branch --format='%(refname:short)' | grep -vE "$protected"); do
  echo "=== $branch ==="
  echo "Commits not in $default_branch:"
  git log --oneline "$default_branch".."$branch" 2>/dev/null | head -5
  echo "Commits not pushed to remote:"
  git log --oneline "origin/$branch".."$branch" 2>/dev/null | head -5 || echo "(no remote tracking)"
done
```

### Phase 2: Group Related Branches

Group by name prefix BEFORE individual categorization:

```bash
git branch --format='%(refname:short)' | sed 's/-[^-]*$//' | sort | uniq -c | sort -rn
```

For each group with 2+ branches:
1. Compare commit histories
2. Find merge evidence (which PRs incorporated work)
3. Identify the "final" branch
4. Mark superseded branches

**SUPERSEDED requires evidence:**
- A PR merged the work into main, OR
- A newer branch contains all commits from the older branch
- Name prefix alone is NOT sufficient

### Phase 3: Categorize Remaining Branches

Decision tree for individual branches:

```
Is branch merged into default branch?
├─ YES → SAFE_TO_DELETE (use -d)
└─ NO → Is tracking a remote?
        ├─ YES → Remote deleted? ([gone])
        │        ├─ YES → Was work squash-merged? (check main for PR)
        │        │        ├─ YES → SQUASH_MERGED (use -D)
        │        │        └─ NO → REMOTE_GONE (needs review)
        │        └─ NO → Local ahead of remote?
        │                ├─ YES (has output) → UNPUSHED_WORK (keep)
        │                └─ NO (empty output) → SYNCED_WITH_REMOTE (keep)
        └─ NO → Has unique commits?
                ├─ YES → LOCAL_WORK (keep)
                └─ NO → SAFE_TO_DELETE (use -d)
```

### Phase 4: Dirty State Detection

Check ALL worktrees and current directory for uncommitted changes:

```bash
# For each worktree path
git -C <worktree-path> status --porcelain

# For current directory
git status --porcelain
```

Display warnings prominently when dirty state detected.

### Phase 5: Execute

Run each deletion as a **separate command** so partial failures don't block remaining deletions:

```bash
git branch -d fix/typo
git branch -D feature/login
git worktree remove ../proj-auth
```

### Phase 6: Report

Provide summary of deleted branches, remaining branches, and any issues encountered.

## 7 Branch Categories

| Category | Meaning | Delete Command |
|----------|---------|----------------|
| SAFE_TO_DELETE | Merged into default branch | `git branch -d` |
| SQUASH_MERGED | Work incorporated via squash merge | `git branch -D` |
| SUPERSEDED | Part of a group, work verified in main via PR or in newer branch | `git branch -D` |
| REMOTE_GONE | Remote deleted, work NOT found in main | Review needed |
| UNPUSHED_WORK | Has commits not pushed to remote | Keep |
| LOCAL_WORK | Untracked branch with unique commits | Keep |
| SYNCED_WITH_REMOTE | Up to date with remote | Keep |

## Two-Confirmation Gates

### GATE 1: Present Complete Analysis

Present everything in ONE comprehensive view with:
- Related branch groups
- Individual branches by category
- Worktree status
- Summary statistics

Ask user what to clean up. **Do not proceed until user responds.**

### GATE 2: Final Confirmation with Exact Commands

Show the EXACT commands that will run with correct flags:

```markdown
I will execute:

# Merged branches (safe delete)
git branch -d fix/typo

# Squash-merged branches (force delete)
git branch -D feature/login

# Worktrees
git worktree remove ../proj-auth

Confirm? (yes/no)
```

## Protected Branches

Never analyze or delete these branches:

```bash
protected='^(main|master|develop|release/.*)$'
```

Programmatically filtered from all operations.

## Worktree Handling

- List all worktrees with `git worktree list`
- Check for uncommitted changes before removal
- Block removal without explicit data loss acknowledgment
- Clean up associated branches after worktree removal

## Squash-Merged Branch Handling

**IMPORTANT:** `git branch -d` will ALWAYS fail for squash-merged branches because git cannot detect that the work was incorporated.

When identifying squash-merged branches:
- Plan to use `git branch -D` (force delete) from the start
- Do NOT try `git branch -d` first
- Show `git branch -D` in confirmation step

## PR History Investigation

Don't rely on simple keyword matching. For `[gone]` branches:

```bash
# 1. Get the branch's commits that aren't in default branch
git log --oneline "$default_branch".."$branch"

# 2. Search default branch for PRs that incorporated this work
git log --oneline "$default_branch" | grep -iE "(branch-name|keyword|#[0-9]+)"

# 3. For related branch groups, trace which PRs merged which work
git log --oneline "$default_branch" | grep -iE "(#[0-9]+)" | head -20
```

## Safety Rules

1. **Never invoke automatically** - Only run when user explicitly requests
2. **Two confirmation gates only** - Analysis review, then deletion confirmation
3. **Use correct delete command** - `-d` for merged, `-D` for squash-merged/superseded
4. **Never touch protected branches** - main, master, develop, release/*
5. **Block dirty worktree removal** - Refuse without explicit data loss acknowledgment
6. **Group related branches** - Don't scatter them across categories

## Rationalizations to Reject

| Rationalization | Why It's Wrong |
|-----------------|----------------|
| "The branch is old, it's probably safe to delete" | Age doesn't indicate merge status |
| "I can recover from reflog if needed" | Reflog entries expire; users often don't know how to use it |
| "It's just a local branch, nothing important" | Local branches may contain the only copy of work |
| "The PR was merged, so the branch is safe" | Squash merges don't preserve branch history |
| "I'll just delete all the `[gone]` branches" | `[gone]` only means the remote was deleted; local may have unpushed commits |
| "The user seems to want everything deleted" | Always present analysis first; let the user choose |
