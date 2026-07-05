# Supply Chain Risk Auditor Reference

## Risk Criteria

A dependency is high-risk if it has ANY of these factors:

### Single Maintainer
Project maintained by one individual or small team, not an organization. Anonymous maintainers = significantly greater risk. Prolific known contributors (sindresorhus, Drew Devault) = lessened but not eliminated risk.

**Justification:** Bribery/phishing of one person can push malicious code.

### Unmaintained
Stale (no updates for long period), deprecated/archived, or seeking maintainers. Large number of unresponded issues.

**Justification:** Vulnerabilities may not be patched timely.

### Low Popularity
Fewer GitHub stars/downloads compared to similar dependencies.

**Justification:** Fewer eyes on the project; malicious code won't be noticed quickly.

### High-Risk Features
Implements FFI, deserialization, or third-party code execution.

**Justification:** Key to target's security posture; needs high scrutiny.

### Presence of Past CVEs
High/critical severity CVEs, especially large number relative to popularity.

**Justification:** Not necessarily concerning for very popular projects subject to more scrutiny.

### Absence of Security Contact
No security contact in SECURITY.md, CONTRIBUTING.md, README.md, or project website.

**Justification:** Discoverers cannot report vulnerabilities safely/timely.

## Workflow

### Initial Setup
1. Create `.supply-chain-risk-auditor` directory
2. Start `results.md` from results-template
3. Find all git repositories for direct dependencies
4. Normalize repository entries to URLs

### Dependency Audit
1. Evaluate each dependency against risk criteria
2. Use `gh` tool for exact data (stars, issues, etc.)
3. Add high-risk dependencies to results table with reasons

### Post-Audit
1. Suggest alternatives for each high-risk dependency
2. Note counts by risk factor category
3. Summarize recommendations

## Report Template

```markdown
# Supply Chain Risk Report

## Metadata
- Scan Date, Project, Repositories Scanned, Total Dependencies

## Executive Summary
### Counts by Risk Factor
| Risk Factor | Dependencies | Total |
|-------------|--------------|-------|

### High-Risk Dependencies
| Dependency | Risk Factors | Notes | Suggested Alternative |
|------------|--------------|-------|-----------------------|
```

## Prerequisites

Ensure `gh` tool is available. Required for querying GitHub data (stars, issues, maintainers).
