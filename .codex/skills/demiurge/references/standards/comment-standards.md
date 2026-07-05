# Comment Standards

Rules for writing code comments. Applies to ALL modes.

## Core Principle

Comment the **why**, not the **what**. The code itself explains what it does through descriptive naming and structure. Comments explain the reasoning behind non-obvious decisions.

## Rules

### 1. Never Explain Standard Syntax

Do not write comments that explain what the code literally does.

**Bad:**
```python
# Increment counter by 1
counter += 1

# Loop through the array
for item in items:

# Check if value is greater than 0
if value > 0:
```

**Good:**
```python
counter += 1  # Retry tracking: starts at 0, max 3 attempts

for item in items:
    # Items are pre-sorted by priority; stable sort preserves insertion order

if value > 0:
    # API returns -1 on timeout; positive values indicate success
```

### 2. Code Is Documentation

Rely on highly descriptive variable and function names. The code itself should be readable enough that inline comments are rarely needed.

**Bad:**
```javascript
// Process the data
function pd(d) { ... }
```

**Good:**
```javascript
function parseUserExportData(csvContent) { ... }
```

### 3. Document Edge Cases and Workarounds

Explicitly comment any workarounds, hacks, or specific handling of edge cases. Explain why the edge case exists and how the logic mitigates it.

```python
# The API returns an empty string instead of null for deleted users.
# This is a documented API quirk, not a bug on our end.
# See: https://api.example.com/docs/users#deletion
user_name = response.get("name") or "Deleted User"
```

### 4. Public API Documentation

Use standard documentation formats for all public-facing functions, classes, and APIs:
- **JavaScript/TypeScript:** JSDoc
- **Python:** Docstrings (Google or NumPy style)
- **Java:** JavaDoc
- **Go:** godoc conventions
- **Rust:** `///` doc comments

Function documentation must state:
1. What the function achieves
2. Expected inputs (parameters)
3. Expected output (return value)
4. Potential exceptions/errors thrown

**Example (JSDoc):**
```javascript
/**
 * Validates a user session token against the auth service.
 *
 * @param {string} token - The JWT session token to validate.
 * @returns {Promise<ValidationResult>} Whether the token is valid and its expiry info.
 * @throws {AuthServiceUnavailableError} If the auth service is unreachable.
 */
async function validateSession(token) { ... }
```

### 5. No Redundant Metadata

Never include in comments:
- Version history or modification dates (use Git)
- Author names (use Git blame)
- "Last modified" timestamps
- "Changed by X on Y" tracking

### 6. No Dead Code

Do not leave commented-out code blocks. If code is no longer needed, remove it entirely. Version control preserves history.

**Bad:**
```javascript
// old approach, kept for reference
// function oldProcess(data) {
//     return data.map(transform).filter(valid);
// }
```

**Good:**
```javascript
// (nothing -- the old code is in git history)
```

### 7. Conciseness and Clarity

Keep comments brief and to the point. Place comments directly above the line or block they describe.

**Bad:**
```python
# This function is responsible for calculating the total price of the order
# including all applicable taxes and discounts. It was written to replace
# the old calculation method which did not handle edge cases properly.
def calculate_total(order):
```

**Good:**
```python
# Includes tax calculation and discount application.
# Replaced v2 calculator which missed edge cases on mixed-rate orders.
def calculate_total(order):
```

### 8. Marking Intentional Simplifications

When using the ponytail ladder to ship a simpler version, mark it with a `ponytail:` comment explaining the ceiling and upgrade path:

```python
# ponytail: global lock; per-account locks if throughput matters
lock = threading.Lock()
```

```typescript
// ponytail: O(n^2) scan; switch to index if dataset grows past 10k
const duplicates = items.filter(item => items.some(other => other.id === item.id && other !== item));
```

### 9. Avoid AI Slop in Comments

Apply the humanizer patterns to all comments:
- No significance inflation ("This crucial function...")
- No promotional language ("This elegant solution...")
- No filler ("It is important to note that...")
- No hedging ("This might potentially help...")
- No rule of three ("fast, reliable, and scalable")
- No AI vocabulary (delve, leverage, utilize, streamline, facilitate)
- No generic conclusions ("This approach provides a robust foundation...")
