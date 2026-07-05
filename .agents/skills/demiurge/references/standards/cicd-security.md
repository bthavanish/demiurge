# CI/CD and Agentic Security

Security audit guidance for CI/CD pipelines, GitHub Actions workflows, and AI agent integrations. Covers prompt injection, supply chain, secrets exposure, and runtime risks.

## When to Use

- Auditing GitHub Actions workflows
- Reviewing CI/CD configurations for security
- Checking AI agent integrations (Claude Code Action, Gemini CLI, OpenAI Codex, GitHub AI Inference)
- Assessing dependency supply chain risks
- Reviewing Docker/container configurations

## When NOT to Use

- Application-level security (use `references/backend/secure-code.md`)
- Infrastructure-as-code (Terraform, CloudFormation) -- separate domain

## GitHub Actions Security

### Dangerous Triggers

| Trigger | Risk | Severity |
|---------|------|----------|
| `pull_request_target` | Runs in base branch with secrets. External PRs can trigger. | P0 |
| `issue_comment` | Comment body is attacker-controlled input. | P1 |
| `issues` | Issue body/title is attacker-controlled input. | P1 |
| `workflow_dispatch` | Input values are user-controlled. | P2 |
| `workflow_run` | Previous workflow output may be attacker-controlled. | P2 |

### Script Injection

Direct expression injection in `run:` blocks:

```yaml
# VULNERABLE: expression in run block
- run: echo "${{ github.event.issue.title }}"

# SAFE: use env var
- run: echo "$ISSUE_TITLE"
  env:
    ISSUE_TITLE: ${{ github.event.issue.title }}
```

### AI Agent Security

When workflows invoke AI coding agents, attacker-controlled input can reach the agent through three paths:

**Path 1 -- Direct injection:**
```
github.event.*.body -> ${{ }} in prompt -> AI processes attacker text
```

**Path 2 -- Env var intermediary:**
```
github.event.*.body -> env: VAR: ${{ }} -> prompt reads $VAR -> AI processes attacker text
```
The prompt field contains zero `${{ }}` expressions. Invisible to naive grep tools.

**Path 3 -- Runtime fetch:**
```
github.event.*.number -> gh issue view N -> API returns attacker body -> AI processes attacker text
```
Attacker content is not in the YAML at all.

### AI Action Detection Matrix

| Action | Prompt Fields | Dangerous Configs |
|--------|--------------|-------------------|
| `anthropics/claude-code-action` | `with.prompt`, `with.claude_args` | `Bash(*)`, `allowed_non_write_users: "*"`, `show_full_output: true` |
| `google-github-actions/run-gemini-cli` | `with.prompt`, `with.settings` | `"sandbox": false`, `--yolo`, `run_shell_command(echo)` in tools |
| `openai/codex-action` | `with.prompt`, `with.prompt-file` | `sandbox: danger-full-access`, `safety-strategy: unsafe`, `allow-users: "*"` |
| `actions/ai-inference` | `with.prompt`, `with.system-prompt` | Overly scoped token, AI output in `eval` |

### Attack Vectors (A-I)

| Vector | Name | Detection |
|--------|------|-----------|
| A | Env Var Intermediary | `env:` with `${{ github.event.* }}` + prompt reads that env var |
| B | Direct Expression Injection | `${{ github.event.* }}` inside prompt field |
| C | CLI Data Fetch | `gh issue view`, `gh pr view` in prompt text |
| D | PR Target + Checkout | `pull_request_target` + checkout with `ref:` to PR head |
| E | Error Log Injection | CI logs/error output passed to AI prompt |
| F | Subshell Expansion | Tool list allows `$()` expandable commands |
| G | Eval of AI Output | `eval`/`exec` consuming AI step outputs |
| H | Dangerous Sandbox | `danger-full-access`, `Bash(*)`, `--yolo` |
| I | Wildcard Allowlists | `allow-users: "*"`, `allowed_non_write_users: "*"` |

### Remediation

**Restrict shell access:**
```yaml
# Claude: specific tool patterns
claude_args: '--allowedTools "Bash(npm test:*) Bash(git diff:*)"'

# Codex: safe sandbox
sandbox: workspace-write

# Gemini: remove expandable tools
settings: '{"tools": {"core": ["read_file", "write_file"]}}'
```

**Restrict user access:**
```yaml
allowed_non_write_users: "trusted-user1,trusted-user2"
allow-users: "maintainer1,maintainer2"
```

**Protect AI output:**
```yaml
# DANGEROUS
- run: eval "${{ steps.ai.outputs.result }}"

# SAFE
- run: echo "${{ steps.ai.outputs.result }}"  # display only
```

## Supply Chain Security

### Dependency Risks

- **Typosquatting:** Packages named similar to popular ones
- **Dependency confusion:** Internal package names exposed in public registries
- **Compromised maintainer:** Trusted package updated with malicious code
- **Transitive dependencies:** Vulnerabilities in deep dependency trees

### Detection

```bash
# Node.js
npm audit
yarn audit

# Python
pip-audit
safety check

# Rust
cargo audit

# Go
govulncheck ./...

# Java
mvn org.owasp:dependency-check-maven:check
```

### Docker Security

- Pin base images to specific versions (not `:latest`)
- Use multi-stage builds to reduce attack surface
- Run as non-root user
- Scan images with `trivy`, `snyk`, or `grype`

## Permissions Best Practices

- Use `permissions:` block in every workflow
- Grant minimum required permissions
- Use `permissions: {}` to start with no permissions
- Never use `permissions: write-all` or `permissions: all`

```yaml
# SAFE: minimal permissions
permissions:
  contents: read
  pull-requests: write  # only if needed
```

## Audit Script

Use `scripts/security/audit-github-actions.sh` for automated detection:

```bash
bash scripts/security/audit-github-actions.sh /path/to/repo
```

Checks: dangerous triggers, script injection, AI agent actions, supply chain, permissions.
