# JavaScript Reference

## Modern Syntax

Use optional chaining (`?.`) for safe property access:

```js
const name = user?.profile?.name;
const first = users?.[0]?.name;
const result = obj?.method?.();
```

Use nullish coalescing (`??`) for defaults — only triggers on `null`/`undefined`, not `0`/`""`/`false`:

```js
const port = config.port ?? 3000;
const label = input ?? "default"; // "" stays as "", 0 stays as 0
```

Use `structuredClone()` for deep cloning — replaces `JSON.parse(JSON.stringify())`. Handles dates, maps, sets, circular refs:

```js
const copy = structuredClone(original);
```

Use logical assignment — assign only when condition met:

```js
options.timeout ??= 5000;  // assign if null/undefined
cache.data ||= fetchData(); // assign if falsy
config.debug &&= validate(config.debug); // assign if truthy
```

Use `Object.groupBy()` (ES2024) for grouping arrays:

```js
const grouped = Object.groupBy(products, (p) => p.category);
// { electronics: [...], clothing: [...] }
```

Use immutable array methods (ES2023/2024) — don't mutate original:

```js
const sorted = arr.toSorted((a, b) => a - b);
const reversed = arr.toReversed();
const replaced = arr.with(2, "new"); // replace index 2
const spliced = arr.toSpliced(1, 1, "inserted");
```

Use Set operations (ES2024):

```js
const a = new Set([1, 2, 3]);
const b = new Set([2, 3, 4]);

a.union(b);        // Set {1, 2, 3, 4}
a.intersection(b); // Set {2, 3}
a.difference(b);   // Set {1}
a.isSubsetOf(b);   // false
```

Use `Promise.withResolvers()` (ES2024) for cleaner promise construction:

```js
const { promise, resolve, reject } = Promise.withResolvers();
// Pass resolve/reject to callbacks, event handlers, etc.
```

Use `.at()` for negative indexing:

```js
const last = arr.at(-1);
const secondLast = arr.at(-2);
const lastChar = str.at(-1);
```

Use `findLast()` and `findLastIndex()` (ES2023) to search from end:

```js
const lastEven = nums.findLast((n) => n % 2 === 0);
const lastIdx = nums.findLastIndex((n) => n > 10);
```

## Async Patterns

Use `Promise.all()` when all must succeed (fail-fast). Use `Promise.allSettled()` when results needed from all regardless of failures:

```js
// Fail-fast — rejects immediately if any promise rejects
const [users, posts] = await Promise.all([fetchUsers(), fetchPosts()]);

// Get all results regardless of failures
const results = await Promise.allSettled([fetchA(), fetchB(), fetchC()]);
results.forEach((r) => {
  if (r.status === "fulfilled") console.log(r.value);
  if (r.status === "rejected") console.error(r.reason);
});
```

Don't `await` sequentially when calls are independent:

```js
// BAD — sequential, twice as slow
const users = await fetchUsers();
const posts = await fetchPosts();

// GOOD — parallel
const [users, posts] = await Promise.all([fetchUsers(), fetchPosts()]);
```

Use `AbortController` for cancellable requests:

```js
const controller = new AbortController();
setTimeout(() => controller.abort(), 5000); // timeout after 5s

try {
  const res = await fetch(url, { signal: controller.signal });
} catch (err) {
  if (err.name === "AbortError") console.log("Request cancelled");
}
```

Always wrap `await` in try/catch or attach `.catch()`. Never leave promises unhandled:

```js
// try/catch
try {
  const data = await fetchData();
} catch (err) {
  handleError(err);
}

// .catch()
fetchData().then(process).catch(handleError);
```

## Error Handling

Use specific error classes, not generic `Error`:

```js
class ValidationError extends Error {
  constructor(field, message) {
    super(message);
    this.name = "ValidationError";
    this.field = field;
  }
}

throw new ValidationError("email", "Invalid email format");
```

Use the `cause` property (ES2022) to chain errors:

```js
try {
  await fetchUser(id);
} catch (err) {
  throw new NetworkError("Failed to load user", { cause: err });
}

// Access the chain
console.log(error.cause); // original error
```

## Module Patterns (ESM)

Standardize on ESM — it is the present standard.

Use static imports at top. Use dynamic `import()` for code-splitting and lazy loading:

```js
// Static — top of file
import { formatDate } from "./utils.js";

// Dynamic — load on demand
const { Chart } = await import("./chart.js");
```

Prefer named exports over default exports:

```js
// GOOD — named exports (explicit, refactorable, auto-importable)
export function parseConfig(raw) { /* ... */ }
export const DEFAULT_TIMEOUT = 5000;

// AVOID — default exports (unclear names, harder to refactor)
export default function parseConfig(raw) { /* ... */ }
```

Keep side-effects out of modules — no top-level mutations, subscriptions, or DOM manipulation at import time:

```js
// BAD — runs on import
document.addEventListener("click", handler);
globalState.initialized = true;

// GOOD — explicit initialization
export function init() {
  document.addEventListener("click", handler);
}
```

## Memory Leak Prevention

Scope variables to functions/blocks. Minimize globals — globals are never garbage-collected:

```js
// BAD
let cache = {}; // module-level, lives forever

// GOOD — scoped or bounded
function processData() {
  const cache = new Map(); // GC'd when function returns
}
```

Always remove event listeners when DOM element removed or component unmounts:

```js
const handler = (e) => console.log(e);
element.addEventListener("click", handler);

// On cleanup
element.removeEventListener("click", handler);
```

Clear `setInterval`/`setTimeout` when no longer needed:

```js
const id = setInterval(poll, 1000);
// On cleanup
clearInterval(id);
```

Remove references to detached DOM nodes — keeping a reference prevents entire subtree GC:

```js
// BAD — element removed from DOM but reference held
let detached = document.getElementById("old");
detached.remove();
// detached still holds ref — subtree not GC'd

// GOOD
detached = null;
```

Use `WeakMap` and `WeakSet` for caches keyed by objects — auto garbage-collected when no other refs:

```js
const metadata = new WeakMap();

function track(element) {
  metadata.set(element, { clicks: 0 });
}
// When element is GC'd, metadata entry is automatically removed
```

Use `WeakRef` and `FinalizationRegistry` sparingly — GC timing is unpredictable:

```js
const ref = new WeakRef(largeObject);
// ref.deref() returns object or undefined if GC'd
```

## Event Handling

Use event delegation for lists — one listener on parent instead of one per child:

```js
document.getElementById("list").addEventListener("click", (e) => {
  const item = e.target.closest("li");
  if (item) handleItemClick(item);
});
```

Use `{ once: true }` for one-shot listeners:

```js
button.addEventListener("click", handleSubmit, { once: true });
```

Use `{ passive: true }` for scroll/touch listeners to improve performance:

```js
window.addEventListener("scroll", onScroll, { passive: true });
element.addEventListener("touchstart", onTouch, { passive: true });
```

Use `AbortController` for batch listener cleanup — add `{ signal }` to multiple listeners, then `abort()` to clean all:

```js
const controller = new AbortController();
const { signal } = controller;

element.addEventListener("click", onClick, { signal });
element.addEventListener("keydown", onKey, { signal });
window.addEventListener("resize", onResize, { signal });

// Clean up all at once
controller.abort();
```

## Date/Time

Use the Temporal API for new code (supported Chrome, Edge, Firefox as of 2025). Use polyfill for Safari/Opera:

```js
import { Temporal } from "@js-temporal/polyfill"; // if needed
```

Choose the right Temporal type:

```js
// Date only (no time, no timezone)
const date = Temporal.PlainDate.from("2025-06-15");

// Time only
const time = Temporal.PlainTime.from("14:30:00");

// Date + time, no timezone
const dt = Temporal.PlainDateTime.from("2025-06-15T14:30:00");

// Full timezone-aware datetime
const zdt = Temporal.ZonedDateTime.from("2025-06-15T14:30:00[America/New_York]");

// Absolute timestamp (like Date.now() but better)
const instant = Temporal.Now.instant();

// Duration
const dur = Temporal.Duration.from({ hours: 2, minutes: 30 });
```

All Temporal objects are immutable — operations return new objects:

```js
const tomorrow = today.add({ days: 1 });
const nextMonth = date.add({ months: 1 });
const diff = date1.until(date2);
```

Store and transmit timestamps in ISO 8601 format:

```js
const iso = instant.toString(); // "2025-06-15T18:30:00Z"
const parsed = Temporal.Instant.from(iso);
```

Until Temporal fully available, use `date-fns` (tree-shakable, immutable) over Moment.js (deprecated, large):

```js
import { format, addDays, differenceInDays } from "date-fns";

const formatted = format(new Date(), "yyyy-MM-dd");
const future = addDays(new Date(), 7);
const gap = differenceInDays(dateA, dateB);
```

---

## Svelte Flow Diagrams with Svelvet

From "Svelvet: Svelte node-based flow diagrams."

### What Svelvet Is

A Svelte component library for building interactive node-based flow diagrams (similar to React Flow but for Svelte). Useful for visual editors, workflow builders, data pipeline UIs, and dependency graphs.

### Key Features

- Draggable, connectable nodes with custom Svelte components as content
- Edge routing with customizable paths (bezier, step, straight)
- Zoom, pan, minimap, and selection controls built in
- Lightweight compared to React Flow since it leverages Svelte's compile-time approach

### When to Use

- Building visual workflow/pipeline editors
- Displaying dependency graphs or org charts with interactivity
- Any UI where users connect nodes/boxes with edges
- Svelte/SvelteKit projects that need flow diagram capabilities without pulling in React

### Consideration

Node-based UI libraries add significant complexity. Evaluate whether a simpler list/tree/kanban interface serves the use case before committing to a flow diagram UX.

---

## SPA Routing Philosophy

From "Routing: I'm not smart enough for a SPA."

### The Argument

Client-side routing in SPAs re-implements browser navigation poorly. The browser already handles routing, history, scroll restoration, back/forward, and link behavior. SPA routers must re-create all of this, and they get it wrong in subtle ways:
- Scroll position not restored correctly on back navigation
- Browser loading indicators do not work (user sees no feedback)
- Accessibility announcements on page change are often missing
- `<a>` tags require special wrappers (`<Link>`) to intercept navigation

### The Alternative

Use **MPA (multi-page app) architecture** with progressive enhancement:
- Server-rendered pages with standard `<a>` links
- Enhance specific interactions with JS (fetch + DOM update) where SPA-like behavior is needed
- Frameworks like Astro, SvelteKit (with SSR), and Remix default to this model
- View Transitions API (Chrome, Edge) provides SPA-like visual transitions between full page loads

### When a SPA Router IS Justified

- Long-session apps where full page reloads would destroy complex client state (e.g., code editors, design tools, real-time collaboration)
- Apps with heavy client-side state that is expensive to reconstruct on each navigation
- NOT justified for marketing sites, blogs, e-commerce, documentation, or CRUD apps

### Practical Takeaway

Default to server-rendered pages with standard navigation. Reach for client-side routing only when you can articulate what specific user experience problem it solves that server rendering cannot.

---

## SPA 404 Handling with SEO

From "How To Properly Serve 404 Errors on SPAs (with SEO in Mind)."

### The Problem

SPAs serve a single `index.html` for all routes. When a user or search engine crawler hits a non-existent URL, the server returns 200 OK with `index.html` instead of 404. This causes:
- Search engines index non-existent pages (wasting crawl budget)
- Soft 404s that confuse Google Search Console
- Users see a blank page or broken UI instead of a helpful error

### Solutions

**Option 1: SSR/Prerendering for known routes**
- Pre-render all valid routes at build time or use SSR. Unknown routes return a proper 404 HTTP status. This is the cleanest solution (Astro, SvelteKit, Next.js all support this).

**Option 2: Server-side route validation**
- Configure the server (Nginx, Cloudflare, Vercel) to serve `index.html` only for known route patterns. Unknown patterns return 404 status with a 404 page.

**Option 3: Client-side 404 with meta tag**
- If fully client-side: render a 404 component and add `<meta name="robots" content="noindex">` to prevent search engine indexing. This is a band-aid -- the HTTP status is still 200.

### Best Practice

Use SSR or static generation with a proper server-side 404 response. If stuck with a pure SPA, implement server-side route validation so the HTTP status code is correct for crawlers.

---

## Underused HTML Attributes

From "Those HTML Attributes You Never Use."

### Useful but Overlooked

| Attribute | Element | What It Does |
|---|---|---|
| `inputmode` | `<input>` | Controls virtual keyboard type. `inputmode="numeric"` shows number pad on mobile without restricting input to numbers (unlike `type="number"`). |
| `enterkeyhint` | `<input>`, `<textarea>` | Changes the Enter key label on mobile keyboards: `"search"`, `"send"`, `"go"`, `"next"`, `"done"`. |
| `inert` | Any element | Makes element and all descendants non-interactive and invisible to assistive tech. Better than `aria-hidden` + `tabindex="-1"` for disabling sections. |
| `loading="lazy"` | `<img>`, `<iframe>` | Native lazy loading. No JS library needed. Use for below-fold images. |
| `decoding="async"` | `<img>` | Allows browser to decode image off main thread. Pair with `loading="lazy"` for non-critical images. |
| `fetchpriority` | `<img>`, `<link>`, `<script>` | `"high"` for LCP image, `"low"` for non-critical resources. Gives browser explicit priority hints. |
| `popover` | Any element | Native popover API. No JS needed for show/hide. Handles light-dismiss, top-layer stacking, and focus management. |
| `autofocus` | Form elements | Focus element on page load. Use sparingly -- only when the page's primary purpose is that input (search pages, login forms). |
| `translate="no"` | Any element | Prevents browser translation tools from translating content. Use for brand names, code snippets, technical terms. |
| `spellcheck="false"` | `<input>`, `<textarea>` | Disables spellcheck. Use for code inputs, API keys, identifiers. |

### Key Takeaway

Native HTML attributes often eliminate the need for JavaScript solutions. Check MDN for built-in capabilities before reaching for a library.

---

## Publishing npm Packages with TypeScript and Microbundle

From "Writing an npm module with TypeScript and microbundle."

### The Stack

- **TypeScript** for type safety and `.d.ts` generation
- **Microbundle** (or similar: tsup, unbuild) for zero-config bundling that outputs CJS, ESM, and UMD in one step

### Package.json Setup

```json
{
  "name": "my-package",
  "version": "1.0.0",
  "source": "src/index.ts",
  "main": "dist/index.cjs",
  "module": "dist/index.mjs",
  "types": "dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.cjs",
      "types": "./dist/index.d.ts"
    }
  },
  "files": ["dist"],
  "scripts": {
    "build": "microbundle",
    "dev": "microbundle watch"
  }
}
```

### Key Decisions

- **`exports` field**: Modern Node.js resolution. Define explicit entry points for ESM and CJS consumers. Without this, bundlers may pick the wrong format.
- **`files` field**: Whitelist what goes in the published package. Keeps package size small. Never publish `src/`, `tests/`, or config files.
- **`types` field**: Points to generated `.d.ts` file. TypeScript consumers get autocompletion and type checking.
- **Tree-shaking**: ESM output (`module` field) enables tree-shaking in consumer bundlers. Always provide ESM.

### Publishing Checklist

1. `npm run build` -- verify output in `dist/`
2. `npm pack` -- inspect tarball contents before publishing
3. Test the package locally: `npm link` or `npm install ../my-package`
4. `npm publish` (use `--dry-run` first)
5. Verify on unpkg.com or jsdelivr.net that files are accessible

### Modern Alternatives to Microbundle

- **tsup**: Esbuild-based, faster, supports ESM/CJS/DTS. Most popular for library authors in 2024+.
- **unbuild**: From the UnJS ecosystem. Auto-detects config from package.json.
- **Vite library mode**: If already using Vite, configure `build.lib` for library output.
