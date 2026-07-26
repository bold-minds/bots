# Lens Selection Rules

Rules for the `/check` skill to auto-select which lenses apply to each package.

## Always-On Baseline

Every package gets these 3 lenses regardless of what it does:
- **Security** — vulnerabilities can exist anywhere
- **Staff Engineer** — code quality standards apply everywhere
- **SRE** — operational concerns (error handling, resource management) are universal

## Contextual Lenses

Added based on signals detected in the package's files:

| Signal | How to detect | Lenses to add |
|--------|--------------|---------------|
| Handles HTTP, WebSocket, API, or user input | Imports `net/http`, `fiber`, `gin`, `echo`, `grpc`, `websocket`; or file path contains `handler`, `controller`, `api`, `route`, `endpoint`, `server` | Performance, Architect |
| Has user-facing output (Slack, CLI, UI, email) | Imports `slack`, `discord`, `tview`, `bubbletea`; or file path contains `gateway`, `cli`, `ui`, `frontend`, `template`, `view`, `formatter` | Product Owner, UX |
| Stores data (DB, files, cache) | Imports `database/sql`, `gorm`, `sqlx`, `redis`, `badger`, `bolt`, `leveldb`; or file path contains `store`, `repo`, `persist`, `migrate`, `cache` | Legal, Architect |
| Processes external content (LLM, fetch, scrape) | Imports `openai`, `anthropic`, `llm`, `http.Client`; or file path contains `llm`, `ai`, `fetch`, `scrape`, `mcp`, `crawler`, `connector` | Legal, QA |
| Contains test files or test infrastructure | File name ends in `_test.go`, `_test.py`, `.test.ts`, `.spec.ts`; or path contains `test/`, `mock`, `fake`, `fixture` | QA |
| Defines types, interfaces, or public API | File contains `type.*interface`, `type.*struct` (Go); `export interface`, `export class` (TS); or path contains `types`, `models`, `schema`, `api` | Architect |
| Touches auth, tokens, credentials, or crypto | Imports `crypto`, `oauth`, `jwt`, `bcrypt`; or file path contains `auth`, `token`, `cred`, `secret`, `encrypt`, `sign`, `verify` | QA (adversarial focus) |

## Detection Method

For each package in the file manifest:
1. Read all import statements in the package's files
2. Check file names and paths against the signal patterns
3. Union all matching lenses with the baseline set
4. Deduplicate

## Override

- For `repo` mode: every package gets all 9 lenses (full audit)
- User can force all 9 via `/check branch --all-lenses`
