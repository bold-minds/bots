# Svelte 5 Reference

## $state
- Use `$state` ONLY for variables that are truly reactive -- those that trigger updates in `$effect`, `$derived`, or template expressions. Everything else should be a normal variable.
- Use `$state(value)` for primitives and objects/arrays intended to be mutated in place.
- Use `$state.raw(value)` for large objects or collections that will only be replaced (never mutate properties). Avoids proxy overhead -- use for API response data.
- `$state({...})` and `$state([...])` create deeply reactive proxies. Changing `todos[0].done = true` triggers updates only for that specific property.
- Array methods like `.push()`, `.splice()` work reactively on `$state` arrays.
- Destructuring breaks reactivity: `let { done, text } = todos[0]` evaluates at destructuring time -- changes to `done` will NOT affect the original. Access properties through the proxy.
- Cannot export `$state` variables directly. Export state nested in objects, export getter functions, or use classes with `$state` fields.
- Cross-module reactivity requires closures. A raw exported `$state` variable freezes at import time. Use getter/setter patterns, `$state` objects (can mutate properties but not reassign root), or classes (get V8 optimization advantages).
- Use `$state.snapshot()` to extract a plain (non-proxy) snapshot for passing to external libraries (console.log, serialization, third-party code). Uses `.toJSON()` which cannot access private class fields.
- When calling methods from event handlers on `$state` class instances, use arrow functions or inline calls to preserve `this` context.

## $derived
- If a value CAN be calculated from existing state, it MUST be `$derived`, never computed via `$effect`. This is the single most important rule.
- Use `$derived(expression)` for simple one-liners. Use `$derived.by(() => { ... })` for multi-statement logic. They are equivalent.
- `$derived` is lazy (pull-based) -- only recalculates when something reads it, not on every dependency change.
- Push-pull reactivity: state changes notify dependents immediately (push), but derived recalculation only occurs when read (pull). If new value is referentially identical to previous, downstream skips updates.
- Dependencies tracked synchronously. Use `untrack()` to exclude specific reads.
- No side effects inside `$derived` -- Svelte disallows state changes (e.g., `count++`).
- Destructuring with `$derived` creates separate reactive deriveds: `let { a, b, c } = $derived(stuff())`.
- Derived values are writable since Svelte 5.25 -- can temporarily reassign for optimistic UI patterns. Re-derives when dependencies change.
- Objects/arrays from `$derived` are NOT deeply reactive unless `$state` is used inside `$derived.by`.

## $effect
- `$effect` is an ESCAPE HATCH, not routine code. Use only for unavoidable side effects: DOM manipulation, third-party library integration, canvas, analytics, logging.
- Effects run AFTER component mounts and AFTER DOM updates, batched in a microtask after state changes.
- Variants: `$effect(() => {...})` runs after DOM updates. `$effect.pre(() => {...})` runs BEFORE DOM updates (replaces `beforeUpdate`). `$effect.root(() => {...})` creates non-tracked scope with manual cleanup.
- Cleanup pattern: return a function from `$effect` -- runs before re-run and on unmount.
- ANTI-PATTERNS (never do):
  1. Never use `$effect` to synchronize state -- if setting one `$state` based on another, use `$derived`
  2. Never read and write the same `$state` in an effect -- creates infinite loops. Use `untrack()` if unavoidable
  3. Never chain effects to link dependent values ("effect ping-pong") -- use `$derived` or function bindings
  4. Do not wrap effect body in `if (browser)` -- effects already only run in browser
  5. Do not use `$effect` for event handling -- put code directly in handlers
  6. Do not use `$effect` for global event listeners -- use `<svelte:window>` or `<svelte:document>`
  7. Use `$inspect` for debugging instead of `$effect(() => console.log(value))`
- `$effect` does NOT track async reads -- values read after `await` or inside `setTimeout` are not dependencies.

## $props
- Destructure for clean access with defaults: `let { adjective, count = 0, ...rest } = $props()`
- Rename with destructuring for reserved words: `let { class: className } = $props()`
- Rest props with `...rest` for forwarding attributes.
- Props are read-only. Never mutate unless marked `$bindable`.
- Fallback values are NOT reactive proxies.
- Treat props as potentially changing -- use `$derived` for values computed from props: `let color = $derived(type === 'danger' ? 'red' : 'green')`. Not `let color = type === 'danger' ? 'red' : 'green'` (won't update).
- Type props with TypeScript: `let { adjective }: { adjective: string } = $props()`
- `$props.id()` (Svelte 5.20+) generates unique, SSR-consistent ID per component instance.

## $bindable
- Use sparingly -- only for genuine two-way binding (form inputs, controlled components).
- Declare in child: `let { value = $bindable('') } = $props()`
- Bind in parent: `<Input bind:value={name} />`
- Without `$bindable`, `bind:value` causes compiler error -- contract is explicit.
- Overuse makes data flow unpredictable. Prefer unidirectional (callback props) for most cases.
- Fallback values only apply when prop is NOT bound.

## Component Patterns

### Snippets Replace Slots (Svelte 5)
- Slots are deprecated. Use `{#snippet}` and `{@render}`.
- Default content becomes `children` prop, rendered via `{@render children?.()}`.
- Named snippets declared inside a component tag automatically become props.
- Snippets accept parameters (unlike slots), have lexical scoping, support TypeScript via `Snippet<[ParamTypes]>`.
- Snippets can self-reference recursively.

### Callback Props Replace Event Dispatchers
- Old: `dispatch('close')`. New: `let { onclose } = $props(); onclose?.()`.
- Benefits: TypeScript type-safety, "Go to Definition" works, explicit contract, no event bubbling confusion.

### Component Composition
- If a component grows beyond 3-4 props for layout/content, refactor into compound components.
- Use compound components pattern: parent with children that communicate via context.
- Use CSS custom properties for styling: `<Child --color="red" />` -- child uses `var(--color, blue)`.

### Context API
- Use `createContext` (not raw `setContext`/`getContext`) for type safety.
- Context prevents state leakage between users in SSR (unlike shared modules).
- Context scopes state to a component tree, avoiding global pollution.

## State Management
- Local state: use `$state` directly in components. No boilerplate.
- Shared client-side state: reactive classes with `$state` fields, exported from `.svelte.ts` files. Classes get V8 optimization.
- App-wide client state: context API (instantiate in root layout). Each SSR request gets fresh context.
- Server state: use `event.locals` in hooks/load functions. Never use module-level `$state` for server-side data -- persists across requests, causes state pollution.
- Runes have largely replaced stores. Stores remain for complex async data streams or RxJS-like patterns.
- `onMount` and stores are NOT deprecated. `beforeUpdate`/`afterUpdate` ARE deprecated.
- Only rename `.ts` to `.svelte.ts` when files explicitly use runes.

### Global State Dangers
- Module-level `$state` in isomorphic apps persists across server requests -- causes data leaks.
- Concurrent async requests to shared global state create race conditions.
- Always scope shared state via context or `event.locals` in SSR.

## Reactivity Pitfalls
1. Computing values in effects instead of `$derived` -- most common anti-pattern
2. Destructuring reactive proxies -- breaks reactivity link
3. Exporting raw `$state` -- freezes value at import time
4. Mutating props -- only allowed on `$bindable`
5. Using array index as keyed-each key -- defeats the purpose; keys must uniquely identify data
6. `$effect` does not track async reads -- values after `await`/`setTimeout` are not dependencies

## Event Handling (Svelte 5)
- Use standard HTML attributes: `<button onclick={() => {...}}>` (not `on:click`)
- Attribute shorthand: `<button {onclick}>`
- Spread: `<button {...props}>`
- Use `<svelte:window>` and `<svelte:document>` for window/document events
- Component events use callback props (not `createEventDispatcher`)

## Performance
- Use keyed `{#each}` blocks -- allows surgical DOM insert/remove. Keys must uniquely identify objects; NEVER use array indices.
- Use `$state.raw` for large collections replaced not mutated (API responses, paginated data).
- Only mark variables as `$state` if actually reactive. Non-reactive = plain `let`/`const`.
- Virtual lists for large datasets -- render only visible items.
- Code-split with dynamic imports -- can reduce initial load by up to 60%.
- All Svelte transitions/animations use CSS (off main thread). Prefer CSS over tick-based JS.
- Svelte runtime is ~1.6KB vs React's ~40KB+.

## Lifecycle
- Only two phases: creation and destruction. Everything between handled by effects reacting to state.
- `onMount` -- runs once after DOM mount. Returns cleanup function. Does NOT run during SSR. NOT deprecated.
- `onDestroy` -- runs before unmount. Only legacy hook that runs during SSR.
- `tick()` -- returns promise resolving after pending state changes apply to DOM.
- `beforeUpdate`/`afterUpdate` -- DEPRECATED. Replace with `$effect.pre` and `$effect`.
- Async `onMount` cannot return cleanup -- use `onDestroy` separately.

## Form Handling (SvelteKit)
- Use `+page.server.ts` form actions for server-side processing.
- Forms should work without JavaScript (progressive enhancement).
- Add `use:enhance` from `$app/forms` to progressively enhance with JS.
- Validate on server; show inline errors while preserving user input.
- Test both no-JS and full-JS paths.

## Accessibility
- Svelte compiler warns about 35 common a11y issues at build time.
- Click handlers on non-interactive elements must have keyboard equivalents. Use semantic `<button>` or `<a>`.
- Image alt text must not contain "image"/"photo"/"picture" (redundant).
- Form labels must be associated via `for` attribute or wrapping.
- Video requires `<track kind="captions">`.
- Compiler catches common issues but NOT everything. Run Axe, WAVE, or Lighthouse audits.
- Use `$props.id()` for SSR-safe element ID generation when linking labels to inputs.

## Animations & Transitions
- `transition:` applies enter+exit. `in:` and `out:` for separate control. Only ONE transition per element.
- `animate:` directive MUST be on immediate child of keyed `{#each}`. Only triggers on index changes.
- Use `flip` for list reorder animations. All transitions use CSS (off main thread).
- Keep animations subtle -- pick 1-2 complementary effects.
- Respect `prefers-reduced-motion`.

## Testing
- Use Vitest with `@testing-library/svelte`. Vitest browser mode recommended for most accurate results.
- Use `flushSync()` from `svelte` to synchronously apply state updates in tests.
- Use `$effect.root()` to test side effects in `.svelte.ts` files.
- Focus on behavior and user experience, not implementation details.
- Extract business logic into plain `.ts` functions and test independently.
- Use Playwright for E2E tests of critical user journeys.

## Migration Table (Svelte 4 to 5)

| Old (Svelte 4) | New (Svelte 5) |
|---|---|
| `let x = 0` (implicit) | `let x = $state(0)` |
| `$: doubled = x * 2` | `let doubled = $derived(x * 2)` |
| `$: { sideEffect() }` | `$effect(() => { sideEffect() })` |
| `export let prop` | `let { prop } = $props()` |
| `on:click={handler}` | `onclick={handler}` |
| `<slot>` / `<slot name="x">` | `{@render children()}` / `{#snippet}` |
| `createEventDispatcher` | Callback props |
| `use:action` | `{@attach handler}` |
| Writable stores | Classes with `$state` fields |
| `beforeUpdate`/`afterUpdate` | `$effect.pre`/`$effect` |
