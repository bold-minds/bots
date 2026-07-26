# Astro Framework Reference

## Project Structure
- Put page routes in `src/pages/` (mandatory, only required directory)
- Put reusable UI in `src/components/`
- Put shared page shells in `src/layouts/`
- Put optimizable images in `src/` (not `public/`) — `src/` images get transformed, optimized, bundled
- Use `public/` only for files that must not be processed: robots.txt, manifest.json, favicons, fonts
- Never put CSS or JS in `public/` expecting bundling — files in `public/` bypass all processing
- Always include `tsconfig.json` even if not writing TypeScript — enables editor IntelliSense

## Component Patterns
- Default to `.astro` components — they render to pure HTML with zero client-side JS
- Only use framework components (Svelte, React) when client-side interactivity is needed
- Never wrap entire layouts in framework components — ships massive JS bundles. Use `.astro` for layouts with small embedded islands
- Never import `.astro` components inside framework components (technically impossible). Pass Astro content as children/slots from `.astro` parent
- Without a `client:*` directive, framework components render to static HTML at build time with zero JS
- Always define Props interface in component frontmatter for type safety
- Never pass functions as props to hydrated framework components — Astro cannot serialize functions. Pass only serializable data (strings, numbers, objects, arrays, Date, URL, Map, Set)

## Island Architecture (client: Directives)
- `client:visible` — below-the-fold interactive content (comments, carousels, footer widgets). JS loads when user scrolls to it
- `client:idle` — secondary features (newsletter signups, share buttons, analytics). Loads when browser main thread is idle
- `client:load` — ONLY for critical above-the-fold interactions (nav dropdowns, hero interactions). Use sparingly
- `client:media={QUERY}` — responsive-only components (mobile hamburger menus)
- `client:only={FRAMEWORK}` — components that cannot server-render (depend on `window`/`document` at render time). Skips SSR entirely
- Never default to `client:load` "because it just works" — every `client:load` adds immediate JS payload
- Never map over large arrays to spawn individual client islands — creates N separate JS bundles. Render list statically, hydrate a single controller island
- Use shared stores (nanostores) for cross-island communication, not prop drilling through Astro

## Data Fetching
- Fetch data in component frontmatter (between `---` fences) — Astro supports top-level `await`
- Pass fetched data to child components as props
- Never fetch your own API routes via HTTP during build — creates build-order dependencies. Use shared utility modules instead
- Use content collections for structured local content (blog posts, docs, product data)
- Use API endpoints (`src/pages/api/`) for: webhook receivers, client-side fetching from islands, feed generation (RSS, sitemaps), form handlers (POST/PUT/DELETE)
- Use `getCollection()` and `getEntry()` for content collections — never read content files directly with `fs`

## Content Collections
- Always define schemas with Zod for every collection — gives build-time validation and TypeScript types
- Always restart dev server after modifying schemas or creating new collections
- Always sort collections manually — collection order is non-deterministic. Never rely on filesystem order
- Always filter drafts conditionally: `import.meta.env.PROD ? data.draft !== true : true`
- Use `reference()` for relationships between collections (blog post → author)
- Use `z.coerce.date()` for date fields — handles string-to-Date conversion
- Use `[...id].astro` (rest parameter) for slug routes when content IDs contain slashes
- Use the `image()` helper in schemas to validate and optimize content collection images

## Image Optimization
- Store optimizable images in `src/` not `public/` — `src/` images get automatic format conversion (WebP/AVIF), resizing, lazy loading, CLS prevention
- Always provide `alt` text on `<Image />` and `<Picture />` — mandatory, errors without it
- Use `<Picture />` when multiple formats are needed — generates `<picture>` tags with AVIF/WebP fallbacks
- Authorize remote image domains in `astro.config.mjs` using `image.domains` or `image.remotePatterns`
- Never use `<Image />` or `<Picture />` inside framework components — they cannot use Astro components. Import the image, access `.src`, use standard `<img>`, or pass via slot
- Use `getImage()` for programmatic image generation (API routes, Open Graph images)
- For Markdown: use standard `![alt](path)` syntax. `<Image />` is not available in `.md` (only `.mdx` and `.astro`)
- Use responsive images (Astro 5.10+) via `layout` property: `constrained` or `full-width`

## SSR vs SSG Decision
- Default to SSG (static) and opt into SSR only where needed — Astro's default mode is static for a reason
- Use SSG when: content changes daily or less, pages identical for all users, data available at build time, maximum performance needed, SEO primary concern
- Use SSR when: user authentication/personalization needed, real-time data, server-side form processing, database queries per-request, content depends on request headers/cookies
- Use Hybrid Mode (recommended for most projects): most pages SSG + individual pages opt into SSR with `export const prerender = false`
- Never use SSR for content that does not change — blog via SSR is slower than SSG + CDN
- Always use an adapter (Cloudflare, Netlify, Vercel, Node) when enabling SSR

## Scoped Styling
- Use Astro's scoped `<style>` tags by default — styles auto-scoped via data attributes, prevents leakage
- Scoped styles do NOT cascade into child Astro components — they only apply to HTML written directly in that component. Wrap children in a targetable element
- Use `<style is:global>` sparingly — only for truly global styles (resets, typography, theme variables)
- Use `:global()` selector for targeted global rules within otherwise scoped styles: `article :global(h1) { color: blue; }`
- Use `class:list` for conditional classes: `<div class:list={['box', { active: isActive }, someClass]}>`
- Use `define:vars` to pass JS values to CSS: `<style define:vars={{ color: themeColor }}>` then `var(--color)`
- For Tailwind: use Tailwind 4 with Astro 5.2+. Import via `@import "tailwindcss"` in a global CSS file. Remove the legacy `@astrojs/tailwind` integration
- When passing classes to child components, the child must explicitly accept and apply the class, including `...rest` for scoped style data attributes
- CSS cascade order (lowest to highest priority): link tags, imported stylesheets, scoped styles

## TypeScript in Astro
- Use the `strict` or `strictest` tsconfig template: `{ "extends": "astro/tsconfigs/strict" }`
- Include `.astro/types.d.ts` in tsconfig `include` for full Astro type support
- Use explicit type imports with `import type { ... }` and enable `verbatimModuleSyntax: true`
- Define a `Props` interface in every `.astro` component that accepts props
- Run `astro check` before builds — the dev server does NOT perform type checking: `{ "scripts": { "build": "astro check && astro build" } }`
- Configure path aliases to avoid deep relative imports: `"@components/*": ["./src/components/*"]`
- Use `src/env.d.ts` for global type extensions

## View Transitions
- Use `<ClientRouter />` from `astro:transitions` in base layout for SPA-like navigation across MPA
- Use `transition:persist` on elements that should survive navigation (video players, audio, persistent UI state)
- Use `astro:page-load` instead of `DOMContentLoaded` when using view transitions — DOMContentLoaded only fires on initial load
- Add `data-astro-reload` to links that should trigger full page loads (external links, downloads, logout)
- Sanitize input before passing to `navigate()` to prevent XSS
- Include `<title>` on every page for the accessibility route announcer
- Astro automatically respects `prefers-reduced-motion` and disables all transition animations

## SEO
- Set the `site` property in `astro.config.mjs` — required for sitemaps, canonical URLs, and OG tags
- Include on every page: `<title>`, `<meta name="description">`, Open Graph tags, Twitter Card tags, canonical URL
- Install `@astrojs/sitemap` for auto-generated sitemaps
- Create a reusable SEO/Head component in base layout that accepts title, description, image as props
- Set canonical URLs using `Astro.url.pathname` + `Astro.site`
- Add JSON-LD structured data for rich search results
- Configure `robots.txt` as static file in `public/` or via `@astrojs/robots`

## Build Optimization
- Use content collection caching to avoid re-processing unchanged content
- Move large media (videos, large image sets) to a CDN — removes them from build pipeline
- Implement API response caching for build-time data fetching — prevents redundant network calls
- Use dynamic imports (`import()`) for large libraries not needed immediately
- Choose tree-shakeable libraries (ESM with named exports) over monolithic bundles
- Enable prefetching via `prefetch: true` in config or per-link with `data-astro-prefetch`
- Use `font-display: swap` for web fonts to prevent invisible text during font loading

## Common Mistakes
- Wrapping entire layouts in framework components — ships massive JS
- Defaulting to `client:load` everywhere — use `client:visible` or `client:idle`
- Mapping arrays to create many client islands — render statically, hydrate one controller
- Fetching own API routes via HTTP during build — use shared utility modules
- Putting optimizable images in `public/` — skips all optimization
- Importing full utility libraries (`import _ from 'lodash'`) — use named imports from ESM
- Not filtering drafts in production — published draft content
- Relying on collection order — non-deterministic, always sort explicitly
- Using `DOMContentLoaded` with View Transitions — fires only once, use `astro:page-load`
- Not running `astro check` — dev server does not type-check
- Passing functions as props to hydrated islands — cannot be serialized, will silently fail
- Using SSR for static content — slower than SSG + CDN
