# Humanize Mode

Audit code for AI-generated patterns and rewrite them to sound human. Based on the humanizer skill's detection of 33 AI writing patterns, applied to code artifacts.

## What This Mode Audits

### Code-Level AI Patterns

1. **Unnecessary abstractions.** Interface with one implementation. Factory for one product. Config for a value that never changes. Adapter wrapping a single adapter. Strategy pattern for two options.
   - Fix: Inline the abstraction. Use a function or a constant.

2. **Boilerplate scaffolding.** "For later" infrastructure that nothing uses. Empty base classes. Generic utility functions with one caller. Abstract factories before there are multiple products.
   - Fix: Delete it. Let later handle later.

3. **Over-documentation.** Comments that explain what the code does line by line. JSDoc on private functions. Docstrings on trivial getters. README sections for self-explanatory code.
   - Fix: Remove what-the-code-does comments. Keep why comments only where the reasoning is non-obvious.

4. **Performative naming.** Variables named for what they represent conceptually rather than what they hold. `userPreferencesManager` for a function that reads one config value. `DataProcessingPipeline` for a map-filter chain.
   - Fix: Name for what it does, not what it means.

5. **Template patterns.** Identical error handling across functions. Copy-pasted validation blocks. Synchronized try-catch structures where each branch does something different.
   - Fix: Extract the common handling into a shared function, or remove the ceremony if the branches are actually different.

6. **Defensive over-engineering.** Try-catch wrapping everything "just in case." Null checks on values that cannot be null by construction. Type guards on values already typed. Validation on internal functions that only receive validated input.
   - Fix: Trust the type system. Validate at boundaries, not everywhere.

7. **Import-everything patterns.** Importing entire libraries when only one function is used. Barrel imports from index files. Re-exporting everything.
   - Fix: Import what you use. No barrel files.

8. **Config proliferation.** Separate config files for values that never change. Environment variable reads for constants. Feature flags for permanent features.
   - Fix: Inline the value. Make it a constant.

9. **Circular type definitions.** Types that reference each other. Generic types that wrap other generic types. Type gymnastics where a simple interface suffices.
   - Fix: Flatten. Use simple, direct types.

10. **Generic utility functions.** Custom implementations of `groupBy`, `sortBy`, `uniqueBy`, `clamp` that add no value over a one-liner or stdlib.
    - Fix: Use stdlib. Write the one-liner.

### Comment-Level AI Patterns

Apply all 33 humanizer patterns to comments and documentation. The patterns below are grouped by category.

#### Content Patterns

11. **Significance inflation.** "This crucial function..." "The important role of..." "Underscores the significance..."
    - Watch for: stands/serves as, is a testament/reminder, a vital/significant/crucial/pivotal/key role/moment, underscores/highlights, reflects broader, symbolizing, setting the stage for, marking/shaping, represents a shift, key turning point, evolving landscape, focal point, indelible mark
    - Fix: State what it does. Drop the commentary about why it matters.

12. **Undue emphasis on notability.** Citing sources without context. Listing credentials instead of making a point.
    - Watch for: independent coverage, local/regional/national media outlets, written by a leading expert, active social media presence
    - Fix: If you cite a source, say what it said. Otherwise don't cite it.

13. **Superficial -ing analyses.** Tacking present participle phrases onto sentences for fake depth.
    - Watch for: highlighting/underscoring/emphasizing, ensuring, reflecting/symbolizing, contributing to, cultivating/fostering, encompassing, showcasing
    - Fix: Say what it does, not what it symbolizes.

14. **Promotional language.** Sales-y adjectives. Hyperbole. Breathless enthusiasm.
    - Watch for: boasts a, vibrant, rich (figurative), profound, enhancing, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking (figurative), renowned, breathtaking, must-visit, stunning
    - Fix: Use plain descriptors. State facts, not vibes.

15. **Vague attributions.** Citing unnamed experts or unspecified sources.
    - Watch for: Industry reports, Observers have cited, Experts argue, Some critics argue, several sources/publications
    - Fix: Name the source or drop the claim.

16. **Outline-like "Challenges" sections.** Formulaic "Despite X, Y faces challenges..." paragraphs.
    - Watch for: Despite its... faces several challenges..., Despite these challenges, Challenges and Legacy, Future Outlook
    - Fix: State specific challenges with specifics. Drop the template.

#### Language and Grammar Patterns

17. **AI vocabulary.** High-frequency words that appear far more in post-2023 text.
    - Watch for: actually, additionally, align with, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract noun), pivotal, showcase, tapestry (abstract noun), testament, underscore (verb), valuable, vibrant
    - Fix: Replace with simpler words. "Crucial" -> "important" or just cut it.

18. **Copula avoidance.** Substituting elaborate constructions for simple "is/are".
    - Watch for: serves as/stands as/marks/represents, boasts/features/offers
    - Fix: Use "is", "has", "does".

19. **Negative parallelisms and tailing negations.** "Not only...but..." or "It's not just about..., it's..." overuse. Clipped negation fragments tacked onto sentences.
    - Watch for: Not only...but, It's not just..., no [noun] at end of sentence
    - Fix: State the positive directly. Expand negation fragments into clauses.

20. **Rule of three.** Forcing ideas into groups of three to appear comprehensive.
    - Fix: Use however many items there actually are. Two is fine. Four is fine.

21. **Elegant variation.** Cycling through synonyms for the same thing.
    - Fix: Pick one name and stick with it.

22. **False ranges.** "From X to Y" where X and Y aren't on a meaningful scale.
    - Fix: List the things directly.

23. **Passive voice and subjectless fragments.** Hiding the actor or dropping the subject.
    - Watch for: "No configuration file needed", "The results are preserved automatically"
    - Fix: Use active voice with explicit subjects.

#### Style Patterns

24. **Em dashes.** The most reliable AI tell. Replace with periods, commas, colons, or parentheses.
    - Rule: Zero em dashes (—) and en dashes (–) in the final output. Also catch spaced em dashes (` — `) and double hyphens (` -- `).

25. **Overuse of boldface.** Mechanical bolding of terms.
    - Fix: Remove bold unless it serves a real purpose (defining a term, UI label).

26. **Inline-header vertical lists.** Lists where items start with bolded headers followed by colons.
    - Fix: Write prose instead of faux-definition lists.

27. **Title case in headings.** Capitalizing all main words.
    - Fix: Use sentence case.

28. **Emojis.** Decorating headings or bullets with emojis.
    - Fix: Remove. Use words instead.

29. **Curly quotation marks.** Using smart quotes where straight quotes belong.
    - Fix: Use straight quotes ("...").

#### Communication Patterns

30. **Collaborative artifacts.** Chatbot pleasantries pasted as content.
    - Watch for: I hope this helps, Of course!, Certainly!, You're absolutely right!, Would you like..., Want me to..., let me know
    - Fix: Remove all of it.

31. **Knowledge-cutoff disclaimers.** "As of [date]...", "Based on available information..."
    - Watch for: as of [date], Up to my last training update, While specific details are limited, based on available information, not publicly available, maintains a low profile, prefers to stay out of the spotlight
    - Fix: State what you know. Say what you don't know briefly. Don't dress a guess as fact.

32. **Sycophantic tone.** Overly positive, people-pleasing language.
    - Watch for: Great question!, You're absolutely right!, That's an excellent point!
    - Fix: Just make the point.

33. **Filler phrases.** Wordy constructions that say nothing.
    - Watch for: In order to achieve this goal, Due to the fact that, At this point in time, In the event that, The system has the ability to, It is important to note that
    - Fix: "To achieve this", "Because", "Now", "If", "The system can", cut entirely.

34. **Excessive hedging.** Over-qualifying statements.
    - Watch for: could potentially possibly, might have some effect, it could be argued
    - Fix: State your position. Hedging is fine; stacking hedges is not.

35. **Generic positive conclusions.** Vague upbeat endings.
    - Watch for: The future looks bright, Exciting times lie ahead, This represents a major step
    - Fix: End with a concrete next step or a specific fact.

36. **Hyphenated word pair overuse.** Uniform hyphenation of compound adjectives.
    - Watch for: third-party, cross-functional, client-facing, data-driven, decision-making, well-known, high-quality, real-time, long-term, end-to-end
    - Fix: Hyphenate attributive position only. Drop hyphens after the noun.

37. **Persuasive authority tropes.** Pretending to cut through noise to a deeper truth.
    - Watch for: The real question is, at its core, in reality, what really matters, fundamentally, the deeper issue, the heart of the matter
    - Fix: Just state the point.

38. **Signposting and announcements.** Announcing what you're about to do instead of doing it.
    - Watch for: Let's dive in, let's explore, let's break this down, here's what you need to know, without further ado
    - Fix: Do the thing. Don't announce it.

39. **Fragmented headers.** A heading followed by a one-line restatement of the heading.
    - Fix: Delete the restatement. Let the heading lead directly into content.

40. **Diff-anchored writing.** Writing comments as if narrating a change rather than describing the current state.
    - Watch for: "This function was added to replace...", "This was changed because..."
    - Fix: Describe what it does now. Changelogs are for changelogs.

41. **Manufactured punchlines.** Stacking short declarative fragments for manufactured drama.
    - Fix: One emphatic sentence is fine. Three in a row is a pattern.

42. **Aphorism formulas.** Turning claims into reusable pseudo-profound statements.
    - Watch for: X is the Y of Z, X becomes a trap, X is not a tool but a mirror, the language of, the currency of
    - Fix: State the concrete claim.

43. **Conversational rhetorical openers.** Fake-candid hooks before ordinary points.
    - Watch for: Honestly?, Look, Here's the thing, The thing is, Let's be honest, Real talk
    - Fix: Just say the thing.

### Variable and Function Name Patterns

- Generic suffixes: `Manager`, `Handler`, `Processor`, `Service`, `Factory` when the thing does one job
- Prefix patterns: `doX`, `handleX`, `processX` that add no meaning
- Abstract nouns: `facilitator`, `orchestrator`, `coordinator` for things with one caller
- Hungarian notation in languages that do not need it

## Detection Guidance

### What NOT to flag (false positives)

- Perfect grammar and consistent style. Many writers are professionals.
- Mixed casual and formal registers. Often a person in a technical field.
- Formal or academic vocabulary. AI overuses *specific* words, not all fancy words.
- Common transition words in isolation. One "however" is not a tell.
- Correct, complex formatting. Visual editors and templates produce clean output.
- Unsourced claims. Most of the web is unsourced.

When in doubt, look for **clusters** of tells, not isolated ones.

### Signs of human writing (preserve these)

- Specific, unusual, hard-to-fabricate detail
- Mixed feelings and unresolved tension
- Dated, era-bound references
- Variety in sentence length
- Genuine asides, parentheticals, or self-corrections

## Workflow

1. **Scan code.** Read every source file. Identify instances of the patterns above.

2. **Classify findings.** Group by pattern type. Count instances.

3. **Fix.** Rewrite each instance to sound human. Apply the ponytail ladder: can it be deleted? Simplified? Inlined?

4. **Report.** Output findings and fixes.

## Report Template

```markdown
# Humanize Report

**Date:** [date]
**Files scanned:** [count]

## AI Patterns Found

| Pattern | Instances | Files affected |
|---------|-----------|----------------|
| Unnecessary abstractions | [n] | [files] |
| Boilerplate scaffolding | [n] | [files] |
| Over-documentation | [n] | [files] |
| Performative naming | [n] | [files] |
| Template patterns | [n] | [files] |
| Defensive over-engineering | [n] | [files] |
| Import-everything | [n] | [files] |
| Config proliferation | [n] | [files] |
| Circular types | [n] | [files] |
| Generic utilities | [n] | [files] |
| AI comment patterns (33 patterns) | [n] | [files] |
| AI name patterns | [n] | [files] |
| **Total** | **[n]** | |

## Fixes Applied

| # | File | Pattern | Before | After |
|---|------|---------|--------|-------|
| 1 | path/file:line | [pattern] | [what it was] | [what it is now] |
```

## Rules

- Fix every instance. Do not just report.
- Preserve functionality. The rewrite must behave identically.
- Apply the ponytail ladder to each fix: delete > simplify > inline > refactor.
- No em dashes in comments or documentation.
- Comment the why, not the what.
