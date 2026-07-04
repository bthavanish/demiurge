# Quieter Mode

Tones down aggressive or overstimulating designs. Reduces visual noise while preserving intent.

## Register Awareness

### Brand Context
Quieter in brand means: a more restrained palette, more typographic air, less visual noise, more whitespace. Brand quieter is about sophistication and letting the work speak for itself.

### Product Context
Quieter in product means: reducing visual noise, fewer background accents, flatter cards, less competing motion. Product quieter is about reducing cognitive load so the user can focus on the task.

## Intensity Diagnostic

Before reducing, diagnose the source of visual noise:

| Source | Signal | Fix |
|--------|--------|-----|
| **Color saturation** | Fully saturated backgrounds, competing accents | Desaturate to 70-85%, use tinted grays |
| **Contrast extremes** | Very dark on very light, harsh borders | Soften contrast ratios, reduce border weight |
| **Visual weight** | Heavy fonts, thick borders, large icons | Reduce font weights, thin borders, smaller icons |
| **Animation excess** | Entrance animations on every section, parallax | Remove non-essential motion, shorter distances |
| **Complexity** | Too many elements, competing hierarchies | Reduce element count, strengthen hierarchy |
| **Scale jumps** | Inconsistent size ratios between elements | Align to a consistent scale, reduce jumps |

## Process

1. **Assess visual noise.** What's screaming that should whisper? What's competing for attention?

2. **Reduce selectively.** Lower the volume on secondary elements. Keep the focal point.

3. **Preserve hierarchy.** The most important thing should still be the most visible.

## Reduction Levers

### Color
- Shift from fully saturated to 70-85% saturation
- Use tinted grays instead of pure gray
- Never gray on color -- use a tinted darker shade of the background hue
- Reduce the number of competing accent colors
- Use neutral tones for background elements
- Increase whitespace to let colors breathe

### Typography
- Reduce font weights (900 -> 600, 700 -> 500)
- Use fewer font weights (2-3 max)
- Increase line height for calmer reading
- Remove decorative text treatments
- Reduce heading sizes that feel like shouting

### Spacing
- Add more whitespace between sections
- Increase padding to reduce density
- Separate competing elements with distance
- Reduce scale jumps between heading levels

### Motion
- Reduce animation distances (10-20px instead of 40px)
- Use ease-out-quart for calmer exits
- Remove animations entirely if not serving clear purpose
- Slow down transitions (longer durations)
- Respect `prefers-reduced-motion`

### Borders and Lines
- Reduce border thickness
- Decrease border opacity
- Remove borders entirely when spacing provides enough separation

### Composition
- Reduce the number of elements on screen
- Group related elements to reduce cognitive load
- Use consistent alignment to create calm
- Remove decorative elements that add noise
- Align to grid for visual consistency

## Verification Checklist

- [ ] Visual noise is reduced. The design feels calmer.
- [ ] The focal point is still the most visible element.
- [ ] Content still communicates clearly.
- [ ] The design is not boring -- it's controlled.
- [ ] Contrast ratios still pass (text >= 4.5:1).
- [ ] No information was lost in the reduction.

## Rules

- Reduce volume, not meaning. The content should still communicate clearly.
- Quiet does not mean boring. It means controlled.
- Preserve the focal point. If the user's eye wanders, you've gone too quiet.
- Ship code, not concepts.
