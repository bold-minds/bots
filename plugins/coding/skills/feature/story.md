# The story

One feature is one story, one PR, one board card; the owner also calls it a slice. The `feature` skill writes the story, checks it mechanically, puts it in front of the owner, and keeps its Changelog after approval. The owner's word on the shape (2026-09-12): "many short docs where each one is very self-contained… a very long list of slices which are all very short to read and for you to implement and for me to skim in a PR. Slow is smooth, and smooth is fast."

## The slice

- One story, one PR, one board card. A slice that needs two PRs is two slices.
- Every slice is the customer's next step, or builds on a step already live.
- **Every story is end to end and shows a customer something.** A story is sized by taking business out of it, never by taking an end off it. A story that brings new services or infrastructure carries no business rules: it runs the whole path with the plainest content that proves it (a hello page, a "Got it." reply), and the business stories after it put the content in. There are no story types.

## The story

Eight sections, every story, in this order. Nothing else. No prose. No text copied from another story. `template.md` beside this file is the skeleton; `examples.md` shows two finished stories.

| Section | What it holds |
|---|---|
| **Shows** | One sentence: what a customer or the owner can see when it is done. |
| **Journey** | One Given / When / Then walking the slice end to end through the real environment, every customer-visible effect asserted. The end-to-end test and the definition of done. Names an environment only where the journey has to differ in one. |
| **Scenarios** | Given / When / Then in the owner's words, one behaviour each, each naming its requirement id in brackets on its first line. Each scenario is the rule and is the test: the text on the story is the scenario file that runs. |
| **Flow** | An ASCII sequence diagram, symbols on the arrow labels (`--webhook~->`); every piece new in this story, a participant or an arrow, carries `+`. A **Legend** mapping each symbol (`+` new, async, a retry policy, dead-letter). **Components** saying what each participant is and where it lives, never a bare name. Then the connections as a plain numbered list in the order the events occur, each marked New or Existing. |
| **Solution** | How the surface changes, one concrete line each: envs added to CI and app config, packages added, external endpoints added with their URL. Leading indicators of misalignment, not an inventory. "None new" is a valid line. |
| **Observed** | By condition: every non-error log line and what it carries; every product event, its name and what it carries; every alert. Only what this story adds; "None new" is the default. Errors are logged always and not listed. Customer id only, never a phone number, an email or message text. |
| **References** | Every item on this story that needs an ADR, and the ADR that covers it: a new service, vendor or piece of infrastructure, or a business rule that means refactoring a large amount of existing code. ADRs live in the repo. "None" is a valid line. |
| **Changelog** | Empty at approval. Every change after approval is one dated line. |

Observability appears in Observed and nowhere else on the story.

## Rules

- **The story is the whitelist.** What is on it is the slice; what is not, is not. No exclusion list. A line or event not in Observed is not written.
- **Every scenario names a requirement id.** A scenario without one waits until the owner adds the requirement to the requirements file. A PR never adds one. Nothing comes back because it was built before.
- **Validations are scenarios.** Every check, limit, refusal or error message is a Given / When / Then in the owner's words, or it does not exist.
- **Overlap is merged, never deleted.** Two scenarios describing one behaviour become one; the merged scenario carries `(merged)` on its first line until the owner has read it.
- **No ceiling.** At ten scenarios the story splits into two stories. Nothing is trimmed.
- **Copy and numbers on the story are approved by reading.** Change a word on the story and the test changes with it.
- **No number unless it will be measured and proven.** A time, a count, an amount on the story is a claim the Journey or a scenario proves; a number nobody will measure is a guess and does not go on the story.
- **No specific example unless it is labelled as one.** A concrete address, name or value on the story anchors the tests to it; write the class of thing ("a web address"), and label anything concrete "for example".
- **Every ADR in References is named and approved before the story is approved.**
- **Any difference between environments is settled before the first story that depends on it.**
- **Which files a slice may touch is the builder's plan**, never the story.
- **The template changes only with the owner's approval.** When a story cannot say what it needs inside the eight sections, do not bend the story quietly: write it in the shape it needs, put one line under the title, `Template: proposes <the change, one sentence>`, and show it with the story. Approved, the change lands in `template.md`, `check.sh` and this file in the same commit, and the line comes off the story. Refused, the story is rewritten to fit.

## The owner reads four times per story

1. **The story, before anything is built.** Every story. Ten minutes. They edit it or say go.
2. **The task list, with its coverage table.** One row per scenario naming the task that carries it; never a task list alone. They say go.
3. **The PR.** Tests named in their words at the top, the verifier's verdict as the body, the diff below. They merge.
4. **The board card, after launch.** Two dated sentences.

Nothing else reaches them unless they ask. A question that needs them is one line with a default, and only for a one-way door; everything else takes the default and goes in the story's Changelog.

## Process

Stories live under `<root>/docs/product/`: the requirements file is `docs/product/requirements.md`, the stories are `docs/product/stories/<nn>-<name>.md`, their order is `docs/product/<release>.md`, and ADRs are `docs/adr/`. (Claire, 12 Sept.)

1. **Find the step.** Read `docs/product/requirements.md` and `docs/product/<release>.md`. The next story is the customer's next step or builds on the last live one. Name it in the customer's words.
2. **Write the story** at `docs/product/stories/<nn>-<name>.md` from `template.md`. Scenarios from the requirements file or the owner's words only. Vendors as roles in Components, with the ADR in References.
3. **Check it:** `bash ${CLAUDE_PLUGIN_ROOT}/skills/feature/check.sh docs/product/stories/<nn>-<name>.md`. Fix every line it prints. It checks the eight headings and their order, a requirement id on every scenario, a non-empty Journey, an empty Changelog before approval, no line shared with another story in the directory, and no observability vendor named outside Observed.
4. **Show the owner the story**, whole, in the chat, with any `Template: proposes` line first. Wait for their edit or their go. Nothing is built before it.
5. **Add it to `docs/product/<release>.md`** in order, and to the board.
6. **After approval, every change is a dated Changelog line**, including any two-way-door default the build took.

## Building on it

On the owner's go, the run in `SKILL.md` §2 takes the story through the pipeline: the scenarios are the red tests, the Journey is the feature verify, the board is updated at every step. The board is a Claude artifact, one per product: the ship date and days left in the header; one card per story with six stops: **Requirements** (every scenario has its id), **Story** (approved), **Tasks** (the task list and coverage table approved), **Building** (tests green, verified, pushed), **Code Review** (the PR merged), **Launched** (deployed by CI, the Journey passing in production, the card's two sentences written); each stop is done, happening now, waiting on the owner, waiting on a dependency, or not started; a dated line per card, replaced never appended; a "waiting on the owner" box. `docs/product/<release>.md` is its written form; the two say the same thing.
