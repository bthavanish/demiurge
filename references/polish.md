# Polish Mode

Final quality pass. Catches the small details that separate good work from great work.

## Workflow

1. **Design system discovery.** Find existing design tokens, component libraries, style guides. Note conventions. Identify drift and root cause (missing token, one-off implementation, conceptual misalignment).

2. **Pre-polish assessment.** Review completeness. Is it functionally complete? What's the quality bar (MVP vs flagship)? Triage cosmetic vs functional.

3. **Systematic polish.** Work through every dimension below.

4. **Final verification.** Re-check at multiple viewport sizes.

## Polish Dimensions

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

### Content and Copy
- Consistent voice and tone
- No orphaned words in headings
- Error messages explain what happened and what to do
- Button labels are action-oriented

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

## Output

List what was polished, grouped by dimension. If the codebase was already clean, say so.
