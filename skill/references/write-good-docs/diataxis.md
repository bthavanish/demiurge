# Diataxis Framework

A systematic approach to documentation based on two axes: **action vs cognition** and **acquisition vs application**. This produces four quadrants.

## The Compass

| If the content... | ...and serves the user's... | ...then it belongs to... |
| --- | --- | --- |
| informs action | acquisition of skill | a **Tutorial** |
| informs action | application of skill | a **How-to Guide** |
| informs cognition | application of skill | **Reference** |
| informs cognition | acquisition of skill | **Explanation** |

Two questions: *action or cognition?* *acquisition or application?*

---

## Tutorials (learning-oriented)

A tutorial is an **experience** that takes place under guidance. It is a lesson -- the student learns by doing something meaningful toward an achievable goal.

**Purpose:** Skill acquisition (study). Not to help the user get something done, but to help them learn.

**Obligations:**
- Meaningful -- the pupil needs a sense of achievement
- Successful -- the pupil needs to be able to complete it
- Logical -- the path through it needs to make sense
- Usefully complete -- encounter with all actions, concepts, and tools needed

### Key Principles

- **Show the learner where they're going.** Describe what they'll accomplish (not "you will learn...").
- **Deliver visible results early and often.** Every step produces a comprehensible result.
- **Maintain a narrative of the expected.** "You will notice that..." Keep feedback flowing.
- **Point out what the learner should notice.** Close the loops of learning by pointing things out.
- **Target the feeling of doing.** Tie purpose and action so they become a cradle for skill.
- **Encourage repetition.** Learners repeat exercises that give them success.
- **Ruthlessly minimise explanation.** A tutorial is not the place for explanation. Link to it instead.
- **Focus on the concrete.** One thing at a time, from concrete step to concrete step.
- **Ignore options and alternatives.** Stay focused on what's required to reach the conclusion.
- **Aspire to perfect reliability.** The tutorial must work for every user, every time.

### Language

- "We..." -- affirms tutor-learner relationship
- "In this tutorial, we will..." -- describe what learner will accomplish
- "First, do x. Now, do y." -- no room for ambiguity
- "The output should look something like..." -- clear expectations
- "Notice that..." / "Remember that..." -- orientation clues
- "You have built a..." -- describe what learner accomplished

---

## How-to Guides (goal-oriented)

How-to guides are **directions** that guide the reader through a problem or towards a result. They serve the user's **action** -- navigating real-world problem-fields.

**Purpose:** Help the user get something done, correctly and safely.

### Key Principles

- **Written from the user's perspective, not the machinery's.** Defined by user needs, not tool operations.
- **Address real-world complexity.** Adaptable to real use-cases, not just the narrow case described.
- **Omit the unnecessary.** Practical usability over completeness. Start and end in meaningful places.
- **Provide a set of instructions.** Executable solution: actions (physical acts, thinking, judgement).
- **Describe a logical sequence.** Ordering matters -- even when operations could go either way, consider setup and thinking flow.
- **Seek flow.** Ground sequences in user's activities and thinking. Anticipate the user.
- **Pay attention to naming.** "How to integrate X" (good) vs "Integrating X" (ambiguous).

### Language

- "This guide shows you how to..."
- "If you want x, do y." -- conditional imperatives
- "Refer to the x reference guide for..." -- don't pollute with every option

---

## Reference (information-oriented)

Reference material is **technical description** of the machinery and how to operate it. It contains propositional/theoretical knowledge for work.

**Purpose:** Describe, succinctly and in orderly way. Neutral, authoritative, like a map.

### Key Principles

- **Describe and only describe.** Neutral description is the key imperative. No instruction, explanation, or opinion.
- **Adopt standard patterns.** Consistency is what makes reference useful. Place material where users expect it.
- **Respect the structure of the machinery.** Documentation structure should mirror product structure.
- **Provide examples.** Examples illustrate without falling into explanation or instruction.

### Language

- "Django's default logging..." -- state facts
- "Sub-commands are: a, b, c..." -- list commands, options, features
- "You must use a. You must not apply b unless c." -- warnings where appropriate

---

## Explanation (understanding-oriented)

Explanation is a discursive treatment that permits **reflection**. It deepens and broadens understanding, bringing clarity, light, and context.

**Purpose:** Weave a web of understanding. Documentation that makes sense to read away from the product.

### Key Principles

- **Make connections.** Connect to other things, even outside the immediate topic.
- **Provide context.** Why things are so -- design decisions, historical reasons, technical constraints.
- **Talk about the subject.** The bigger picture, history, choices, alternatives, why.
- **Admit opinion and perspective.** Explanation can and must consider alternatives and contrary opinions.
- **Keep explanation bounded.** Don't let instruction or reference creep in.

### Language

- "The reason for x is because..." -- explain
- "W is better than z, because..." -- offer judgements
- "An x in system y is analogous to..." -- provide context
- "Some users prefer w (because z)..." -- weigh alternatives

---

## Using Diataxis in Practice

### The Compass in Action

Use the compass when you're unsure what form documentation should take. Ask: *action or cognition?* *acquisition or application?*

Apply close-up (sentences, words) or wide (entire documents).

### Iterative Improvement

1. **Choose something** -- any piece of documentation.
2. **Assess it** -- what user need does it serve? How well?
3. **Decide** -- what single next action produces immediate improvement?
4. **Do it** -- complete and commit.
5. Repeat.

### Rules

- Use Diataxis as a **guide**, not a plan. It's a map, not a blueprint.
- Don't worry about structure. Structure emerges from improving content.
- Work one step at a time. Every step in the right direction is worth publishing.
- Don't try to work on the big picture. Small steps arrive where you want to go.
- Allow organic growth. Well-formed organic growth that adapts to external conditions.
- Documentation is never finished, but always complete -- useful, appropriate, structurally healthy.
