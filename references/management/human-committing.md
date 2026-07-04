# Human Committing Style

A realistic human commit flow. Each commit is a logical unit of work, not a mechanical dump of files.

## Principles

- **One logical change per commit.** Each commit should answer "what did I just do?" in one sentence.
- **Commit in the order a human would build.** Core first, features second, polish last.
- **Never mention parts, batches, or sequencing.** Just describe the change.
- **Use conventional commits format.** `type(scope): description`
- **No "WIP", no "fix stuff", no "updates".** Every commit message should be meaningful 6 months from now.

## Commit Flow Pattern

A typical human building a feature from scratch:

```
1. feat: set up [core thing]          # Foundation
2. feat: add [first feature]          # First real feature
3. feat: add [second feature]         # Second feature
4. feat: add [third feature]          # Third feature
5. docs: update README                # Documentation after features work
6. chore: clean up / config           # Cleanup at the end
```

A human fixing a bug:

```
1. fix: describe the actual bug       # The fix
2. test: add test for [edge case]     # Test if needed
```

A human refactoring:

```
1. refactor: what changed and why     # The refactor
2. perf: if performance improved      # Separate if perf is a side effect
```

## Types

| Type | When |
|------|------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Code restructuring, no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `chore` | Build, tooling, config |
| `ci` | CI/CD changes |
| `revert` | Reverting a previous commit |

## Scopes

Use scopes when the change touches a specific area:

```
feat(auth): add JWT validation
fix(api): handle null response from upstream
docs(readme): add install instructions
```

## Message Rules

- Subject line: imperative mood, lowercase after colon, no period, <=50 chars
- Body: explain *why*, not *what*. Only when the subject isn't enough.
- No AI attribution ("Co-authored-by: AI")
- No emoji in commit messages
- No "This commit adds/fixes/implements..." -- just say what it is

## Example

```bash
# Human builds a feature incrementally:
git add src/auth/ && git commit -m "feat: add JWT token validation"
git add src/middleware/ && git commit -m "feat: add auth middleware for protected routes"
git add src/routes/ && git commit -m "feat: protect /api/users endpoints"
git add tests/auth.test.ts && git commit -m "test: add JWT validation edge cases"
git add README.md && git commit -m "docs: add auth setup instructions"
```

## Anti-patterns

- "WIP: working on feature" -- commit when it works, not before
- "fix stuff" -- be specific
- "address PR feedback" -- say what changed
- "update code" -- too vague
- Splitting one logical change across multiple commits
- Combining unrelated changes in one commit
