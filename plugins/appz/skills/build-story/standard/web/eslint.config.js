// The standard web lint, run by `task lint` with --max-warnings 0: ESLint's recommended rules, typescript-eslint's
// strict type-checked rules and Svelte's recommended rules, reading the same svelte.config.js as the build.
import js from "@eslint/js";
import { defineConfig } from "eslint/config";
import svelte from "eslint-plugin-svelte";
import globals from "globals";
import ts from "typescript-eslint";
import svelteConfig from "./svelte.config.js";

export default defineConfig(
  {
    ignores: [
      "coverage/",
      "dist/",
      "node_modules/",
      "playwright-report/",
      "test-results/",
    ],
  },
  js.configs.recommended,
  ts.configs.strictTypeChecked,
  svelte.configs.recommended,
  {
    languageOptions: {
      globals: globals.browser,
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
  {
    files: ["**/*.svelte", "**/*.svelte.ts"],
    languageOptions: {
      parserOptions: {
        parser: ts.parser,
        extraFileExtensions: [".svelte"],
        svelteConfig,
      },
    },
  },
  {
    // The config files in plain JS sit outside tsconfig.json.
    files: ["**/*.js"],
    extends: [ts.configs.disableTypeChecked],
  },
  // PER-REPO, optional: the page's own boundaries as rules, for example no-restricted-imports or
  // no-restricted-globals for the one file that may call the server.
);
