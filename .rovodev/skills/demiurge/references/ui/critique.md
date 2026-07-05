# Critique Mode

UX design review with heuristic scoring, cognitive load assessment, and persona testing. Generates a structured critique report.

## Workflow

1. **Resolve the target** to a concrete file path or URL.
2. **Read the source files** and visually inspect when browser automation is available.
3. **Run two assessments** (A: design review, B: anti-pattern detection).
4. **Synthesize** into a single critique report.
5. **Ask the user** what to improve first.
6. **Recommend actions** based on their priorities.

## Assessment A: Design Review

Evaluate like a design director:

- **AI slop**: Would someone believe "AI made this"? Check all anti-patterns from SKILL.md base rules.
- **Holistic design**: hierarchy, IA, emotional fit, discoverability, composition, typography, color, accessibility, states, copy, edge cases.
- **Cognitive load**: 8-item checklist (single focus, chunking, grouping, visual hierarchy, one thing at a time, minimal choices, working memory, progressive disclosure). Count failures. 0-1 = low, 2-3 = moderate, 4+ = high.
- **Working memory**: At any decision point, count distinct options. <=4 manageable, 5-7 pushing it, 8+ overloaded.
- **Emotional journey**: peak-end rule, emotional valleys, reassurance at high-stakes moments.

## Assessment B: Anti-Pattern Detection

Scan for AI slop tells and design anti-patterns:

- Side-stripe borders, gradient text, glassmorphism
- Hero-metric template, identical card grids
- Tiny uppercase tracked eyebrows on every section
- Numbered section markers as default scaffolding
- Text overflowing containers
- Cream/sand/beige body background
- Gray text on colored backgrounds
- Nested cards, bounce easing

## Heuristics Scoring

Score each of Nielsen's 10 heuristics 0-4:

| # | Heuristic | What to check |
|---|-----------|--------------|
| 1 | Visibility of System Status | Loading indicators, confirmations, progress, location |
| 2 | Match System/Real World | Familiar terminology, logical order, recognizable icons |
| 3 | User Control and Freedom | Undo/redo, cancel, back, escape from traps |
| 4 | Consistency and Standards | Consistent terminology, same actions = same results |
| 5 | Error Prevention | Confirmation before destructive actions, constraints, smart defaults |
| 6 | Recognition Rather Than Recall | Visible options, contextual help, autocomplete, labels on icons |
| 7 | Flexibility and Efficiency | Keyboard shortcuts, bulk actions, power user features |
| 8 | Aesthetic and Minimalist Design | Only necessary info, clear hierarchy, no clutter |
| 9 | Error Recovery | Plain language errors, specific identification, actionable suggestions |
| 10 | Help and Documentation | Searchable, task-focused, concise, easy to access |

**Total:** /40. 36-40 excellent, 28-35 good, 20-27 acceptable, 12-19 poor, 0-11 critical.

## Persona Testing

Select 2-3 relevant personas:

- **Alex (Power User)**: Expert, expects efficiency, skips onboarding, finds shortcuts.
- **Jordan (First-Timer)**: Never used this, needs guidance, abandons rather than figures out.
- **Sam (Accessibility-Dependent)**: Screen reader, keyboard-only, needs ARIA and contrast.
- **Riley (Stress Tester)**: Tests edge cases, empty states, unexpected input.
- **Casey (Mobile User)**: One-handed, interrupted, slow connection, thumb zone.

Walk through the primary user action as each persona. Report specific red flags with exact elements and interactions.

## Severity Levels

- **P0 Blocking**: Prevents task completion. Fix immediately.
- **P1 Major**: Significant difficulty or WCAG AA violation. Fix before release.
- **P2 Minor**: Annoyance, workaround exists. Fix in next pass.
- **P3 Polish**: Nice-to-fix, no real user impact. Fix if time permits.

## Report Template

```markdown
# Critique Report

**Target:** [file/URL]
**Date:** [date]

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | ? | ... |
| ... | ... | ... | ... |
| **Total** | | **??/40** | |

## Anti-Patterns Verdict

Does this look AI-generated? List specific tells.

## What's Working

2-3 things done well. Be specific about why.

## Priority Issues

For each:
- **[P?] What**: Name the problem
- **Why it matters**: How this hurts users
- **Fix**: What to do about it

## Persona Red Flags

[per-persona findings]

## Minor Observations

## Questions to Consider
```

## Rules

- Be direct. Vague feedback wastes time.
- Be specific. "The submit button," not "some elements."
- Say what's wrong AND why it matters.
- Give concrete suggestions. Cut "consider exploring..." entirely.
- Prioritize ruthlessly. If everything is important, nothing is.
- Don't soften criticism.
