# Insecure Defaults Detection Reference

## Core Principle

Finds **fail-open** vulnerabilities where apps run insecurely with missing configuration. Distinguishes exploitable defaults from fail-secure patterns.

- **Fail-open (CRITICAL):** `SECRET = env.get('KEY') or 'default'` → App runs with weak secret
- **Fail-secure (SAFE):** `SECRET = env['KEY']` → App crashes if missing

## When to Use
- Security audits of production applications
- Configuration review of deployment files, IaC templates, Docker configs
- Code review of environment variable handling
- Pre-deployment checks for hardcoded credentials

## When NOT to Use
- Test fixtures, example/template files, development-only tools
- Documentation examples, build-time configuration
- Crash-on-missing behavior (fail-secure)

## Categories

### Fallback Secrets
**Vulnerable:** `os.environ.get('SECRET_KEY', 'dev-secret-key-123')`
**Secure:** `os.environ['SECRET_KEY']` (raises KeyError if missing)

### Default Credentials
**Vulnerable:** Hardcoded admin accounts created on first run
**Secure:** Admin credentials from environment variables

### Fail-Open Security
**Vulnerable:** `REQUIRE_AUTH = env.get(X, 'false')` — default is no auth
**Secure:** `REQUIRE_AUTH = env.get(X, 'true')` — default requires auth

### Weak Crypto
**Vulnerable:** MD5 for passwords, DES encryption, SHA1 for signatures
**Secure:** bcrypt/Argon2 for passwords, AES-GCM for encryption

### Permissive Access
**Vulnerable:** CORS `*`, permissions `0o666`, S3 `public-read` by default
**Secure:** Explicit configuration required, restrictive defaults

### Debug Features
**Vulnerable:** Stack traces in API responses, GraphQL introspection enabled
**Secure:** Generic errors to users, debug info to logs only

## Quick Verification Checklist

| Pattern | Verify | Skip if |
|---------|--------|---------|
| Fallback secrets | App starts without env var? Used in crypto? | Test fixtures, example files |
| Default credentials | Active in deployed config? | Disabled accounts, docs |
| Fail-open security | Default is insecure? | App crashes or default is secure |
| Weak crypto | Used for passwords/encryption/tokens? | Checksums, non-security hashing |
| Permissive access | Default allows unauthorized access? | Explicitly configured with justification |
| Debug features | Enabled by default? Exposed in responses? | Logging-only, not user-facing |

## Rationalizations to Reject

- "It's just a development default" → If it reaches production code, it's a finding
- "The production config overrides it" → Verify prod config exists; code-level vulnerability remains
- "This would never run without proper config" → Prove it with code trace
- "It's behind authentication" → Defense in depth; compromised session still exploits
- "We'll fix it before release" → Document now; "later" rarely comes
