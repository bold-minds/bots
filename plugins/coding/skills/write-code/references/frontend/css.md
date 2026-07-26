# CSS Reference

## Layout: Flexbox vs Grid
- Use Flexbox for one-dimensional layout (single row OR column), when content drives sizing, items should wrap/self-size.
- Use Grid for two-dimensional layout (rows AND columns), when structure is known upfront (dashboards, card grids), items placed in precise cells.
- If disabling flexbox flexibility (forcing fixed widths on flex children), switch to Grid.
- Use Grid for page structure, Flexbox inside grid cells for component-level alignment.

## Custom Properties
- Naming pattern: `--{category}-{property}-{variant}` (e.g., `--color-primary-500`, `--font-size-lg`)
- Namespace with project prefix in shared environments: `--myapp-color-brand`
- Define global tokens (brand colors, font families, base spacing) on `:root`
- Scope component-specific variables on the component selector — don't pollute `:root`
- Two-tier token system: primitive tokens (`--color-blue-500: oklch(...)`) and semantic tokens (`--color-primary: var(--color-blue-500)`). Switch themes by remapping semantic tokens only.
- Changing a CSS variable is faster than changing multiple properties — prefer variable-based theming over class-swapping.

## Container Queries vs Media Queries
- Media queries for top-level page layout, viewport-specific changes, print styles, accessibility preferences (`prefers-reduced-motion`, `prefers-color-scheme`).
- Container queries for component-level responsiveness — components that adapt based on their container, not the viewport.
- Set `container-type: inline-size` on wrapper. Use `@container` on children, never on the container itself.
- Container requires containment — cannot size itself based on children's intrinsic size in contained axis.
- Combine both: media queries page-level, container queries component-level.

## Logical Properties
- Prefer `margin-inline`, `margin-block`, `padding-inline`, `padding-block` over `margin-left`, `margin-top`, etc.
- Use `inset-inline-start`/`inset-inline-end` instead of `left`/`right`.
- Two-value shorthand: `margin-inline: 1rem 2rem` sets start and end.
- Provides automatic RTL/LTR support — use from start for free internationalization.

## Accessibility
- NEVER remove outline without custom replacement — accessibility violation.
- Use `:focus-visible` instead of `:focus` — shows focus rings only for keyboard users.
- Focus indicators: at least 2px thick, 3:1 contrast ratio against element and background. Not obscured by sticky headers.
- Wrap animations in `@media (prefers-reduced-motion: no-preference) { ... }`. Provide non-motion alternatives.
- Normal text: minimum 4.5:1 contrast (WCAG AA). Large text (18px+ bold or 24px+): 3:1. UI components: 3:1.
- Use `forced-colors` media query for Windows High Contrast Mode.

## Performance
- `will-change`: last resort only. Apply just before animation starts (e.g., on parent `:hover`), remove after. Only for `transform` and `opacity`. Don't apply to many elements — each consumes GPU memory.
- `contain: layout style paint` on visually/layout-isolated components. `contain: strict` most aggressive.
- `content-visibility: auto` on off-screen sections — browser skips rendering until scrolled into view. ALWAYS pair with `contain-intrinsic-size: auto 500px` to prevent layout shifts. Never on above-the-fold content.
- Animate ONLY `transform` and `opacity` — run on GPU compositor thread. Never animate `width`, `height`, `top`, `left`, `margin`, `padding` (trigger layout every frame).
- Use individual transform properties (`translate`, `scale`, `rotate`) instead of compound `transform`.
- Target 16.66ms per frame (60fps).

## Specificity Management with @layer
- Declare layer order upfront: `@layer reset, base, theme, components, utilities;`
- Layer priority trumps specificity — simple selector in later layer beats complex selector in earlier layer.
- Import third-party CSS into early layer: `@import url("framework.css") layer(vendors);` — trivially overridable.
- Eliminates need for `!important` hacks.
- Keep selectors flat — prefer single class selectors.
- Avoid ID selectors in stylesheets (too high specificity).
- Use `:where()` for zero specificity contribution. Use `:is()` for grouping (takes highest specificity of arguments).

## Animation
- CSS transitions for simple state changes (hover, focus, active).
- CSS `@keyframes` for complex multi-step or looping animations.
- Use `animation-composition: accumulate` when layering multiple animations on same property.
- View Transitions API for page-level transitions (both SPA and MPA).
- Use `interpolate-size: allow-keywords` to animate to `auto` height — eliminates `max-height` hack.
- Always provide `prefers-reduced-motion` fallback.
- Use `animation-timeline: scroll()` for scroll-driven animations instead of JS scroll listeners.
