# Web Performance Reference

Distilled from: web.dev performance guides, CSS Wizardry caching guide, Smashing Magazine performance checklist, V8 blog, Philip Walton's idle-until-urgent, HTTP/3 research, Alex Russell's framework analysis, htmx docs, and rendering strategy guides.

---

## Rendering Strategy Decision Tree

Choose based on session characteristics, not framework preference.

### When to Use Each Strategy

| Strategy | Use When | TTFB | FCP | TTI |
|---|---|---|---|---|
| **SSG** | Content changes daily or less, SEO-critical, same for all users | Fast | Fast | Excellent |
| **SSR** | Personalization, real-time data, auth-dependent content | Slower | Fast | Good |
| **Streaming SSR** | Large component trees, faster FCP critical | Moderate | Fast | Good |
| **CSR (SPA)** | Long-session apps with frequent data updates (editors, dashboards) | Fast | Slow | Slow |
| **Progressive Hydration** | Complex apps where not all components need immediate interactivity | Moderate | Fast | Better |
| **Islands** | Mostly-static pages with isolated interactive widgets | Fast | Fast | Excellent |

### The Decision Sequence

1. Can this page be static? -> SSG + CDN (fastest, cheapest)
2. Does it need per-request data? -> SSR with caching, or hybrid SSG + SSR per-page
3. Is it a long-session, data-heavy app? -> Only then consider CSR/SPA
4. Does it need real-time collaboration? -> Consider local-first sync engine (see SKILL.md)

### Rehydration Warning

Full rehydration has "considerable performance drawbacks." The page appears loaded but cannot respond to input until client JS executes. Server sends the UI description AND the source data AND the implementation -- triple redundancy. Use progressive hydration or islands architecture instead.

### Trisomorphic Rendering

Share templating/routing code across server, client, and service worker. Initial load uses SSR; service worker handles subsequent navigations like a SPA. Best for apps where users navigate extensively after first load.

---

## JavaScript Cost Management

### The Core Problem

JavaScript execution is the dominant cost on mobile. Mid-range phones execute JS 3-4x slower than high-end devices; low-end phones 6x slower. The virtual DOM "was never fast" -- it doubles work on the main thread.

### Size Budgets

- First-load JS budget: 170 KB compressed (Smashing Magazine checklist)
- If a bundle exceeds 50-100 KB, split it for HTTP/2 multiplexing
- Avoid inlining scripts over 1 KB (prevents code caching by V8)
- First-load CSS budget: 30 KB compressed

### Framework Selection Hierarchy

For most sites (informational, e-commerce, media):
1. Static generation (Hugo, Astro, 11ty) -- no framework JS
2. Server-rendered HTML with progressive enhancement (Rails, Django, Laravel)
3. Islands architecture (Astro) for isolated interactivity
4. Lightweight frameworks (Preact, Svelte, Solid, Lit) for true SPA needs
5. React/Angular only for long-session apps with strict performance guardrails

Key data point: React's synthetic event system creates lock-in while doubling main-thread work. Any developer competent with React can master Preact, Svelte, or Solid.

### htmx: When Server-Rendered is Enough

htmx extends HTML with `hx-get`, `hx-post`, `hx-target`, `hx-swap` attributes for AJAX without a framework. Choose htmx when:
- Server-side rendering is your strength
- You don't need offline-first or complex client state
- Smaller team without specialized frontend engineers
- Full-page reactivity is not required

htmx falls short for: rich text editors, offline-first apps, bandwidth-constrained environments needing JSON over HTML fragments.

### Qwik Resumability Model

Traditional hydration replays all component initialization on the client. Qwik's resumability serializes component state into HTML, then lazily loads event handlers only when triggered. Partytown moves third-party scripts (analytics, ads) to a web worker. Result: up to 99% JS reduction for content sites.

### Redux Is Half a Pattern

Redux implements event sourcing (actions + reducers) but lacks command handling (effects, state machines). Reducers alone cannot express "when in state X, action Y is invalid." State machines/statecharts fill this gap by making impossible states unrepresentable. Consider XState or similar for complex UI state.

### Code Splitting Tactics

- Split by route for SPAs
- Dynamic `import()` for on-demand loading
- Import-on-interaction for UI features (load chart library on first click)
- Module/nomodule pattern: `<script type="module">` for modern browsers, `<script nomodule>` for legacy (20-30% bundle reduction for modern clients)

### JSON.parse Optimization

Replace large JavaScript object literals with `JSON.parse('...')` for objects 10 KB or larger. V8 shows 1.7x speedup; benefits apply across all engines.

---

## Caching Strategy

### Cache-Control by Asset Type

```
# HTML pages (dynamic)
Cache-Control: no-cache

# HTML pages (rarely changes, e.g. FAQ)
Cache-Control: max-age=604800, must-revalidate

# Static assets with fingerprinted filenames (JS/CSS/fonts)
Cache-Control: max-age=31536000, immutable

# Sensitive pages (banking, accounts)
Cache-Control: private, no-cache, no-store

# API responses (frequently updated)
Cache-Control: max-age=300, must-revalidate

# Decorative images
Cache-Control: max-age=2419200, must-revalidate, stale-while-revalidate=86400
```

### Critical Directives

| Directive | What It Does | Common Confusion |
|---|---|---|
| `no-cache` | Cache it, but revalidate before serving | Does NOT mean "don't cache" |
| `no-store` | Never cache at all | Use for truly sensitive data |
| `immutable` | Skip revalidation even on refresh | Only for fingerprinted files |
| `s-maxage` | Override max-age for CDNs only | Different TTL for edge vs browser |
| `stale-while-revalidate` | Serve stale during background refresh | Reduces perceived latency |

### Cache-Busting Strategy

Fingerprint filenames (preferred): `/style.ae3f66.css` -- filename changes with content.
Query strings are suboptimal: proxies strip them.
You MUST have a cache-busting strategy before setting aggressive max-age.

### Key Principle

"The best request is the one that never happens." Design cache policy before optimizing anything else.

---

## HTTP/3 and Transport Optimization

### What HTTP/3 (QUIC) Actually Improves

- **Head-of-line blocking**: QUIC handles packet loss per stream independently. Benefit is real but modest on low-loss networks. Major gains on high-loss connections.
- **0-RTT connection resumption**: Saves one round trip for resumed connections (not two or three as marketed). ~40% of connections are resumptions.
- **Connection migration**: Preserves connections across network changes (WiFi to cellular). Most useful for long-lived connections like video streaming.

### 0-RTT Security Constraints

- Only safe for idempotent GET requests without query parameters (replay attack risk)
- Server responses capped at 4-6 KB initially
- TLS 1.3 0-RTT saves ~250ms on resumed connections

### When HTTP/3 Delivers Maximum Impact

1. High-latency networks (satellite, remote regions with 100+ ms RTT)
2. Slow/variable networks where packet loss disrupts TCP
3. Users in the 90th-99th percentile of slowness
4. Repeated visits leveraging session resumption

Users on fast, stable connections see minimal gains. The most impactful optimization remains reducing geographic distance via CDN.

### Server Push Is Declining

HTTP/2 server push has diminished relevance with HTTP/3. Focus instead on critical resource ordering and keeping initial payload under 14 KB.

---

## Idle-Until-Urgent Pattern

### The Problem

Synchronous initialization during page load creates long tasks (>50ms) that block user input. "Death by a thousand cuts" -- individual functions are fast but their cumulative synchronous execution blocks the main thread.

### Three Initialization Strategies

| Strategy | When It Runs | Best For |
|---|---|---|
| **Eager** | Immediately on load | Critical path only |
| **Lazy** | When first needed | Rarely-used features |
| **Idle-until-urgent** | During idle time, or immediately if needed before idle fires | Everything else |

### Implementation Pattern

```javascript
class IdleValue {
  constructor(init) {
    this._init = init;
    this._value;
    this._idleHandle = requestIdleCallback(() => {
      this._value = this._init();
    });
  }
  getValue() {
    if (this._value === undefined) {
      cancelIdleCallback(this._idleHandle);
      this._value = this._init();
    }
    return this._value;
  }
}
```

If the value is needed before idle callback fires, initialization runs synchronously (same as lazy). If idle time is available first, initialization happens without blocking.

### IdleQueue for Analytics and State Persistence

Queue multiple tasks to run during idle time. Set `ensureTasksRun: true` to guarantee execution during `visibilitychange` event (prevents data loss when users navigate away).

### Measured Results

- FID p99: 254ms -> 85ms (67% reduction)
- Longest task: 233ms -> 37ms
- Same total work, spread across sub-50ms idle chunks

### Browser Support

`requestIdleCallback` supported in Chrome and Firefox. Fallback to `setTimeout` still provides benefits since browsers prioritize input over setTimeout tasks.

---

## Data Fetching Patterns

### The Waterfall Problem

Fetch-on-render creates sequential waterfalls: Parent renders -> fetches data -> Child renders -> fetches its data. Each level adds a full round trip.

### Pattern Comparison

| Pattern | How It Works | Tradeoff |
|---|---|---|
| **Fetch-on-render** | Components fetch their own data on mount | Creates waterfalls; simple to implement |
| **Fetch-then-render** | Fetch all data before rendering anything | No waterfall; shows nothing until everything is ready |
| **Render-as-you-fetch** | Start fetch and render simultaneously; stream results | Best performance; requires Suspense or equivalent |
| **Prefetching** | Start fetching before navigation/interaction | Eliminates perceived latency; requires prediction |

### Practical Rules

- Fetch independent data in parallel, never sequentially
- Colocate data requirements with routes, not components (route-level loaders)
- Prefetch on hover/focus for likely next navigations
- Cache aggressively on the client with stale-while-revalidate semantics
- Use server-side data loading (Astro frontmatter, SvelteKit load functions) to eliminate client waterfalls entirely

---

## RAIL Performance Model

| Phase | Budget | Key Rule |
|---|---|---|
| **Response** | 50ms processing (100ms perceived) | Process input within 50ms; provide feedback for longer work |
| **Animation** | 10ms per frame (60fps target) | Pre-calculate during response window; animate only transform/opacity |
| **Idle** | 50ms max per idle chunk | Use requestIdleCallback; yield immediately on user input |
| **Load** | 5s on mid-range mobile/slow 3G; 2s for repeat visits | Eliminate render-blocking resources; lazy-load below fold |

---

## Core Web Vitals Quick Reference

| Metric | Measures | Good Threshold |
|---|---|---|
| **LCP** (Largest Contentful Paint) | Main content visible | < 2.5s |
| **INP** (Interaction to Next Paint) | Responsiveness to all interactions | < 200ms |
| **CLS** (Cumulative Layout Shift) | Visual stability | < 0.1 |
| **FCP** (First Contentful Paint) | First visual response | < 1.8s |
| **TTFB** (Time to First Byte) | Server responsiveness | < 800ms |
| **TBT** (Total Blocking Time) | Main thread blocked between FCP and TTI | < 200ms |

---

## Performance Quick Wins (Ordered by Impact)

1. Ship less JavaScript (biggest lever on mobile)
2. Compress with Brotli (10-20% better than gzip)
3. Optimize images (WebP/AVIF, responsive srcset, lazy-load below fold)
4. Inline critical CSS, defer the rest
5. Set correct Cache-Control headers with fingerprinted assets
6. Use resource hints: `preconnect` (critical origins), `preload` (critical fonts/hero images), `prefetch` (likely next pages)
7. Font-display: swap + subset fonts (can reduce font size 50%+)
8. Code-split by route with dynamic imports
9. Serve modern JS to modern browsers (module/nomodule)
10. Move third-party scripts to web workers or load async

---

## Measurement Stack

- **Lab testing**: Lighthouse, WebPageTest (waterfall analysis)
- **Field testing (RUM)**: Web Vitals library -> analytics endpoint
- **Continuous monitoring**: Lighthouse CI in pull requests, performance budgets in build pipeline
- **Competitive benchmark**: Chrome UX Report (CrUX). Target 20% faster than competitors for perceivable difference.

---

## WASM + DuckDB in Browser

From "My browser WASM't prepared for this" -- pattern for heavy client-side data processing.

### The Pattern

Run DuckDB compiled to WebAssembly inside a Web Worker. The main thread stays responsive while the worker executes SQL queries against in-browser datasets. Apache Arrow serves as the zero-copy interchange format between DuckDB and the rendering layer.

### When to Use

- Analytical dashboards where data can be shipped to the client (parquet files, CSV)
- Offline-capable data exploration tools
- Replacing server round-trips for filter/aggregate/sort on datasets under ~100MB
- Privacy-sensitive analytics where data should not leave the browser

### Architecture

1. **Main thread**: UI rendering only. Sends query requests to worker via `postMessage`.
2. **Web Worker**: Loads DuckDB-WASM, executes SQL, returns Arrow-serialized results.
3. **Apache Arrow**: Columnar format enables zero-copy transfer between WASM and JS. Avoids JSON serialization overhead.

### Key Constraints

- Initial WASM bundle is ~4MB (use lazy loading, cache aggressively)
- Memory limited to browser tab allocation (~2-4GB depending on browser)
- First query has cold-start cost while WASM initializes
- Not a replacement for server-side processing on large datasets

---

## Web Workers Capabilities

From "The State Of Web Workers In 2021."

### What Web Workers Solve

The main thread is responsible for both UI rendering and JS execution. Any JS task >50ms blocks user input. Web Workers run JS on separate threads with zero main-thread impact.

### Worker Types

| Type | Scope | Lifetime | Use Case |
|---|---|---|---|
| **Dedicated Worker** | Single page | Page lifetime | Heavy computation, data processing |
| **Shared Worker** | Multiple tabs/windows | Until last tab closes | Cross-tab state synchronization |
| **Service Worker** | Origin-wide | Event-driven (install/activate/fetch) | Offline caching, background sync, push notifications |

### Communication Patterns

- **postMessage**: Default. Data is structured-cloned (copied). Fine for small payloads.
- **Transferable objects**: Zero-copy transfer of ArrayBuffers, MessagePorts, OffscreenCanvas. Original becomes unusable in sender.
- **SharedArrayBuffer + Atomics**: True shared memory. Requires COOP/COEP headers (`Cross-Origin-Opener-Policy: same-origin`, `Cross-Origin-Embedder-Policy: require-corp`). Use for real-time shared state.

### What Workers Cannot Do

- Access the DOM (no `document`, no `window`)
- Use synchronous XHR (use `fetch` instead)
- Access `localStorage` (use IndexedDB or postMessage to main thread)

### Practical Guidelines

- Move any computation >16ms off the main thread
- Use Comlink to simplify worker communication (RPC-style API over postMessage)
- Bundle workers with your build tool (Webpack 5 `new Worker(new URL(...))`, Vite native support)
- Pool workers for repeated short tasks rather than spawning/destroying

---

## Adaptive Serving with Network Information API

From "Serving Adaptive Components Using the Network Information API."

### The Concept

Serve different asset quality based on the user's actual network conditions, not just viewport size. A user on a fast connection gets high-res images and rich interactions; a user on slow 3G gets lightweight alternatives.

### API Surface

```javascript
const connection = navigator.connection || navigator.mozConnection;

connection.effectiveType; // "4g", "3g", "2g", "slow-2g"
connection.downlink;      // Estimated bandwidth in Mbps
connection.rtt;           // Round-trip time in ms
connection.saveData;      // User opted into data saver mode
```

### Adaptive Patterns

| Signal | Adaptation |
|---|---|
| `effectiveType === "2g"` or `saveData === true` | Placeholder images, no video autoplay, minimal JS |
| `effectiveType === "3g"` | Low-res images, defer non-critical resources |
| `effectiveType === "4g"` | Full experience, prefetch likely next pages |
| `rtt > 500` | Increase timeouts, show loading states earlier |

### Implementation

```javascript
function getImageQuality() {
  const conn = navigator.connection;
  if (!conn) return "high"; // fallback for unsupported browsers
  if (conn.saveData || conn.effectiveType === "2g") return "low";
  if (conn.effectiveType === "3g") return "medium";
  return "high";
}
```

### Caveats

- Not supported in Safari/Firefox (Chrome/Edge only as of 2024). Always provide fallback.
- `effectiveType` is an estimate, not a guarantee. Use as progressive enhancement, not hard gating.
- Combine with `prefers-reduced-data` media query for CSS-level adaptation.

---

## CSS for Web Vitals

From web.dev "CSS for Web Vitals."

### CSS Impact on LCP

- **Render-blocking**: All CSS in `<head>` blocks rendering. Inline critical CSS (above-the-fold styles) and defer the rest.
- **Font loading**: `font-display: swap` prevents invisible text. Preload critical fonts with `<link rel="preload" as="font" crossorigin>`.
- **Background images**: LCP element using `background-image` cannot be discovered by the preload scanner. Use `<img>` for LCP images instead, or add an explicit `<link rel="preload">`.

### CSS Impact on CLS

- **Always set dimensions**: `width`/`height` on images and videos, or use `aspect-ratio`. Without these, content shifts as media loads.
- **`contain-intrinsic-size`**: Pair with `content-visibility: auto` to reserve space for off-screen content.
- **Avoid inserting content above existing content**: Dynamically injected banners, cookie bars, or ads above the fold cause layout shifts. Reserve space or use fixed/sticky positioning.
- **Web fonts CLS**: `font-display: optional` eliminates layout shift entirely (at the cost of sometimes not showing the custom font). `size-adjust`, `ascent-override`, `descent-override` on `@font-face` to match fallback font metrics.

### CSS Impact on INP

- **Expensive selectors**: Deeply nested selectors and universal selectors (`*`) in large DOMs slow style recalculation. Keep selectors flat and specific.
- **`contain` property**: `contain: layout` or `contain: content` limits browser recalculation scope. Apply to independent widgets.
- **`content-visibility: auto`**: Skips rendering for off-screen elements entirely. Massive win for long pages with many sections.
- **Avoid forced synchronous layouts**: Reading layout properties (`offsetHeight`, `getBoundingClientRect()`) after writing styles forces a synchronous reflow. Batch reads and writes separately.

---

## Deferring Non-Critical CSS

From web.dev "Defer non-critical CSS."

### Technique

```html
<!-- Critical CSS inlined -->
<style>/* above-the-fold styles */</style>

<!-- Non-critical CSS loaded asynchronously -->
<link rel="preload" href="styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="styles.css"></noscript>
```

### How It Works

1. `rel="preload"` fetches the stylesheet without blocking render.
2. `onload` switches `rel` to `stylesheet` after download, applying styles.
3. `this.onload=null` prevents re-triggering in some browsers.
4. `<noscript>` fallback for users without JavaScript.

### Identifying Critical CSS

- Tools: Critical (npm package), Penthouse, Critters (webpack plugin)
- Critical CSS = styles needed for above-the-fold content on initial viewport
- Automate extraction in build pipeline; manual maintenance is unsustainable

### Alternative: Media Attribute Trick

```html
<link rel="stylesheet" href="print.css" media="print" onload="this.media='all'">
```

Browser downloads print stylesheets at low priority without blocking render. `onload` switches to `all` media after load.

---

## Partial Hydration and Progressive Enhancement

From "Building Partially Hydrated, Progressively Enhanced Static Websites."

### The Problem with Full Hydration

Full hydration ships the entire component tree as JavaScript, re-executes it client-side, and attaches event listeners to server-rendered HTML. This means the browser parses, compiles, and executes JS for components that may never need interactivity (headers, footers, static text blocks).

### Partial Hydration Strategy

1. **Identify interactive boundaries**: Mark only the components that need client-side JS (forms, toggles, dynamic widgets). Everything else stays as static HTML -- zero JS cost.
2. **Hydrate on trigger**: Instead of hydrating everything on load, hydrate components when they become relevant:
   - `on:visible` -- hydrate when scrolled into viewport (IntersectionObserver)
   - `on:idle` -- hydrate during idle time (requestIdleCallback)
   - `on:interaction` -- hydrate on first click/focus/hover
   - `on:media` -- hydrate when media query matches (e.g., mobile-only widget)
3. **Progressive enhancement base**: The site works without JavaScript. Interactive components enhance the experience but are not required for core functionality.

### Framework Support

- **Astro**: Islands architecture. Components are static by default; add `client:visible`, `client:idle`, `client:load` directives for selective hydration.
- **Eleventy + WebC/is-land**: `<is-land>` custom element wraps interactive components with configurable hydration triggers.
- **Qwik**: Resumability -- no hydration at all. Serializes state into HTML, lazy-loads handlers on interaction.

### Key Insight

"The fastest JavaScript is no JavaScript." Partial hydration aligns the JS cost with the actual interactivity requirements of each component, rather than treating the entire page as a single interactive unit.

---

## Workbox: Service Worker Toolkit

From Chrome for Developers "Workbox" documentation.

### What Workbox Is

A set of libraries from Google that simplify service worker development. Abstracts the boilerplate of caching strategies, precaching, background sync, and routing into a declarative API.

### Caching Strategies

| Strategy | Behavior | Use Case |
|---|---|---|
| **CacheFirst** | Serve from cache; fall back to network | Fonts, images, static assets that rarely change |
| **NetworkFirst** | Try network; fall back to cache | API responses, dynamic HTML pages |
| **StaleWhileRevalidate** | Serve from cache immediately; update cache in background | Assets that change but staleness is acceptable (CSS, non-critical JS) |
| **NetworkOnly** | Always fetch from network | Non-cacheable requests (analytics pings, POST) |
| **CacheOnly** | Only serve from cache | Precached assets during offline mode |

### Precaching

Workbox CLI or build plugins (webpack, Rollup, Vite) generate a precache manifest at build time. Assets are versioned by content hash. On service worker install, all manifested assets are cached. On update, only changed assets are re-fetched.

```javascript
import { precacheAndRoute } from 'workbox-precaching';
precacheAndRoute(self.__WB_MANIFEST); // injected by build tool
```

### Runtime Routing

```javascript
import { registerRoute } from 'workbox-routing';
import { CacheFirst, StaleWhileRevalidate } from 'workbox-strategies';
import { ExpirationPlugin } from 'workbox-expiration';

registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [new ExpirationPlugin({ maxEntries: 50, maxAgeSeconds: 30 * 24 * 60 * 60 })],
  })
);
```

### Background Sync

Queue failed requests (e.g., form submissions while offline) and replay them when connectivity returns:

```javascript
import { BackgroundSyncPlugin } from 'workbox-background-sync';

const bgSyncPlugin = new BackgroundSyncPlugin('formQueue', {
  maxRetentionTime: 24 * 60, // retry for up to 24 hours
});
```

### When to Use Workbox

- Any PWA or site that benefits from offline support
- Apps with significant repeat visitors (caching pays off)
- Sites serving large static asset sets (precaching eliminates repeat downloads)
- When you need service worker functionality but do not want to write raw Cache API code
