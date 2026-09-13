# The story

One feature is one story, one PR, one board card; the owner also calls it a slice. The `feature` skill writes the story, checks it mechanically, puts it in front of the owner, and keeps its Changelog after approval. The owner's word on the shape (2026-09-12): "many short docs where each one is very self-contained… a very long list of slices which are all very short to read and for you to implement and for me to skim in a PR. Slow is smooth, and smooth is fast."

## The slice

- One story, one PR, one board card. A slice that needs two PRs is two slices.
- Every slice is the customer's next step, or builds on a step already live.
- **Every story is end to end and shows a customer something.** A story is sized by taking business out of it, never by taking an end off it. A story that brings new services or infrastructure carries no business rules: it runs the whole path with the plainest content that proves it (a hello page, a "Got it." reply), and the business stories after it put the content in. There are no story types.

## The story

Four sections, every story, in this order. Nothing else. No prose. No text copied from another story. The owner's words throughout. `shared/hil/templates/story.md` is the skeleton; `shared/hil/examples/` shows two finished stories with their TRDs.

| Section | What it holds |
|---|---|
| **Shows** | One sentence: what a customer or the owner can see when it is done. |
| **Journey** | One Given / When / Then walking the slice end to end through the real environment, every customer-visible effect asserted. The end-to-end test and the definition of done. Names an environment only where the journey has to differ in one. |
| **Scenarios** | Given / When / Then in the owner's words, one behaviour each, numbered from 1, each naming its requirement id in brackets on its first line. Each scenario is the rule and is the test: the text on the story is the scenario file that runs. |
| **Changelog** | Empty at approval. Every change after approval is one dated line. |

**The TRD** (`<nn>-<name>.trd.md`, beside the story) carries the technical half — Flow, Solution, Observed, References, reviewed by the seven lenses and the pre-mortem before the owner sees it, with their findings folded in and nothing of the review left on it — and is engineering's, written after the story is approved and read by the owner as their second read (Claire, 13 Sept: "making the story file short is no prob with me"). Its template and checker are in `shared/hil/` too. Nothing technical appears on the story: no vendor, no package, no endpoint, no log line.

## Rules

- **The story is the whitelist.** What is on it is the slice; what is not, is not. No exclusion list. The TRD's Solution, Observed and References are the whitelist for what the code may add, write and depend on.
- **Every scenario names a requirement id.** A scenario without one waits until the owner adds the requirement to the requirements file. A PR never adds one. Nothing comes back because it was built before.
- **Validations are scenarios.** Every check, limit, refusal or error message is a Given / When / Then in the owner's words, or it does not exist. A TRD review that finds one proposes it; the owner puts it on the story or refuses it.
- **Overlap is merged, never deleted.** Two scenarios describing one behaviour become one; the merged scenario carries `(merged)` on its first line until the owner has read it.
- **No ceiling.** At ten scenarios the story splits into two stories. Nothing is trimmed.
- **Copy and numbers on the story are approved by reading.** Change a word on the story and the test changes with it.
- **No number unless it will be measured and proven.** A time, a count, an amount on the story is a claim the Journey or a scenario proves; a number nobody will measure is a guess and does not go on the story.
- **No specific example unless it is labelled as one.** A concrete address, name or value on the story anchors the tests to it; write the class of thing ("a web address"), and label anything concrete "for example".
- **Every ADR in the TRD's References is named and approved before the TRD is approved.**
- **Any difference between environments is settled before the first story that depends on it.**
- **Which files a slice may touch is the builder's plan**, never the story or the TRD.
- **The template changes only with the owner's approval.** When a story cannot say what it needs inside the four sections, do not bend the story quietly: write it in the shape it needs, put one line under the title, `Template: proposes <the change, one sentence>`, and show it with the story. Approved, the change lands in `shared/hil/templates/story.md`, `shared/hil/check.sh`, `shared/hil/selftest.sh` and this file in the same commit, and the line comes off the story. Refused, the story is rewritten to fit.

## The owner reads five times per story

1. **The story, before anything is designed.** Every story. Ten minutes. They edit it or say go.
2. **The TRD, before anything is built.** Flow, Solution, Observed, References — one cohesive draft, already reviewed. Under it, only what needs their word: a scenario the review proposes (theirs to accept or refuse) and any finding the writer refused (theirs to overrule). They say go.
3. **The coverage table, with each task's success sentence.** One row per scenario naming the task that carries it; never a task list alone. They say go.
4. **The PR.** Tests named in their words at the top, the verifier's verdict as the body, the diff below. They skim; `/software` merges when the PR's CI is green (the owner, 13 Sept: "you will be merging").
5. **The board card, after launch.** One line, two sentences.

Every one of the five has a template, a checker and a cap in `shared/hil/`; the skill that writes it runs the checker first, and nothing that fails is shown. Nothing else reaches them unless they ask. A question that needs them is one line with a default, and only for a one-way door; everything else takes the default and goes in the story's Changelog.

## Process

Stories live under `<root>/docs/product/`: the requirements file is `docs/product/requirements.md`, the stories are `docs/product/stories/<nn>-<name>.md` with their TRDs beside them as `<nn>-<name>.trd.md`, their order is `docs/product/<release>.md`, and ADRs are `docs/adr/`. (Claire, 12 Sept.)

1. **Find the step.** Read `docs/product/requirements.md` and `docs/product/<release>.md`, and `docs/product/survey.md` if one exists. The next story is the customer's next step or builds on the last live one. Name it in the customer's words.
2. **Write the story** at `docs/product/stories/<nn>-<name>.md` from `shared/hil/templates/story.md`. Scenarios from the requirements file or the owner's words only.
3. **Check it:** `bash ${CLAUDE_PLUGIN_ROOT}/shared/hil/check.sh story docs/product/stories/<nn>-<name>.md`. Fix every line it prints. It checks the title and the Shows line, the three headings and their order, a Given/When/Then in the Journey, a requirement id on every scenario and their numbering, no more than ten, an empty Changelog before approval, no vendor named, no line shared with another story in the directory, and the cap.
4. **Show the owner the story**, whole, in the chat, with any `Template: proposes` line first. Wait for their edit or their go. Nothing is designed before it.
5. **Add it to `docs/product/<release>.md`** in order, and to the board.
6. **After approval, every change is a dated Changelog line**, including any two-way-door default the build took and any scenario accepted from the TRD's review.

## Building on it

On the owner's go, the Design stop follows: `trd` writes the TRD from the story and the code, the seven lenses and the pre-mortem review it, and the owner reads it. Then `pipeline` runs on story + TRD: the scenarios are the red tests, the Journey is the feature verify, the board is updated at every stop. The board is a Claude artifact, one per product: the ship date and days left in the header; one card per story with eight stops: **Requirements** (every scenario has its id), **Story** (approved), **Design** (the TRD approved), **Tasks** (the coverage table approved), **Building** (tests green, verified, pushed), **Code Review** (the PR merged), **Test** (the Journey and every scenario passing on the test environment), **Launched** (the same in production, the card written); each stop is done, now, waiting on the owner, waiting on a dependency, or not started; a dated line per card, replaced never appended; a "waiting on the owner" box. `docs/product/<release>.md` is its written form; the two say the same thing.
