# Design Material Mode

Build UI using Material Design 3 (Material You) guidelines. Component-first, token-driven, platform-aware.

## Workflow

1. **Identify the platform.** Jetpack Compose (primary), Flutter, or Web.

2. **Load the component catalog.** Read the platform-specific reference for the component you need.

3. **Apply MD3 tokens.** Never hardcode colors, shapes, or sizes. Use the design token system.

4. **Build.** Ship production-grade code, not prototypes.

## Platform Decision Tree

| Platform | Library | Notes |
|----------|---------|-------|
| Android | `androidx.compose.material3` | Primary. Full MD3 support including Expressive. |
| Flutter | `useMaterial3: true` | Good coverage. Use `ColorScheme.fromSeed()`. |
| Web (vanilla) | `@material/web` + CSS custom properties | Maintenance mode. Limited M3 Expressive. |
| Web (React/Vue/Svelte) | CSS custom properties + wrapper components | Build custom wrappers around MD3 tokens. |
| Web (CSS-only) | MD3 token values as CSS custom properties | No JS needed for static themes. |

## Design Token System

### Color

- Use `--md-sys-color-*` CSS tokens or `MaterialTheme.colorScheme` (Compose).
- MD3 color roles: primary, secondary, tertiary, error, surface, on-primary, on-secondary, on-tertiary, on-error, on-surface, outline, outline-variant, inverse-surface, inverse-on-surface, inverse-primary, surface-variant, background, on-background.
- Tonal palette: seed color generates 5 palettes (primary, secondary, tertiary, neutral, neutral-variant) with 13 tonal stops each.
- Dynamic color: use wallpaper-derived or content-derived color when available (API 31+ on Android).
- Dark theme: automatic generation from the same seed. Never hardcode dark colors separately.
- User-controlled contrast: 3 levels (default, medium, high).

### Typography

- 15 baseline styles: Display (L/M/S), Headline (L/M/S), Title (L/M/S), Body (L/M/S), Label (L/M/S).
- 15 emphasized styles for M3 Expressive.
- Component-to-type-style mapping: each MD3 component uses specific type styles.
- Never hardcode font sizes or weights. Use the type scale.

### Shape

- 10 shape tokens from `none` (0dp) to `full` (circular).
- Component-to-shape mapping: each component has a default corner radius.
- Shape morphing available in Expressive (platform-dependent).

### Elevation

- 5 levels (0-4). MD3 uses tonal surface color, not shadows, to communicate depth.
- Tonal elevation: surface color shifts toward primary at higher elevations.
- CSS shadows only when shadows are appropriate (floating elements).

### Motion

- Spring-based physics (Expressive). Easing/duration system for standard.
- Duration scale: 16 tokens from 50ms to 1000ms.
- Reduced motion: always provide `prefers-reduced-motion` alternatives.

## Component Checklist

For each component, verify:
- Correct MD3 element name and import
- All attributes use MD3 tokens, not hardcoded values
- Color roles applied correctly (not swapped)
- Shape token matches component specification
- Elevation level is appropriate
- Typography uses type scale, not hardcoded sizes
- Accessibility: ARIA labels, keyboard navigation, screen reader support
- Responsive behavior at all window sizes

## Anti-Patterns

- Hardcoded colors instead of tokens
- MD2 and MD3 mixing (do not mix `@material/mdc-*` with `@material/web`)
- Importing all of `@material/web` (tree-shaking issues)
- Wrong color pairing (on-primary on a surface that is not primary)
- Shadows where tonal elevation should be used
- Missing dark theme support
- Non-responsive layouts

## Window Size Classes

| Class | Width | Device | Columns |
|-------|-------|--------|---------|
| Compact | <600dp | Phone (portrait) | 4 |
| Medium | 600-839dp | Phone (landscape), Foldable | 8 |
| Expanded | 840-1199dp | Tablet | 12 |
| Large | 1200-1599dp | Desktop | 12 |
| Extra-large | >=1600dp | Wide desktop | 12 |

## Responsive Navigation

| Destinations | Mobile | Tablet | Desktop |
|-------------|--------|--------|---------|
| 3-5 | NavigationBar | NavigationRail | NavigationRail + Drawer |
| 6+ | NavigationBar | NavigationRail | NavigationDrawer |

## Rules

- Compose-first. All guidance defaults to Jetpack Compose. Adapt for other platforms.
- Token-driven. Never hardcode colors, shapes, sizes, or spacing.
- No MD2/MD3 mixing.
- Tonal elevation over shadows.
- Always support dark theme.
- Always support reduced motion.
- Ship production code, not prototypes.
