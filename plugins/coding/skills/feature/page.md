# The page

One feature is one page, one PR, one board card; the owner calls it a slice. The `feature` skill writes the page, checks it mechanically, puts it in front of the owner, and keeps its Changelog after approval. The owner's word on the shape (2026-09-12): "many short docs where each one is very self-contained… a very long list of slices which are all very short to read and for you to implement and for me to skim in a PR. Slow is smooth, and smooth is fast."

## The slice

- One page, one PR, one board card. A slice that needs two PRs is two slices.
- Every slice is the customer's next step, or builds on a step already live.
- The first slice that touches a new service or piece of infrastructure does the least business it can: it proves the wire. The slices after it build on that. There are no page types.

## The page

Eight sections, every page, in this order. Nothing else. No prose. No text copied from another page. `template.md` beside this file is the skeleton; `examples.md` shows two finished pages.

| Section | What it holds |
|---|---|
| **Shows** | One sentence: what a customer or the owner can see when it is done. |
| **Journey** | One Given / When / Then walking the slice end to end through the real environment, every customer-visible effect asserted. The end-to-end test and the definition of done. Names an environment only where the journey has to differ in one. |
| **Scenarios** | Given / When / Then in the owner's words, one behaviour each, each naming its requirement id in brackets on its first line. Each scenario is the rule and is the test: the text on the page is the scenario file that runs. |
| **Flow** | An ASCII sequence diagram, symbols on the arrow labels (`--webhook~->`). A **Legend** mapping each symbol (async, a retry policy, dead-letter). **Components** saying what each participant is and where it lives, never a bare name. Then the connections as a plain numbered list in the order the events occur, each marked New or Existing. |
| **Solution** | How the surface changes, one concrete line each: envs added to CI and app config, packages added, external endpoints added with their URL. Leading indicators of misalignment, not an inventory. "None new" is a valid line. |
| **Observed** | By condition: every non-error log line and what it carries; every product event, its name and what it carries; every alert. Only what this page adds; "None new" is the default. Errors are logged always and not listed. Customer id only, never a phone number, an email or message text. |
| **References** | Every item on this page that needs an ADR, and the ADR that covers it: a new service, vendor or piece of infrastructure, or a business rule that means refactoring a large amount of existing code. ADRs live in the repo. "None" is a valid line. |
| **Changelog** | Empty at approval. Every change after approval is one dated line. |

Observability appears in Observed and nowhere else on the page.

## Rules

- **The page is the whitelist.** What is on it is the slice; what is not, is not. No exclusion list. A line or event not in Observed is not written.
- **Every scenario names a requirement id.** A scenario without one waits until the owner adds the requirement to the requirements file. A PR never adds one. Nothing comes back because it was built before.
- **Validations are scenarios.** Every check, limit, refusal or error message is a Given / When / Then in the owner's words, or it does not exist.
- **Overlap is merged, never deleted.** Two scenarios describing one behaviour become one; the merged scenario carries `(merged)` on its first line until the owner has read it.
- **No ceiling.** At ten scenarios the page splits into two pages. Nothing is trimmed.
- **Copy and numbers on the page are approved by reading.** Change a word on the page and the test changes with it.
- **Every ADR in References is named and approved before the page is approved.**
- **Any difference between environments is settled before the first page that depends on it.**
- **Which files a slice may touch is the builder's plan**, never the page.

## The owner reads three times per slice

1. **The page, before anything is built.** Every page. Ten minutes. They edit it or say go.
2. **The PR.** Tests named in their words at the top, the verifier's verdict as the body, the diff below.
3. **The board card, after merge.** Two dated sentences.

Nothing else reaches them unless they ask. A question that needs them is one line with a default, and only for a one-way door; everything else takes the default and goes in the page's Changelog.

## Process

1. **Find the step.** Read the product's requirements file and `<root>/spec/<release>.md`. The next page is the customer's next step or builds on the last live one. Name it in the customer's words.
2. **Write the page** at `<root>/spec/<nn>-<name>.md` from `template.md`. Scenarios from the requirements file or the owner's words only. Vendors as roles in Components, with the ADR in References.
3. **Check it:** `bash ${CLAUDE_PLUGIN_ROOT}/skills/feature/check.sh <root>/spec/<nn>-<name>.md`. Fix every line it prints. It checks the eight headings and their order, a requirement id on every scenario, a non-empty Journey, an empty Changelog before approval, no line shared with another page under `spec/`, and no observability vendor named outside Observed.
4. **Show the owner the page**, whole, in the chat. Wait for their edit or their go. Nothing is built before it.
5. **Add it to `<root>/spec/<release>.md`** in order, and to the board.
6. **After approval, every change is a dated Changelog line**, including any two-way-door default the build took.

## Building on it

On the owner's go, the run in `SKILL.md` §2 takes the page through the pipeline: the scenarios are the red tests, the Journey is the feature verify, the board is updated at every step. The board is a Claude artifact, one per product: the ship date and days left in the header; one card per slice with a five-stop track (page, approved, building, in review, live); a dated line per card, replaced never appended; a "waiting on the owner" box. `<root>/spec/<release>.md` is its written form; the two say the same thing.
