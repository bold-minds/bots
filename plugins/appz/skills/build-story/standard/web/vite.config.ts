import { svelte } from "@sveltejs/vite-plugin-svelte";
import { defineConfig } from "vite";

// PER-REPO, optional: build.outDir when the server embeds or serves the page from another folder.
export default defineConfig({
  plugins: [svelte()],
});
