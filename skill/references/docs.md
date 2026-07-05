# Documentation Reference

Diataxis framework, README writing, and AI trope detection for prose.

---

## Diataxis Framework

Four documentation types based on two axes: action vs cognition, acquisition vs application.

| Content informs... | User's... | Type |
|---|---|---|
| Action | Skill acquisition | Tutorial |
| Action | Skill application | How-to Guide |
| Cognition | Skill application | Reference |
| Cognition | Skill acquisition | Explanation |

### Tutorials (learning-oriented)

Lesson where student learns by doing. Must be meaningful, successful, logical, and usefully complete.

Rules: show where they're going, deliver visible results early, maintain narrative of the expected, ruthlessly minimise explanation, focus on the concrete, ignore alternatives.

Language: "We...", "In this tutorial, we will...", "First, do x. Now, do y.", "Notice that...", "You have built a..."

### How-to Guides (goal-oriented)

Directions guiding through a real problem. Written from user's perspective, address real-world complexity, omit unnecessary, provide executable instructions.

Language: "This guide shows you how to...", "If you want x, do y."

### Reference (information-oriented)

Technical description. Neutral, authoritative, like a map. Describe and only describe. Adopt standard patterns. Respect machinery structure. Provide examples.

### Explanation (understanding-oriented)

Discursive treatment for reflection. Make connections, provide context, talk about the subject, admit opinion, keep bounded.

---

## README Writing

Core principle: READMEs answer questions your audience will have. Different audiences need different information.

### Project Types

| Type | Audience | Key Sections |
|---|---|---|
| Open Source | Contributors, users | Install, Usage, Contributing, License |
| Personal | Future you, portfolio | What it does, Tech stack, Learnings |
| Internal | Teammates, new hires | Setup, Architecture, Runbooks |
| Config | Future you (confused) | What's here, Why, How to extend, Gotchas |

### Essential Sections (All Types)

1. **Name** -- Self-explanatory title
2. **Description** -- What + why in 1-2 sentences
3. **Usage** -- How to use it (examples help)

### Common Mistakes

- No install steps -- never assume setup is obvious
- No examples -- show, don't just tell
- Wall of text -- use headers, tables, lists
- Stale content -- add "last reviewed" date
- Generic tone -- write for YOUR audience

### After Drafting

Ask: "Anything else to highlight or include that I might have missed?"

---

## AI Writing Trope Detection

Catalog of AI writing patterns that make text feel machine-generated. Any single pattern used once might be fine. The problem is when multiple tropes appear together or one repeats throughout a piece.

### Word Choice

Overused vocabulary: "quietly", "delve", "tapestry", "landscape", "serves as", "leverage", "robust", "harness", "streamline", "utilize".

Fix: use plain words. "Look at", "use", "strong", "simplify".

### Sentence Structure

- **Negative parallelism** ("not X -- it's Y"): most common AI tell. State the point directly.
- **Dramatic countdown** ("Not X. Not Y. Just Z."): lead with the point.
- **Self-posed rhetorical questions** ("The result? Devastating."): merge into a statement.
- **Anaphora abuse** (repeating sentence openings): vary openings, combine points.
- **Tricolon abuse** (rule-of-three overuse): use two items or five, break rhythm.
- **Gerund fragment litany** (verbless fragments after a claim): use real sentences or cut.

### Paragraph Structure

- **Short punchy fragments**: excessive standalone short sentences. Combine into real paragraphs.
- **Listicle in a trench coat**: numbered points disguised as prose. Either flow or format as list.

### Tone

- **False suspense** ("Here's the kicker"): drop the windup, state the point.
- **Patronizing analogies** ("Think of it as..."): explain the actual thing.
- **False vulnerability**: if you have a bias, show it through arguments, don't announce it.
- **Grandiose stakes inflation**: match language to actual stakes.
- **Vague attributions** ("Experts argue..."): name the source or drop it.
- **Invented concept labels** ("the supervision paradox"): describe the phenomenon instead.

### Formatting

- **Em-dash addiction**: use commas, parentheses, or separate sentences. Reserve for 1-2 genuine uses.
- **Bold-first bullets**: write list items as normal sentences.
- **Unicode decoration**: use `->`, `=>`, or straight quotes.

### Composition

- **Fractal summaries**: trust readers to remember. Summarize only for executive needs.
- **Dead metaphor**: use a metaphor once or twice, then let it go.
- **Historical analogy stacking**: pick one example, go deep.
- **One-point dilution**: state the point, support it, move on.
- **Signposted conclusion**: just write the final thought.

### Quick Self-Check

Before delivering prose:
- Same sentence structure more than twice in a row?
- Used "not X -- it's Y" or "Here's the thing" anywhere?
- Stacked three or more historical examples back-to-back?
- Inflated stakes beyond what content warrants?
- Would a human write a first draft this way?
- Does any passage sound like a motivational poster?
