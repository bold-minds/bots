import { svelte } from "@sveltejs/vite-plugin-svelte";
import { defineConfig } from "vitest/config";

// The unit tests run the page as the browser does: Svelte compiled by its plugin, jsdom for the document, and the
// browser resolve condition so Svelte hands out its client build. The clock is UTC, so times read the same on
// every machine. Coverage counts src/, less main.ts, which only mounts the page; the minimum is COVERAGE_MIN in
// the Taskfile, applied by `task coverage`.
export default defineConfig({
  plugins: [svelte()],
  test: {
    environment: "jsdom",
    include: ["tests/**/*.test.ts", "src/**/*.test.ts"],
    env: { TZ: "UTC" },
    coverage: {
      provider: "v8",
      include: ["src/**/*.{ts,svelte}"],
      exclude: ["src/main.ts", "src/**/*.test.ts"],
    },
  },
  resolve: {
    conditions: ["browser"],
  },
});
