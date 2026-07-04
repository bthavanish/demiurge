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
