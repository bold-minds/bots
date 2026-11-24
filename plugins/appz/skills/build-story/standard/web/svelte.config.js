// Read by the Vite plugin, svelte-check and eslint alike, so all three compile the page the same way. Runes mode is
// on for every component: legacy syntax (export let, $:) is a compile error rather than a quiet fallback.
export default {
  compilerOptions: { runes: true },
};
