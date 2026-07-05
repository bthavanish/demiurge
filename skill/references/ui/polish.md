# Polish Mode

Final quality pass. Catches the small details that separate good work from great work.

## Workflow

1. **Design system discovery.** Find existing design tokens, component libraries, style guides. Note conventions. Identify drift and classify root cause:
   - Missing token: the system doesn't have what we need
   - One-off implementation: someone built custom instead of using the system
   - Conceptual misalignment: the system's abstraction doesn't match the need

2. **Pre-polish assessment.** Review completeness:
   - Is it functionally complete? (Don't polish half-built features)
   - What's the quality bar? (MVP vs flagship)
   - Experience-first thinking: Who actually uses this, and what's the best possible experience for them? Effective design beats decorative polish.
   - Triage cosmetic vs functional. Functional issues first.

3. **Systematic polish.** Work through every dimension below.

4. **Final verification.** Re-check at multiple viewport sizes. Run the polish checklist.

5. **Clean up.** Replace custom implementations with design system components. Remove orphaned code. Consolidate tokens. Verify DRYness.

## Polish Dimensions

### Information Architecture and Flow
- Progressive disclosure: hide advanced options behind progressive reveal
- Established user flows: follow patterns the user already knows
- Hierarchy and complexity: match information density to user expertise
- Empty/loading/arrival transitions: what the user sees at each state
- Naming and mental model: labels match how users think about the task

### Visual Alignment and Spacing
- Pixel-perfect alignment to grid
- Consistent spacing (no random 13px gaps)
- Optical alignment for visual weight
- Responsive consistency across breakpoints

### Typography
- Hierarchy consistency (same elements, same sizes/weights)
- Line length: 45-75 characters for body text
- Appropriate line height for font size
- `text-wrap: balance` on headings
- `text-wrap: pretty` on long prose

### Color and Contrast
- Body text >= 4.5:1 against background
- Large text >= 3:1
- Placeholder text same 4.5:1 requirement
- Gray text on colored background: use darker shade of background's hue
- No washed-out muted gray on tinted near-white

### Interaction States
- Default, hover, focus, active, disabled for every interactive element
- Loading states for async operations
- Error states with clear messaging
- Empty states with guidance

### Micro-interactions and Transitions
- Smooth transitions between states (no jank)
- Consistent easing across the interface
- Reduced motion: respect `prefers-reduced-motion`
- Transitions serve a purpose (feedback, orientation), not decoration

### Content and Copy
- Consistent voice and tone
- No orphaned words in headings
- Error messages explain what happened and what to do
- Button labels are action-oriented

### Icons and Images
- Consistent icon style (outline or filled, not mixed)
- Appropriate sizing and alignment
- Alt text for meaningful images
- Loading states for lazy-loaded images
- Retina support (@2x assets)

### Forms and Inputs
- Labels on every input
- Inline validation (not just on submit)
- Clear required indicators
- Appropriate input types (email, tel, url, date)
- Autocomplete attributes

### Edge Cases
- Long text truncation or wrapping
- Empty states
- Loading states
- Error states
- Very short text
- RTL text if applicable
- Special characters

### Responsive Behavior
- Works at every breakpoint
- Touch targets >= 44x44px
- No horizontal scroll on mobile
- Content reflows appropriately

### Performance
- Images optimized and lazy-loaded
- No layout shift from unsized elements
- No render-blocking resources

### Code Quality
- No console.log statements
- No commented-out code
- Consistent naming conventions
- No unused imports or variables

## Amplifying Bland Designs

Use when a design is safe to the point of forgettable. Amplify within the existing design system -- do not create a new one.

### Register Awareness
- **Brand context:** Stronger brand presence, more distinctive visual identity, larger brand color surfaces, bolder typography for headlines, more personality in motion.
- **Product context:** Stronger hierarchy, clearer weight contrast, sharper information density, more decisive interactive states. Product bolder builds trust through clarity, not spectacle.

### Process
1. Assess current state. Diagnose specific weaknesses, not general vibes.
2. Lock to design system. Stay within existing tokens.
3. Plan amplification. Pick one focal point to push hardest.
4. Set risk budget. Amplification that breaks recognition is failure.

### Amplification Levers
- **Color:** Push primary color higher on commitment axis. Use brand color at larger surfaces. Increase contrast. Add a deliberate accent.
- **Typography:** Increase heading size. Tighten letter-spacing on display text. Use weight contrast more aggressively. Break grid with oversized type for focal points.
- **Spacing:** Increase white space around focal elements. Use asymmetric spacing for visual tension.
- **Motion:** Add entrance animations that build anticipation. Staggered reveals for lists. Micro-interactions on hover/click.
- **Composition:** One dominant element. Scale contrast. Break symmetry deliberately. Add depth through elevation.

### Anti-Patterns
- Scroll-fade-rise on every section (the saturated AI default).
- Decorative motion without purpose.
- New color palette. Bolder within the system, not a new system.
- Everything is the focal point. Pick one thing.
- Bolder means bigger. Sometimes it means tighter, sharper, denser.

## Toning Down Aggressive Designs

Use when a design is overstimulating. Reduce visual noise while preserving intent.

### Intensity Diagnostic

| Source | Signal | Fix |
|--------|--------|-----|
| Color saturation | Fully saturated backgrounds, competing accents | Desaturate to 70-85%, use tinted grays |
| Contrast extremes | Very dark on very light, harsh borders | Soften contrast, reduce border weight |
| Visual weight | Heavy fonts, thick borders, large icons | Reduce font weights, thin borders, smaller icons |
| Animation excess | Entrance animations on every section, parallax | Remove non-essential motion, shorter distances |
| Complexity | Too many elements, competing hierarchies | Reduce element count, strengthen hierarchy |
| Scale jumps | Inconsistent size ratios | Align to consistent scale, reduce jumps |

### Reduction Levers
- **Color:** Shift from fully saturated to 70-85%. Use tinted grays. Never gray on color. Reduce competing accent colors.
- **Typography:** Reduce font weights (900->600, 700->500). Use 2-3 weights max. Increase line height. Remove decorative text treatments.
- **Spacing:** More whitespace between sections. Increase padding. Separate competing elements with distance.
- **Motion:** Reduce animation distances (10-20px instead of 40px). Ease-out-quart for calmer exits. Remove animations not serving clear purpose. Respect `prefers-reduced-motion`.
- **Borders and Lines:** Reduce thickness. Decrease opacity. Remove when spacing provides enough separation.
- **Composition:** Reduce element count. Group related elements. Use consistent alignment. Remove decorative noise.

### Verification
- Visual noise reduced. Design feels calmer.
- Focal point still most visible.
- Content still communicates clearly.
- Not boring -- controlled.
- Contrast ratios still pass.
- No information lost.

## Polish Checklist

- [ ] All interactive states styled (default, hover, focus, active, disabled)
- [ ] Loading states for async operations
- [ ] Error states with clear messages
- [ ] Empty states with guidance
- [ ] Typography hierarchy consistent
- [ ] Color contrast passes WCAG AA
- [ ] Touch targets >= 44x44px
- [ ] No orphaned words in headings
- [ ] Consistent spacing rhythm
- [ ] Responsive at all breakpoints
- [ ] No layout shift
- [ ] No console.log or debug code
- [ ] No commented-out code
- [ ] Design system tokens used consistently
- [ ] No one-off custom implementations

## Output

List what was polished, grouped by dimension. If the codebase was already clean, say so.
