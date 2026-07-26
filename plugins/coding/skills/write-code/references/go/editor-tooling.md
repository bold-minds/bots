# Editor Tooling, Parsers & Visual Builders

## Building Languages & DSLs

### When to build a DSL
- Build a DSL when domain experts need to express rules without writing general-purpose code. If the domain fits on a napkin, it fits in a DSL.
- If you're writing a config file with conditionals, you already have a DSL. Decide whether to own it or pretend you don't.
- External DSL (own syntax, own parser) vs internal DSL (host language macros/builder pattern). External gives better error messages and tooling; internal ships faster.
- Lingo (GitLab blog: "A Go micro language framework for building DSLs") -- Go micro-framework for building DSLs. Provides lexer/parser scaffolding so you skip the plumbing and focus on semantics. Good for small, well-bounded grammars.

### Parser techniques -- decision tree
- **Recursive descent (hand-rolled)**: Best when grammar is small, you want full control over error messages, and you don't want a build-time dependency. Pratt parsing for expressions. This is what Rob Pike advocates.
- **ANTLR**: Best when grammar is complex (50+ rules), you need multiple target languages, or you want a generated visitor/listener pattern. ANTLR 4 generates LL(*) parsers. The grammar file IS the specification. Downsides: generated code is ugly, debugging requires understanding ANTLR internals, Java dependency at build time.
- **PEG parsers** (pigeon for Go): Middle ground. Grammar-driven but simpler than ANTLR. No left recursion.
- **Tree-sitter**: Best for incremental parsing (editor integration). Generates C parsers. Used by Neovim, Zed, GitHub. Not for transpilers -- for syntax highlighting and structural queries.

### Rob Pike's lexer approach (Lexical Scanning in Go)
- State functions: `type stateFn func(*lexer) stateFn`. Each state returns the next state. No switch statement spaghetti.
- The lexer runs in its own goroutine, emits tokens on a channel. Parser consumes from channel. Clean separation.
- `emit()`, `next()`, `peek()`, `backup()`, `accept()`, `acceptRun()` -- the minimal API.
- Key insight: the lexer is a state machine where states are functions, not enum values. More extensible, more readable.
- This pattern works for any tokenization problem, not just programming languages. Config files, log parsing, protocol decoding.

### Go lexer generator: nex (blynn/nex)
- A lex-like tool that generates Go lexers from regex rules. Each rule pairs a regex with a Go action block. Output is a standalone Go scanner with no runtime dependency.
- Useful when you want lex/flex style rule files but pure Go output. Contrast with Pike's hand-rolled approach -- nex is for when you have many token rules and want a declarative spec.

```go
// nex rule file structure (simplified from blynn/nex):
// Each regex -> Go code block. The generator produces a state machine.
//
// In nex.go, the core abstraction:
type rule struct {
    regex     []rune   // the pattern
    code      string   // Go code to execute on match
    startCode string   // code at start of rule set
    endCode   string   // code at end of rule set
    kid       []*rule  // child rules (for nested states)
    id        string   // rule identifier
}

// Error handling is exhaustive -- every malformed input gets a named error:
var (
    ErrUnmatchedLpar       = errors.New("unmatched '('")
    ErrUnmatchedRpar       = errors.New("unmatched ')'")
    ErrBadRange            = errors.New("bad range in character class")
    ErrExtraneousBackslash = errors.New("extraneous backslash")
    // ... one error per failure mode, not generic "parse error"
)
```

**Key insight:** The exhaustive error catalog is the pattern worth stealing. Every syntax error the lexer can encounter has a specific, named error. Users never see "unexpected token" -- they see exactly what went wrong. Apply this to any parser you build.

### Transpiler methodology (VBA to VB.NET pattern)
- Three-phase architecture: Parse source -> Transform AST -> Emit target. Never skip the AST phase by doing string manipulation.
- Source-to-source translation preserves structure. Map each source construct to its closest target equivalent.
- Handle the 80% with direct mappings, flag the 20% that needs human review. Don't try to auto-translate everything.
- Preserve comments and formatting where possible -- developers need to read the output.
- Build a compatibility shim layer for runtime differences rather than inlining translations everywhere.

## AST Fundamentals

### What they are
- An AST strips syntax noise (parentheses, semicolons, whitespace) and keeps semantic structure. It's the meaning of the code as a tree.
- Contrast with CST (Concrete Syntax Tree / parse tree): CST keeps everything including syntax tokens. CSTs are for formatters and linters that need to preserve or reason about formatting. ASTs are for compilers, analyzers, and transformers.
- Every node has a type and children. Leaf nodes are literals/identifiers. Interior nodes are operations/declarations.

### Working with ASTs
- **Visitor pattern**: Walk the tree, dispatch on node type. ANTLR generates these. Good for read-only analysis (linting, metrics, search).
- **Transformer pattern**: Walk the tree, return modified nodes. Functional style -- never mutate in place. Good for transpilers, optimizers, macro expansion.
- **astexplorer.net**: Paste code, pick a parser, see the AST. Supports JS (babel, acorn, typescript), CSS, HTML, GraphQL, and more. Use it to understand any parser's output format before writing visitors. Essential tool -- bookmark it.
- Source maps: When transforming ASTs, preserve source location info on every node. Without it, error messages point to generated code and debugging is miserable.

### Go-specific AST patterns
- `go/ast`, `go/parser`, `go/printer`, `go/token` -- stdlib packages. Production-grade, used by `gofmt`, `go vet`, `guru`.
- `go/parser.ParseFile(fset, filename, src, mode)` returns `*ast.File`. Use `parser.ParseComments` to include comments.
- `ast.Inspect(node, func(n ast.Node) bool)` -- depth-first traversal. Return true to recurse into children.
- `ast.Walk(visitor, node)` -- visitor interface with `Visit(node) Visitor`. Return nil to skip subtree.
- `golang.org/x/tools/go/ast/astutil` -- cursor-based rewriting. `astutil.Apply` with pre/post functions for transforms.
- `golang.org/x/tools/go/packages` -- higher-level than `go/parser`. Handles modules, build tags, type info. Use this for real tools, not raw `go/parser`.
- `go/types` for semantic analysis after parsing. Type-checking gives you what `ast` alone can't: resolved identifiers, type assertions, interface satisfaction.

## Code Editor Integration

### CodeMirror 6 vs Monaco -- when to use which

| | CodeMirror 6 | Monaco |
|---|---|---|
| **Size** | ~150KB (tree-shakeable) | ~2-5MB (monolithic) |
| **Architecture** | Functional, immutable state | OOP, VS Code internals |
| **Mobile** | Works | Broken/unsupported |
| **Customization** | Everything is an extension | Limited to VS Code APIs |
| **Collab editing** | Built for it (OT-ready state model) | Bolted on, fragile |
| **Language support** | Lezer (incremental parser), you build it | TextMate grammars or Monarch (regex-based) |
| **TypeScript** | First-class | First-class (it's the VS Code editor) |
| **When to pick** | Embedded editors, custom DSLs, mobile, lightweight | Need VS Code feel, existing TextMate grammars, complex IntelliSense |

### CodeMirror 6 custom language support
- CM6 uses Lezer for parsing -- incremental, error-tolerant, generates concrete syntax trees.
- Define grammar in `.grammar` file, compile with `@lezer/generator`. The grammar drives highlighting, folding, indentation.
- Extension stack: `LanguageSupport` bundles parser + syntax highlighting + completion + linting. Compose with other extensions.
- State is immutable. Changes produce transactions. Transactions produce new state. This is why it handles collab editing cleanly.
- `EditorView.updateListener` for reacting to changes. `StateEffect` for custom state transitions.
- System guide and reference manual are dense but complete. Read the System Guide first for the mental model, then reference manual for specifics.

### Monaco custom language support (4-step pattern)
1. Register language: `monaco.languages.register({ id: 'myLang' })`
2. Define tokenizer: `monaco.languages.setMonarchTokensProvider('myLang', monarchDefinition)` -- Monarch is Monaco's regex-based tokenizer. Simpler than TextMate but less portable.
3. Register completion provider: `monaco.languages.registerCompletionItemProvider` -- return `CompletionItem[]` with insertText, documentation, kind.
4. Wire up validation: Use a web worker running your real parser (ANTLR, hand-rolled), post diagnostics back via `monaco.editor.setModelMarkers`.

### Monaco + ANTLR integration pattern
- Run ANTLR parser in a web worker. Don't block the UI thread with parsing.
- On every edit, debounce, send source to worker, worker parses and returns: (a) error diagnostics, (b) token stream for semantic highlighting, (c) symbol table for completion.
- Map ANTLR error tokens to Monaco `IMarkerData`. Map ANTLR token types to Monaco `SemanticTokenTypes`.
- This gives you a real parser backing a rich editor -- far better than regex-only highlighting.

### Syntax highlighting performance (VS Code deep dive)
- VS Code uses TextMate grammars (Oniguruma regex engine via WASM). Expensive -- can dominate frame time on large files.
- Optimization: only tokenize visible lines + buffer. Invalidate on edit, re-tokenize incrementally.
- Semantic highlighting (from language server) overlays on top of TextMate -- provides type-aware coloring.
- Key lesson: syntax highlighting is a rendering problem, not just a parsing problem. Viewport-aware tokenization matters.

## State Machines & Rule Engines

### When state machines solve problems
- Any time you have: modes/states, transitions between them, guards on transitions, and you're currently using a bag of booleans -- use a state machine.
- UI workflows (multi-step forms, editor modes, connection states), protocol implementations, game logic, approval flows.
- State machines make impossible states impossible. A bag of booleans allows `{ loading: true, error: true, data: "hello" }`. A state machine does not.
- "The Rise of the State Machines" (Smashing Magazine) -- covers XState patterns for UI. Key insight: statecharts (hierarchical state machines) handle the complexity explosion that flat state machines hit at ~10 states.

### Libraries

**Go:**
- `qmuntal/stateless` -- .NET Stateless port for Go. Fluent API: `sm.Configure(stateA).Permit(triggerX, stateB)`. Supports guards, entry/exit actions, substates. Mature, well-tested.
- Good for: backend workflow engines, order state management, approval pipelines.

**JavaScript/TypeScript:**
- XState -- the gold standard. Actor model, statecharts, visualizer. Heavy but correct.
- For simpler needs, a `switch` on state + action type is fine. Don't import XState for a loading spinner.

**Visualization:**
- `sverweij/state-machine-cat` -- text-to-SVG state chart renderer. Input: `initial -> "loading" : fetch; "loading" -> "done" : success;`. Output: SVG diagram. Good for documentation, design review.
- Integrates with CLI and has an online editor. Use it to visualize before implementing.

### Rule engines (Go)
- `hyperjumptech/grule-rule-engine` -- Rete-algorithm rule engine for Go. Define rules in GRL (Grule Rule Language) or load from JSON/YAML.
- When to use: Business rules that change faster than deploy cycles, complex conditional logic that domain experts need to author, pricing/discount/eligibility rules.
- When NOT to use: Simple if/else chains, performance-critical hot paths (rule engines add overhead), rules that developers own anyway.
- Alternative: just use Go functions. A `[]Rule` where `Rule` has `Match(ctx) bool` and `Apply(ctx) error` is often enough.

## Visual Builder Libraries

### Flow diagram / node editors

| Library | Framework | Stars | Key trait |
|---|---|---|---|
| **Drawflow** (`jerosoler/Drawflow`) | Vanilla JS | 4k+ | Zero dependencies, simple API. HTML nodes, connections, import/export JSON. Best for: quick prototypes, simple flow editors. Limitation: no built-in layout algorithms. |
| **Svelvet** (`open-source-labs/Svelvet`) | Svelte | 2k+ | Svelte-native flow diagrams. Component-based nodes, reactive connections. Best for: Svelte apps needing flow UIs. Younger ecosystem than React Flow. |
| **React Flow** (not in list but dominant) | React | 20k+ | Industry standard for React. Mention because any comparison without it is incomplete. |

### Drag and drop

| Library | Approach | Best for |
|---|---|---|
| **interact.js** | Pointer events, no DOM manipulation | Resize + drag + multi-touch. Framework-agnostic. Handles inertia, snapping, restricting. Most flexible option. |
| **Shopify/draggable** | Events + mirrors | Sortable lists, swappable containers. Shopify-quality polish. Modular (Sortable, Swappable, Droppable as separate imports). |
| **dflex-js/dflex** | DOM diffing, no cloning | Performance-focused. Transforms DOM without cloning elements. Animated transitions by default. Good for large lists. |

### Grid layout
- **Svelte-grid** -- responsive grid layout for Svelte. Draggable, resizable grid items. Widget dashboards, customizable layouts.
- Compare with: `react-grid-layout` (React equivalent, more mature), CSS Grid (if you don't need drag-to-rearrange).

### Decision framework for visual builders
- **Need a flow/node editor?** React Flow (React) or Svelvet (Svelte) or Drawflow (vanilla). React Flow has the largest ecosystem by far.
- **Need sortable lists?** Shopify/draggable or SortableJS. Both handle the common case well.
- **Need freeform drag with resize/snap?** interact.js. It's the Swiss army knife.
- **Need a grid dashboard?** svelte-grid (Svelte) or react-grid-layout (React).
- **Building something complex?** Combine: flow editor for the canvas + interact.js for fine-grained drag behavior + your own state machine for modes.

---

## Integration Wiring Patterns

Quick-reference patterns for getting editor components wired up and running. Not tutorials -- just the shape of the integration so you don't have to rediscover it each time.

### CodeMirror 6 Basic Setup

Minimal wiring to get CM6 running:

1. `EditorState.create({ doc: initialContent, extensions: [...] })` -- create state with your extension stack.
2. `new EditorView({ state, parent: domElement })` -- attach to a DOM element.
3. Use the `basicSetup` extension (from the `codemirror` package, or `@codemirror/basic-setup` in older versions) to get line numbers, bracket matching, syntax highlighting, keybindings, etc. in one import.

**Key gotcha**: CM6 is modular by design. Unlike CM5 or Monaco, *nothing* is included by default. No keybindings, no line numbers, no undo -- unless you add them via extensions. The `basic-setup` bundle exists specifically to avoid starting from zero, but if you need a stripped-down editor (e.g., single-line input), skip it and compose only what you need.

**Extension ordering matters**: Extensions are applied in array order. Later extensions can override earlier ones. Put your custom keybindings before `basic-setup` if you want them to take priority.

### CodeMirror 6 Custom Language

The `lang-example` pattern for adding a custom language to CM6:

1. **Define a Lezer grammar** in a `.grammar` file. Lezer is incremental and error-tolerant -- it keeps parsing even when the input is broken.
2. **Generate the parser**: `@lezer/generator` compiles `.grammar` to a JS parser module at build time.
3. **Create a `LanguageSupport` object** that bundles: the Lezer parser, syntax highlighting (via `styleTags` mapping grammar node names to highlight classes), completion source, and linting source.
4. **Wire into CM6** by adding the `LanguageSupport` object to your extensions array.

The grammar file is the single source of truth. Highlighting, folding, and indentation all derive from the parse tree it produces.

### Monaco + Svelte Wiring

Monaco requires web workers for language services (TypeScript, JSON, CSS intellisense). In Svelte/SvelteKit, this requires explicit configuration:

1. **The `userWorker.ts` pattern**: Import worker entry points directly from Monaco's ESM build:
   - `monaco-editor/esm/vs/editor/editor.worker` (base)
   - `monaco-editor/esm/vs/language/typescript/ts.worker` (TS/JS)
   - `monaco-editor/esm/vs/language/json/json.worker` (JSON)
   - `monaco-editor/esm/vs/language/css/css.worker` (CSS)
2. **Set `self.MonacoEnvironment.getWorker`** to return the correct worker based on the language label.
3. **Vite/Rollup config**: Workers must be handled by the bundler. In Vite, use `?worker` import suffix or configure `optimizeDeps.include` for Monaco's ESM modules.
4. **SvelteKit SSR caveat**: Monaco is browser-only. Wrap the editor component in `{#if browser}` or use dynamic import with `ssr: false` in the page load.

### Monaco Custom Language (4 Steps)

1. **Register language**: `monaco.languages.register({ id: 'myLang' })` -- declares the language ID.
2. **Define tokenizer**: `monaco.languages.setMonarchTokensProvider('myLang', { tokenizer: { root: [...rules] } })` -- Monarch is regex-based. Each rule maps a regex to a token type (keyword, string, comment, etc.). Simpler than CM6's Lezer but no parse tree -- just flat token classification.
3. **Register completion provider**: `monaco.languages.registerCompletionItemProvider('myLang', { provideCompletionItems(model, position) { ... } })` -- return `CompletionItem[]` with `insertText`, `kind`, `documentation`.
4. **Register hover provider**: `monaco.languages.registerHoverProvider('myLang', { provideHover(model, position) { ... } })` -- return `Hover` with markdown contents for the token at position.

**Monarch vs Lezer tradeoff**: Monarch gives you syntax highlighting with a flat regex ruleset -- fast to write, no build step. Lezer gives you a real parse tree -- needed for structural operations (folding, indentation, refactoring) but requires a grammar file and build-time generation.
