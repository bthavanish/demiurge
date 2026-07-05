# DevContainer Setup Reference

Creates pre-configured devcontainers with Claude Code, language-specific tooling, and persistent volumes for isolated development environments.

## Auto-Detection

### Project Name Inference

Check in order (use first match):

1. `package.json` → `name` field
2. `pyproject.toml` → `project.name`
3. `Cargo.toml` → `package.name`
4. `go.mod` → module path (last segment after `/`)
5. Directory name as fallback

Convert to slug: lowercase, replace spaces/underscores with hyphens.

### Language Stack Detection

| Language | Detection Files |
|----------|-----------------|
| Python | `pyproject.toml`, `*.py` |
| Node/TypeScript | `package.json`, `tsconfig.json` |
| Rust | `Cargo.toml` |
| Go | `go.mod`, `go.sum` |

### Multi-Language Priority

If multiple languages are detected, configure in this order:

1. **Python** - Primary, uses Dockerfile for uv + Python installation
2. **Node/TypeScript** - Uses devcontainer feature
3. **Rust** - Uses devcontainer feature
4. **Go** - Uses devcontainer feature

Chain all setup commands in `postCreateCommand`:
```
uv run /opt/post_install.py && uv sync && npm ci
```

## Generated Files

Create these in the project's `.devcontainer/` directory:

| File | Purpose |
|------|---------|
| `Dockerfile` | Container build instructions |
| `devcontainer.json` | VS Code/devcontainer configuration |
| `post_install.py` | Post-creation setup script |
| `.zshrc` | Shell configuration |
| `install.sh` | CLI helper for managing the devcontainer (`devc` command) |

## Security Features

### Bubblewrap Sandboxing

- Uses bubblewrap for process isolation
- socat for controlled network access

### Network Isolation

- iptables and ipset for network control
- NET_ADMIN capability for network management tools

### Read-Only Mount

- `.devcontainer/` mounted read-only to prevent container escape

### Token Forwarding

- `CLAUDE_CODE_OAUTH_TOKEN` and `ANTHROPIC_API_KEY` via `remoteEnv`
- Tokens forwarded securely without hardcoding

## Base Template Features

- **Claude Code** with marketplace plugins (anthropics/skills, trailofbits/skills, trailofbits/skills-curated)
- **Python 3.13** via uv (fast binary download)
- **Node 22** via fnm (Fast Node Manager)
- **ast-grep** for AST-based code search
- **Modern CLI tools**: ripgrep, fd, fzf, tmux, git-delta

## Language-Specific Configuration

### Python Projects

**Dockerfile additions:**
```dockerfile
# Install Python via uv (fast binary download, not source compilation)
RUN uv python install <version> --default
```

**Extensions:**
```json
"ms-python.python",
"ms-python.vscode-pylance",
"charliermarsh.ruff"
```

**postCreateCommand:**
```
rm -rf .venv && uv sync && uv run /opt/post_install.py
```

### Node/TypeScript Projects

**No Dockerfile additions needed** - Node 22 included via fnm.

**Extensions:**
```json
"dbaeumer.vscode-eslint",
"esbenp.prettier-vscode"
```

**postCreateCommand** (detect from lockfile):
- `pnpm-lock.yaml` → `pnpm install --frozen-lockfile`
- `yarn.lock` → `yarn install --frozen-lockfile`
- `package-lock.json` → `npm ci`
- No lockfile → `npm install`

### Rust Projects

**Features:**
```json
"ghcr.io/devcontainers/features/rust:1": {}
```

**Extensions:**
```json
"rust-lang.rust-analyzer",
"tamasfe.even-better-toml"
```

**postCreateCommand:**
```
uv run /opt/post_install.py && cargo build --locked
```

### Go Projects

**Features:**
```json
"ghcr.io/devcontainers/features/go:1": {
  "version": "latest"
}
```

**Extensions:**
```json
"golang.go"
```

**postCreateCommand:**
```
uv run /opt/post_install.py && go mod download
```

## CLI Helper

The `install.sh` script provides a `devc` command for managing the devcontainer:

```bash
.devcontainer/install.sh self-install
```

## Features vs Dockerfile Decision

| Use Features When | Use Dockerfile When |
|-------------------|---------------------|
| Installing standard tools (GitHub CLI, languages) | Installing specific versions |
| Feature does what you need out of the box | Custom configuration needed |
| Automatic updates with version bumps | Combining tools in optimized layers |

## Dockerfile Best Practices

| Practice | Why |
|----------|-----|
| Order by change frequency | Rarely-changing layers first |
| Combine related RUN commands | Reduces layers, cache coherence |
| Clean up in same layer | Don't leave apt cache in layers |
| Use multi-stage builds | Separate build from runtime |
| Pin versions with digests | Supply chain security |
| Switch to non-root user last | Do root operations first |
| Use COPY over ADD | ADD has unnecessary features |
| Use .dockerignore | Reduce context size |

## Validation Checklist

Before presenting files:

1. All `{{PROJECT_NAME}}` placeholders replaced
2. All `{{PROJECT_SLUG}}` placeholders replaced
3. Valid JSON syntax in `devcontainer.json`
4. Language-specific extensions added
5. `postCreateCommand` includes all required setup commands

## User Instructions

1. Start: "Open in VS Code and select 'Reopen in Container'"
2. Alternative: `devcontainer up --workspace-folder .`
3. CLI helper: Run `.devcontainer/install.sh self-install` to add `devc` to PATH
