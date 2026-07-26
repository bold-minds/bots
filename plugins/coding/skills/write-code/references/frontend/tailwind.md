# Tailwind CSS Reference

## When to Extract vs Inline

- Keep utility classes inline when: elements in a loop (duplication in source only), element is unique/appears once, class list under 10-12 utilities.
- Extract a component/partial when: same markup+styles appears in multiple files, element is more than a single tag, need single source of truth.
- Use `@layer components` with custom CSS when: need a semantic class for simple element AND not using a component framework.
- Never use `@apply` to recreate traditional CSS classes for everything — defeats utility-first purpose, inflates bundle.
- Never create custom classes for one-off elements.

## Responsive Design

- Tailwind is mobile-first: unprefixed utilities apply to ALL screen sizes; `sm:`, `md:`, `lg:` apply at that breakpoint AND above.
- Design mobile layout first with unprefixed utilities, then layer breakpoint-prefixed overrides.
- Default breakpoints: `sm` 640px, `md` 768px, `lg` 1024px, `xl` 1280px, `2xl` 1536px.
- Use `max-*:` variants for styles only below a breakpoint.
- In Tailwind v4, use `@sm:`, `@md:`, `@lg:` for container query variants (first-class, no plugin).
- Hide/show: `hidden md:block` (hidden on mobile, visible from md up).

## Dark Mode

- Three strategies:
  - `media` (default): auto-detects OS preference via `prefers-color-scheme`. Zero JS, no user toggle.
  - `class`: toggle `.dark` class on ancestor. Full user control.
  - `selector` with `data-theme`: supports multiple themes beyond light/dark.
- Use `dark:` variant prefix: `bg-white dark:bg-gray-900`.
- Prevent FOUC by placing theme detection script inline in `<head>` before rendering.
- Persist user preference in `localStorage`.
- Implement three-way toggle: Light / Dark / System.
- Use consistent color pairings: `gray-100` light → `gray-800`/`gray-900` dark.

## Tailwind v4

- Theme configuration now in CSS via `@theme` directive — no `tailwind.config.js` required.
- Define tokens as CSS custom properties in `@theme { }`: `--color-brand: oklch(0.7 0.15 200);`
- `@theme` generates corresponding utility classes automatically (`bg-brand`, `text-brand`).
- v4 uses OKLCH colors by default for more vibrant, perceptually uniform colors.
- First-class container query support without plugins.
- Never hardcode magic numbers with arbitrary values — define as theme tokens.

## State Variants

- `hover:` — on hover. Internally wraps in `@media (hover: hover)` so doesn't fire on touch.
- `focus:` — any focus. `focus-visible:` — keyboard focus only (preferred for focus rings).
- `active:` — while pressed.
- `group-hover:` — style child when ancestor with `group` class is hovered.
- `peer-checked:`/`peer-focus:` — style sibling based on another element's state. The `peer` must come before target in DOM order.
- `disabled:` — disabled form elements.
- Combine: `dark:hover:bg-gray-700`.

## Consistent Spacing

- Stick to default spacing scale (multiples of 4px: `1`=4px, `2`=8px, `4`=16px).
- Define custom spacing in `@theme` if default doesn't fit design system.
- Use same spacing tokens for margin, padding, gap, sizing.
- Use `gap-*` on flex/grid containers instead of margin on children.

## Class Management

- Use `clsx` or `cn()` (with `tailwind-merge`) to conditionally compose class strings in JSX.
- Remove conflicting utilities — don't apply both `grid` and `flex` on same element.
- Don't use arbitrary values (`w-[347px]`) when a theme token exists (`w-96`).
- Use shorthand: `size-12` instead of `w-12 h-12`, `inset-0` instead of `top-0 right-0 bottom-0 left-0`.

## Anti-Patterns

| Anti-Pattern | Why Bad | Do Instead |
|---|---|---|
| `@apply` everywhere | Inflates CSS, loses utility benefits | Extract framework components |
| Arbitrary values for everything | Magic numbers, inconsistent | Define tokens in `@theme` |
| No component extraction | Massive duplication | Components/partials for repeated patterns |
| Ignoring theme customization | Generic look, no brand | Customize colors, fonts, spacing |
| Not mobile-first | Overriding at every breakpoint | Start unprefixed, add breakpoint variants |
| Exposing style props on components | Specificity conflicts | Fixed variant props (`variant="primary"`) |
| Tailwind without component framework | Painful duplication | Use React/Vue/Svelte or partials |
