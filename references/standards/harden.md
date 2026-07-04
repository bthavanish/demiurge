# Harden Mode

Production-readiness: error handling, i18n, text overflow, edge cases.

## Checklist

### Error Handling
- Every async operation has error handling
- User-facing errors explain what happened in plain language
- Developer errors include technical cause
- No swallowed exceptions (empty catch blocks)
- Resources cleaned up in error paths (finally, defer, try-with-resources)
- Network calls have timeouts
- Retries have max attempts

### Internationalization (i18n)
- All user-facing strings extracted to translation files
- No hardcoded strings in templates/components
- Date/time formatting uses locale-aware APIs
- Number formatting uses locale-aware APIs
- Text expansion accounted for (German 30% longer than English)
- RTL layout support if needed

### Text Overflow
- Test every heading and paragraph at narrow viewports
- Long words wrapped with `overflow-wrap: break-word`
- Truncation with ellipsis where appropriate
- No text clipping at any breakpoint

### Edge Cases
- Empty states with helpful guidance
- Loading states with appropriate indicators
- Boundary values (0, max, negative, overflow)
- Concurrent access / race conditions
- Network failure graceful degradation
- Invalid user input handling
- Session expiry handling

### Security
- Input validation at all trust boundaries
- Output encoding for HTML, CSS, JS contexts
- CSRF protection on state-changing operations
- Rate limiting on sensitive endpoints
- No secrets in client-side code
- Secure headers (CSP, X-Frame-Options, etc.)

### CI/CD Security
- GitHub Actions: no `pull_request_target` with PR head checkout
- GitHub Actions: no `${{ github.event.* }}` in `run:` blocks (script injection)
- GitHub Actions: `permissions:` block with minimum required permissions
- GitHub Actions: no wildcard user/bot allowlists
- GitHub Actions: AI agent prompts do not receive attacker-controlled input
- Dependencies: no known CVEs (`npm audit`, `pip-audit`, `cargo audit`)
- Docker: pinned base images, non-root user, multi-stage builds

### Resilience
- Circuit breaker for external services
- Graceful degradation when dependencies fail
- Health check endpoints
- Structured logging at boundaries
- Metrics for critical operations

## Output

List every hardening change made, grouped by category. If the codebase was already production-ready, say so.
