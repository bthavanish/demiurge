# Modern Python Reference

Guide for modern Python tooling and best practices, replacing legacy tools with faster, simpler alternatives.

## Tool Overview

| Tool | Purpose | Replaces |
|------|---------|----------|
| **uv** | Package/dependency management | pip, virtualenv, pip-tools, pipx, pyenv |
| **ruff** | Linting AND formatting | flake8, black, isort, pyupgrade, pydocstyle |
| **ty** | Type checking | mypy, pyright (faster alternative) |
| **pytest** | Testing with coverage | unittest |
| **prek** | Pre-commit hooks | pre-commit (faster, Rust-native) |

### Security Tools

| Tool | Purpose | When It Runs |
|------|---------|--------------|
| **shellcheck** | Shell script linting | pre-commit |
| **detect-secrets** | Secret detection | pre-commit |
| **actionlint** | Workflow syntax validation | pre-commit, CI |
| **zizmor** | Workflow security audit | pre-commit, CI |
| **pip-audit** | Dependency vulnerability scanning | CI, manual |
| **Dependabot** | Automated dependency updates | scheduled |

## Migration Checklist

### Before Migration

- [ ] Determine layout: `src/` or flat? Configure `[tool.uv.build-backend]` if flat
- [ ] Decide uv.lock strategy: app (commit) vs library (.gitignore)
- [ ] Backup current state: Create a branch or tag before starting

### Cleanup Old Artifacts

```bash
# Find files with old linter pragmas
rg "# pylint:|# noqa:|# type: ignore" --files-with-matches

# Find missing __init__.py files
uv run ruff check --select=INP001 .
```

Remove these files after migration:
- [ ] `requirements.txt`, `requirements-dev.txt`
- [ ] `setup.py`, `setup.cfg`, `MANIFEST.in`
- [ ] `.flake8`, `mypy.ini`, `pyrightconfig.json`
- [ ] `tox.ini` (if not needed)
- [ ] `Pipfile`, `Pipfile.lock`
- [ ] Old virtual environments (`venv/`, `.venv/`)

### Post-Migration Easy Wins

```bash
# Pyupgrade modernization (typing, syntax)
uv run ruff check --select=UP --fix .

# Unnecessary variable assignments before return
uv run ruff check --select=RET504 --fix .

# Simplifications (conditionals, comprehensions)
uv run ruff check --select=SIM --fix .

# Remove commented-out code
uv run ruff check --select=ERA --fix .
```

### CI Cleanup

- [ ] Remove scheduled CI triggers (activity without progress is theater)
- [ ] Update CI to use `uv sync` and `uv run`
- [ ] Pin GitHub Actions to SHA hashes
- [ ] Set up security tooling

### Gradual ty Adoption

For legacy codebases with many type errors, start lenient:

```toml
[tool.ty.terminal]
error-on-warning = true

[tool.ty.environment]
python-version = "3.11"

[tool.ty.rules]
# Start with these ignored for legacy codebases
possibly-missing-attribute = "ignore"
unresolved-import = "ignore"
invalid-argument-type = "ignore"
not-subscriptable = "ignore"
unresolved-attribute = "ignore"
```

Remove rules as you fix errors.

### Supply Chain Security

- [ ] Add pip-audit to dependency groups
- [ ] Configure Dependabot with 7-day cooldown
- [ ] Pin exact versions in production (`==` not `>=`)

## Security Hooks

### prek (pre-commit runner)

```bash
# Homebrew (recommended)
brew install prek

# Cargo
cargo install prek

# Standalone installer
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/j178/prek/releases/latest/download/prek-installer.sh | sh
```

### Pre-commit Hooks

**shellcheck - Shell Script Linting:**
```yaml
- repo: https://github.com/koalaman/shellcheck-precommit
  rev: <latest>
  hooks:
    - id: shellcheck
      args: [--severity=error]
```

**detect-secrets - Secret Detection:**
```yaml
- repo: https://github.com/Yelp/detect-secrets
  rev: <latest>
  hooks:
    - id: detect-secrets
      args: [--baseline, .secrets.baseline]
```

First-time setup:
```bash
detect-secrets scan > .secrets.baseline
git add .secrets.baseline
```

**actionlint - Workflow Syntax Validation:**
```yaml
- repo: https://github.com/rhysd/actionlint
  rev: <latest>
  hooks:
    - id: actionlint
```

**zizmor - Workflow Security Audit:**
```yaml
- repo: https://github.com/zizmorcore/zizmor-pre-commit
  rev: <latest>
  hooks:
    - id: zizmor
      args: [--persona=regular, --min-severity=medium, --min-confidence=medium]
```

### CI Security

**pip-audit - Vulnerability Scanning:**
```toml
# pyproject.toml
[dependency-groups]
audit = ["pip-audit"]
```

```bash
# Audit current environment
uv run pip-audit

# Audit without installing (faster for CI)
uv run pip-audit .

# Fix automatically
uv run pip-audit --fix
```

## pyproject.toml Configuration

### Complete Example

```toml
[project]
name = "myproject"
version = "0.1.0"
description = "A modern Python project"
readme = "README.md"
license = "MIT"
requires-python = ">=3.11"
authors = [
    { name = "Your Name", email = "you@example.com" }
]
dependencies = [
    "requests",
    "rich",
]

[project.optional-dependencies]
# Use for optional features users can install
cli = ["typer"]

[project.scripts]
myproject = "myproject.cli:main"

[project.urls]
Homepage = "https://github.com/org/myproject"
Documentation = "https://myproject.readthedocs.io"
Repository = "https://github.com/org/myproject"

[build-system]
requires = ["uv_build>=0.9,<1"]
build-backend = "uv_build"

[dependency-groups]
dev = ["ruff", "ty"]
test = ["pytest", "pytest-cov", "hypothesis"]
docs = ["sphinx", "myst-parser"]

[tool.uv]
default-groups = ["dev", "test"]

[tool.ruff]
line-length = 100
target-version = "py311"
src = ["src"]

[tool.ruff.lint]
select = ["ALL"]
ignore = [
    "D",        # pydocstyle (enable selectively)
    "COM812",   # trailing comma (conflicts with formatter)
    "ISC001",   # implicit string concat (conflicts with formatter)
]

[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = [
    "S101",     # assert allowed in tests
    "PLR2004",  # magic values allowed in tests
    "ANN",      # annotations optional in tests
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
docstring-code-format = true

[tool.pytest]
testpaths = ["tests"]
pythonpath = ["src"]
addopts = [
    "--cov=myproject",
    "--cov-report=term-missing",
    "--cov-fail-under=80",
]

[tool.coverage.run]
branch = true
source = ["src/myproject"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "if __name__ == .__main__.:",
]
```

### Key Sections

| Section | Purpose |
|---------|---------|
| `[project]` | Core project metadata (PEP 621) |
| `[project.optional-dependencies]` | Optional runtime features (NOT dev tools) |
| `[project.scripts]` | Console entry points |
| `[build-system]` | Build backend configuration |
| `[dependency-groups]` | Development dependencies (PEP 735) |
| `[tool.uv]` | uv-specific configuration |
| `[tool.ruff]` | Ruff linting/formatting configuration |
| `[tool.pytest]` | Pytest configuration |
| `[tool.coverage]` | Coverage configuration |

### Dependency Groups (PEP 735)

```toml
[dependency-groups]
dev = [{include-group = "lint"}, {include-group = "test"}, {include-group = "audit"}]
lint = ["ruff", "ty"]
test = ["pytest", "pytest-cov"]
audit = ["pip-audit"]
docs = ["sphinx", "myst-parser"]
```

Install with: `uv sync --group dev --group test`

## Anti-Patterns to Avoid

| Avoid | Use Instead |
|-------|-------------|
| `[tool.ty]` python-version | `[tool.ty.environment]` python-version |
| `uv pip install` | `uv add` and `uv sync` |
| Editing pyproject.toml manually to add deps | `uv add <pkg>` / `uv remove <pkg>` |
| `hatchling` build backend | `uv_build` (simpler, sufficient for most cases) |
| Poetry | uv (faster, simpler, better ecosystem integration) |
| requirements.txt | PEP 723 for scripts, pyproject.toml for projects |
| mypy / pyright | ty (faster, from Astral team) |
| `[project.optional-dependencies]` for dev tools | `[dependency-groups]` (PEP 735) |
| Manual virtualenv activation | `uv run <cmd>` |
| pre-commit | prek (faster, no Python runtime needed) |

**Key principles:**
- Always use `uv add` and `uv remove` to manage dependencies
- Never manually activate or manage virtual environments—use `uv run` for all commands
- Use `[dependency-groups]` for dev/test/docs dependencies, not `[project.optional-dependencies]`

## uv Commands Reference

### Project Commands

| Command | Description |
|---------|-------------|
| `uv init` | Create new project (application) |
| `uv init --package` | Create distributable package with src/ layout |
| `uv init --lib` | Create library package |
| `uv init --script file.py` | Create script with PEP 723 metadata |

### Dependency Management

| Command | Description |
|---------|-------------|
| `uv add <pkg>` | Add dependency to project |
| `uv add <pkg> --group dev` | Add to dependency group |
| `uv add <pkg> --optional feature` | Add to optional dependency |
| `uv remove <pkg>` | Remove dependency |
| `uv lock` | Update lock file without installing |

### Environment Management

| Command | Description |
|---------|-------------|
| `uv sync` | Install dependencies (creates venv if needed) |
| `uv sync --all-groups` | Install all dependency groups |
| `uv sync --group dev` | Install specific group |
| `uv sync --frozen` | Install from lock file exactly |

### Running Code

| Command | Description |
|---------|-------------|
| `uv run <cmd>` | Run command in project venv |
| `uv run python script.py` | Run Python script |
| `uv run pytest` | Run pytest |
| `uv run --with pkg cmd` | Run with temporary dependency |

### Building & Publishing

| Command | Description |
|---------|-------------|
| `uv build` | Build wheel and sdist |
| `uv build --wheel` | Build wheel only |
| `uv publish` | Publish to PyPI |

### Ad-hoc Dependencies with `--with`

```bash
# Run Python with a temporary package
uv run --with requests python -c "import requests; print(requests.get('https://httpbin.org/ip').json())"

# Run a module with temporary deps
uv run --with rich python -m rich.progress

# Multiple packages
uv run --with requests --with rich python script.py
```

**When to use `--with` vs `uv add`:**
- `uv add`: Package is a project dependency (goes in pyproject.toml/uv.lock)
- `--with`: One-off usage, testing, or scripts outside a project context

## Ruff Configuration

### Basic Setup

```toml
[tool.ruff]
line-length = 100
target-version = "py311"
src = ["src"]

[tool.ruff.lint]
select = ["ALL"]
ignore = [
    "D",        # pydocstyle
    "COM812",   # trailing comma (formatter conflict)
    "ISC001",   # string concat (formatter conflict)
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
docstring-code-format = true
```

### Running Ruff

```bash
# Lint
uv run ruff check .
uv run ruff check --fix .        # Auto-fix
uv run ruff check --fix --unsafe-fixes .  # Including unsafe fixes

# Format
uv run ruff format .
uv run ruff format --check .     # Check only
```

### Rule Categories

| Code | Category | Description |
|------|----------|-------------|
| `E`, `W` | pycodestyle | Style errors and warnings |
| `F` | Pyflakes | Logical errors |
| `I` | isort | Import sorting |
| `N` | pep8-naming | Naming conventions |
| `D` | pydocstyle | Docstring conventions |
| `UP` | pyupgrade | Python upgrade suggestions |
| `B` | flake8-bugbear | Bug detection |
| `S` | flake8-bandit | Security issues |
| `A` | flake8-builtins | Built-in shadowing |
| `C4` | flake8-comprehensions | Comprehension improvements |
| `DTZ` | flake8-datetimez | Timezone-aware datetime |
| `T10` | flake8-debugger | Debugger statements |
| `T20` | flake8-print | Print statements |
| `PT` | flake8-pytest-style | Pytest style |
| `Q` | flake8-quotes | Quote consistency |
| `SIM` | flake8-simplify | Simplification suggestions |
| `TID` | flake8-tidy-imports | Import hygiene |
| `ARG` | flake8-unused-arguments | Unused arguments |
| `ERA` | eradicate | Commented-out code |
| `PL` | Pylint | Pylint rules |
| `RUF` | Ruff-specific | Ruff's own rules |
| `ANN` | flake8-annotations | Type annotation checks |

## Best Practices Checklist

- [ ] Use `src/` layout for packages
- [ ] Set `requires-python = ">=3.11"`
- [ ] Configure ruff with `select = ["ALL"]` and explicit ignores
- [ ] Use ty for type checking
- [ ] Enforce test coverage minimum (80%+)
- [ ] Use dependency groups instead of extras for dev tools
- [ ] Add `uv.lock` to version control
- [ ] Use PEP 723 for standalone scripts
