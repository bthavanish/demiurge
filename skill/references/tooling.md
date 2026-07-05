# Tooling Reference

DevContainer setup, git cleanup, modern Python tooling, macOS sandbox profiling.

---

## DevContainer Setup

### Auto-Detection

Project name: `package.json` name > `pyproject.toml` name > `Cargo.toml` name > `go.mod` last segment > directory name.

Language stack: Python (pyproject.toml, *.py), Node (package.json, tsconfig.json), Rust (Cargo.toml), Go (go.mod).

### Generated Files

| File | Purpose |
|---|---|
| `Dockerfile` | Container build |
| `devcontainer.json` | VS Code/devcontainer config |
| `post_install.py` | Post-creation setup |
| `.zshrc` | Shell config |
| `install.sh` | CLI helper (`devc` command) |

### Language-Specific

- **Python**: uv for package management, Dockerfile for uv + Python. Extensions: python, pylance, ruff.
- **Node/TypeScript**: fnm for Node 22. Extensions: eslint, prettier. Detect from lockfile (pnpm/yarn/npm).
- **Rust**: devcontainer feature for Rust. Extensions: rust-analyzer, even-better-toml.
- **Go**: devcontainer feature for Go. Extensions: go.

### Dockerfile Best Practices

Order by change frequency, combine related RUN, clean up in same layer, multi-stage builds, pin versions, non-root user, .dockerignore.

---

## Git Cleanup

### 6-Phase Workflow

1. **Analysis**: list all branches/worktrees, fetch/prune, get merged branches, get PR merge history
2. **Group Related**: group by name prefix, compare histories, find merge evidence, mark superseded
3. **Categorize**: decision tree (merged? remote deleted? squash-merged? local work?)
4. **Dirty State**: check all worktrees for uncommitted changes
5. **Execute**: run each deletion as separate command
6. **Report**: summary of deleted/remaining branches

### 7 Categories

| Category | Delete Command |
|---|---|
| SAFE_TO_DELETE | `git branch -d` |
| SQUASH_MERGED | `git branch -D` |
| SUPERSEDED | `git branch -D` |
| REMOTE_GONE | Review needed |
| UNPUSHED_WORK | Keep |
| LOCAL_WORK | Keep |
| SYNCED_WITH_REMOTE | Keep |

### Protected Branches

Never analyze or delete: `main`, `master`, `develop`, `release/*`.

### Safety Rules

1. Never invoke automatically -- only when user explicitly requests
2. Two confirmation gates: analysis review, then deletion confirmation
3. Use correct flag: `-d` for merged, `-D` for squash-merged/superseded
4. Block dirty worktree removal without explicit data loss acknowledgment

---

## Modern Python

### Tool Overview

| Tool | Purpose | Replaces |
|---|---|---|
| **uv** | Package management | pip, virtualenv, pip-tools, pyenv |
| **ruff** | Linting + formatting | flake8, black, isort, pyupgrade |
| **ty** | Type checking | mypy, pyright |
| **pytest** | Testing | unittest |
| **prek** | Pre-commit hooks | pre-commit |

### Migration

- Remove: requirements.txt, setup.py, setup.cfg, .flake8, mypy.ini, tox.ini, Pipfile
- Use `uv add`/`uv remove` for deps. Never manually manage venvs.
- `[dependency-groups]` for dev/test/docs (PEP 735), not `[project.optional-dependencies]`.
- `uv run <cmd>` for all commands.

### Security Tools

shellcheck, detect-secrets, actionlint, zizmor, pip-audit, Dependabot.

### pyproject.toml Key Sections

`[project]` (PEP 621), `[dependency-groups]` (PEP 735), `[tool.uv]`, `[tool.ruff]`, `[tool.pytest]`, `[tool.coverage]`.

---

## macOS Seatbelt Sandbox Profiling

Generate minimally-permissioned allowlist-based sandbox configs for macOS.

### 4-Step Methodology

1. **Identify requirements**: file read/write, network, process, Mach IPC, signals, etc.
2. **Start minimal**: `(deny default)` + essential process operations + file-read-metadata
3. **Add file read**: allowlist with `file-read-data` (not `file-read*`) for specific paths
4. **Add file write**: working directory + temp dirs only

### Network Levels

- Block all: `(deny network*)`
- Localhost only: specific bind + outbound to localhost
- Allow all: `(allow network*)` (avoid if possible)

### Path Filters

```scheme
(subpath "/path")           ;; path and all descendants
(literal "/path/file")      ;; exact path only
(regex "^/path/.*\\.js$")   ;; regex match
```

### Iterative Testing

```bash
sandbox-exec -f profile.sb -D WORKING_DIR=/path -D HOME=$HOME /bin/echo "test"
sandbox-exec -f profile.sb -D WORKING_DIR=/path -D HOME=$HOME /path/to/app --args
```

Common failure: exit 134 = sandbox violation, ENOENT = missing `file-read-metadata`.
