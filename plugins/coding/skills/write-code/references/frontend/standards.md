# Frontend — Astro/Svelte/TypeScript + Product UX

Standards for all frontend code. Mandatory. Detailed rules for each technology are in reference files — consult them when working in that area.

---

## Stack Overview

| Technology | Role | Reference |
|---|---|---|
| Astro | Page framework, routing, SSG/SSR, islands | `references/astro.md` |
| Svelte 5 | Interactive components, runes-based reactivity | `references/svelte.md` |
| TypeScript | Type safety, all runtime logic | `references/typescript.md` |
| JavaScript | Modern syntax, async, memory, events | `references/javascript.md` |
| CSS | Layout, custom properties, accessibility | `references/css.md` |
| Tailwind | Utility-first styling, responsive, dark mode | `references/tailwind.md` |
| JSON | API responses, schemas, data interchange | `references/json.md` |
| Web Performance | Loading strategies, JS cost, caching, HTTP/3, RAIL | `references/web-performance.md` |

**Always consult the relevant reference file before writing code in that technology.** The reference files contain specific rules, anti-patterns, and code examples.

---

## Component Architecture

### Layer Model

1. **Route/Page** (.astro) — Routing + data loading. Minimal logic. Calls loaders, passes data down.
2. **Orchestrator/Container** — Local UI state + wiring. Coordinates sections, handles state transitions. Target 350-400 lines max.
3. **Section/Presentational** — Single visual concept. Receives data via props, communicates via callbacks/events. **Must not** know about routing or access global stores directly.
4. **Primitives** — Tiny reusable building blocks (buttons, inputs, badges). Pure UI, no business logic.

### Key Rules

- Default to `.astro` components — zero client JS. Use Svelte only when client-side interactivity is needed.
- Never wrap layouts in framework components — ships massive JS. Use `.astro` layouts with embedded islands.
- Before creating any component, check: shared primitives → feature-local components → existing patterns → only then create new.
- Near-duplicate components must converge into a single shared component with props/slots.
- No god modules — modules spanning multiple domains must not receive new responsibilities.
- Route/page components: 200-250 lines max. Other modules: ~200 lines.
- More than 3 levels of nesting is a smell — use guard clauses and early returns.

---

## Svelte 5 Runes (Quick Reference)

Consult `references/svelte.md` for full runes documentation, patterns, and pitfalls.

| Rune | Purpose | Key Rule |
|---|---|---|
| `$state` | Reactive state | Use only for truly reactive variables. Use `$state.raw` for large collections replaced not mutated. |
| `$derived` | Computed values | If it CAN be calculated from state, it MUST be `$derived`. Never use `$effect` for this. |
| `$effect` | Side effects | Escape hatch only. DOM manipulation, third-party libs, analytics. Never for state sync. |
| `$props` | Component props | Read-only. Use `$derived` for values computed from props. Type with TypeScript. |
| `$bindable` | Two-way binding | Use sparingly. Prefer unidirectional (callback props) for most cases. |

### Critical Pitfalls
- Destructuring `$state` objects breaks reactivity — access through proxy.
- `$effect` does not track async reads (after `await` or `setTimeout`).
- Module-level `$state` persists across SSR requests — scope via context or `event.locals`.
- Slots are deprecated — use `{#snippet}` and `{@render}`. Event dispatchers replaced by callback props.

---

## TypeScript (Quick Reference)

Consult `references/typescript.md` for full type design patterns, generics, and utility types.

- Always enable `strict: true` + `noUncheckedIndexedAccess`.
- Use `interface` for object shapes, `type` for unions/intersections/mapped types.
- Prefer union types over enums. Use `as const` objects when runtime values needed.
- Use `unknown` (not `any`) for uncertain types. Narrow before use.
- Use discriminated unions + `never` exhaustive check for type-safe branching.
- Use Result pattern for expected errors; reserve `throw` for unexpected defects.
- Avoid barrel files in large codebases. Import directly from source files.
- "Parse, Don't Validate" — use Zod at boundaries, then work with fully-typed data.

---

## Astro (Quick Reference)

Consult `references/astro.md` for full island architecture, content collections, and build optimization.

- Default to SSG. Opt into SSR per-page only where needed.
- Use `client:visible` (below fold) or `client:idle` (secondary features), not `client:load`.
- Fetch data in frontmatter with top-level `await`. Never HTTP to own API routes during build.
- Content collections: always define Zod schemas, sort manually, filter drafts in production.
- Images in `src/` for optimization; `public/` only for unprocessed files.
- Run `astro check` before builds — dev server does not type-check.

---

## Styling (Quick Reference)

Consult `references/css.md` and `references/tailwind.md` for full patterns.

- Tailwind is mobile-first: unprefixed = all sizes, `md:` = medium and up.
- Keep utility class lists under 10-12 per element; extract components beyond that.
- Use `@theme` (Tailwind v4) for design tokens — no `tailwind.config.js`.
- Use Grid for page layout, Flexbox inside grid cells.
- Use CSS custom properties with two-tier tokens (primitive + semantic) for theming.
- Use `@layer` for specificity management — eliminates `!important` hacks.
- Animate only `transform` and `opacity` — everything else triggers layout recalculation.
- Use `:focus-visible` for keyboard-only focus rings. Never remove outline without replacement.

---

## Error Handling

- No silent catches — every catch block must map to a structured error or be explicitly documented as fire-and-forget.
- Define behavior for invalid input, missing data, and failures upfront. "Handle errors later" is not acceptable.
- Domain logic (business rules, calculations) must live in domain/service modules, not UI components or route handlers.
- Use structured/typed error objects so API boundaries can translate to stable error codes.

---

## SEO

Consult `references/astro.md` for Astro-specific SEO patterns.

- Each indexable page: one `<h1>`, logical heading hierarchy, `<title>` (50-60 chars), `<meta description>` (120-160 chars).
- Canonical tags for multi-URL pages. Marketing URLs: human-readable kebab-case.
- Images: WebP/AVIF, width/height for CLS prevention, `srcset`/`sizes` for responsive.
- Every page reachable in 2-3 clicks from home. No orphan pages.
- JSON-LD structured data for key page types, kept in sync with visible content.
- Preserve UTM/campaign parameters through signup flows.

---

## Sync Engine Architecture (Local-First Pattern)

When to consider: productivity apps where users spend extended time post-load, apps needing offline support, collaborative/multiplayer experiences, or any app where loading spinners and stale data are unacceptable.

**When NOT to use:** operations requiring server validation before visibility (payments, trading), systems with massive datasets exceeding client storage, or apps where optimistic updates would frequently fail.

### Core Concept
The client always reads from and writes to a local store. That store syncs bidirectionally with the server. The server remains authoritative, but the client operates independently.

### Key Patterns
- **Optimistic updates:** Changes apply immediately on the client. Server validation either confirms or triggers a rollback with rebase of pending mutations.
- **Local persistence:** Data cached in memory + IndexedDB provides instant reads and resilience against network loss.
- **Pull-based sync:** Clients periodically pull changes. A "poke" mechanism (SSE or WebSocket) triggers immediate pulls for real-time behavior.
- **Cross-tab coordination:** Broadcast channels keep multiple browser tabs synchronized while managing schema compatibility.
- **Conflict resolution:** Git-like approach -- server stores revisions and flags conflicts, client library decides how to merge.

### What This Replaces
Traditional REST/GraphQL request-response cycles for every data operation. Instead of fetching, rendering, waiting, and re-fetching -- the local store is always populated, always current, and always fast.

### Implementation Options (current landscape)
- **PowerSync** -- Postgres/MongoDB/MySQL to SQLite sync
- **Zero (Rocicorp)** -- client-side relational database with sync
- **RxDB** -- JavaScript reactive database with sync replication
- **Convex** -- object sync engine with server-side functions
- **WASM SQLite** -- near-native database performance in the browser

---

## Analytics Architecture

- System of record (DB, Stripe) is canonical. Analytics (GA4, PostHog) is always derived, never canonical.
- One stable internal user ID across all tools.
- Encapsulate analytics calls in helper functions/service modules — not scattered in components.
- Distinguish web analytics (consent-sensitive) from product analytics (may be always-on for product experience).

---

## Product UX Standards

### Journey & State Coverage

Every feature covers: **discover → try → use → recover → upgrade**. Every flow includes:
- **Loading** — skeleton/spinner
- **Empty** — guidance + CTA (not just "no data")
- **Error** — recovery action (not just "something went wrong")
- **Success** — next steps

### No Dead Ends

- No placeholder buttons, fake links, or broken CTAs in shipped UI. Hide unfinished features or label "Coming soon."
- Pre-fill with sensible defaults. Remember previous choices.

### Wayfinding & Copy

- Each screen answers: "Where am I?" / "What can I do?" / "Where do I go next?"
- Button labels describe actions: "Save changes" not "Submit." Error messages: user terms + next steps, no internal codes.
- Upgrade flows: show value before asking for commitment. No dark patterns.
- Significant UX changes must define success metrics before shipping.

---

## Reference Files

Consult these for detailed rules, code examples, and anti-patterns:

- **`references/astro.md`** — Islands, client directives, content collections, SSR/SSG, styling, view transitions, image optimization, build optimization, TypeScript in Astro, SEO patterns
- **`references/svelte.md`** — Runes ($state, $derived, $effect, $props, $bindable), component patterns, snippets, state management, reactivity pitfalls, lifecycle, accessibility, animations, testing, Svelte 4→5 migration
- **`references/typescript.md`** — Strict mode, interfaces vs types, generics, discriminated unions, type narrowing, utility types, enums vs unions, unknown/any/never, Result pattern, readonly, template literals, branded types, barrel files
- **`references/javascript.md`** — Modern syntax (ES2022-2024), async patterns, memory leak prevention, event handling, Temporal API
- **`references/css.md`** — Flexbox vs Grid, custom properties, container queries, logical properties, accessibility (focus, motion, contrast), performance (will-change, contain, content-visibility), @layer specificity, animations
- **`references/tailwind.md`** — Extraction rules, responsive mobile-first, dark mode, Tailwind v4 @theme, state variants, class management, anti-patterns
- **`references/json.md`** — Naming conventions, JSON Schema, null handling, ISO 8601 dates, nested vs flat structure, error responses, pagination
- **`references/web-performance.md`** — Rendering strategy decision tree (SSR/CSR/SSG/islands), JavaScript cost management, framework selection, caching strategy (Cache-Control), HTTP/3 and transport, idle-until-urgent pattern, data fetching patterns, RAIL model, Core Web Vitals