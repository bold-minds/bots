"""Check a story by command: its form, its requirement ids, look and layout words, numbers, and the people's words
in each broad scenario.

Usage: python3 check-story.py <story file> <file holding what people said> <requirements> <source> ...
                              [--wrong <scenario number> ...] [--broad <scenario number> ...]
                              [--named <scenario number> ...] [--approved]
  requirements: a file, or the text itself; a line that starts with an id (SM-3, R5) gives that id, and a ` *` after
                the id or at the end of the line marks it as added by AI.
  sources:      the design and, when revising, the caller's answers: each a file, a folder (every file under it is
                read) or, when it is no path, the text itself.
  --wrong:      the number of each scenario for a thing that goes wrong.
  --broad:      the number of each scenario that covers several causes of one trouble (read as --wrong too).
  --named:      the number of each broad scenario whose trouble people named (read as --broad too).
  --approved:   the story was approved before this revision, so its Changelog keeps its lines.
It fails:
- Form: no `# <title>` first line; no `Shows:` line, or one holding more than one sentence; no `Design:` line naming
  a path that exists beside the story, above it, or in the current folder (a link starting http counts); no
  `## Journey` with Given, When and Then; no `## Scenarios` with numbered lines; no `## Changelog`; a Changelog with
  lines when the story is not --approved, or with none when it is; a `Defaults taken:` line that is not after the
  Scenarios and before the Changelog.
- Ids: a scenario naming no requirement id, an id the requirements don't hold, or an id the requirements mark as
  added by AI without ` *` after it.
- Look and layout, on the Shows line, the Journey and the Scenarios: a line naming where a thing sits on screen (at the
  top, on the left, in the corner), how it looks (fills teal, a grey button, a size in px, rounded corners, an icon),
  how it moves (slides up, fades out), or a control or gesture (tap, swipe, click, button, chip). Only words about a
  screen are read, so an endpoint, command or function story ("the token comes back in the header", "rounded to the
  nearest whole number", "the red-black tree") passes. Words inside a quote of what people said
  are left out.
- Numbers, on the same lines: a number in neither what people said, the requirements, the sources nor the story's
  own `Defaults taken:`; or one counting a thing those count (tags, characters) that isn't one of their figures for
  it. Scenario numbers, ids, references to a default or a scenario by its number, and numbers inside a quoted example
  ("Top 10 Tips") are left out.
- Things that go wrong: for each --wrong or --broad number, a scenario that does not say what to do as
  `so they <do this>` (or "so the caller", "so I" and the like).
- Named troubles: for each --named number, a scenario whose text after its first "Given" does not open with a quoted
  phrase ("..." or “...”) found word for word in what people said (case and spacing aside). The causes may follow the
  quote, for example in brackets.
Prints each check and what it found, then "FAILS: <n>"; exits 1 when n > 0."""
import os
import re
import sys

args = sys.argv[1:]
approved = "--approved" in args
args = [a for a in args if a != "--approved"]
lists, rest_args, current = {"--broad": [], "--wrong": [], "--named": []}, [], None
for a in args:
    if a in lists:
        current = a
    elif current:
        lists[current].append(a)
    else:
        rest_args.append(a)
named, args = lists["--named"], rest_args
broad = list(dict.fromkeys(lists["--broad"] + named))  # a named trouble is a broad scenario too
wrong = list(dict.fromkeys(lists["--wrong"] + broad))  # a broad scenario is a thing that goes wrong too
if len(args) < 3:
    print(__doc__)
    sys.exit(2)
story_path, said_path, req_arg, sources = args[0], args[1], args[2], args[3:]
fails = []


def fail(msg):
    fails.append(msg)
    print("FAIL: " + msg)


def norm(s):
    return " ".join(s.replace("’", "'").lower().split())


def read_all(path):
    if os.path.isdir(path):
        out = []
        for d, _, fs in os.walk(path):
            for f in sorted(fs):
                try:
                    out.append(open(os.path.join(d, f), encoding="utf-8").read())
                except (UnicodeDecodeError, OSError):
                    pass
        return "\n".join(out)
    if os.path.isfile(path):
        return open(path, encoding="utf-8").read()
    return path  # not a path: the source is the text itself


lines = open(story_path, encoding="utf-8").read().split("\n")
said_text = open(said_path, encoding="utf-8").read()
said = norm(said_text)
req_text = read_all(req_arg)
source_text = "\n".join(read_all(p) for p in sources)
QUOTE = re.compile(r'["“]([^"”]+)["”]')
ID = re.compile(r"\b([A-Z][A-Z0-9]*-\d+)\b")

# Requirement ids, and which ones AI added.
req_ids, ai_ids = set(), set()
for line in req_text.split("\n"):
    m = re.match(r"^\s*(?:[-*]\s+)?\**([A-Z][A-Z0-9]*-\d+|[A-Z]{1,2}\d+)\**(\s*\*)?[:.\s]", line + " ")
    if m:
        req_ids.add(m.group(1))
        if m.group(2) or line.rstrip().endswith(" *"):
            ai_ids.add(m.group(1))
if not req_ids:
    fail("the requirements hold no line that starts with an id")
ID = re.compile(r"\b(" + "|".join(sorted(map(re.escape, req_ids), key=len, reverse=True)) + r"|[A-Z][A-Z0-9]*-\d+)\b") if req_ids else ID

# Sections, in order.
heads, section, sec_of = [], None, []
for line in lines:
    if line.startswith("## "):
        section = line[3:].strip()
        heads.append(section)
    elif line.strip().startswith("Defaults taken"):
        section = "Defaults taken"
        heads.append(section)
    sec_of.append(section)


def body(name):
    return [l for l, s in zip(lines, sec_of) if s == name and not l.startswith("## ") and not l.strip().startswith("Defaults taken")]


# Form.
first = next((l for l in lines if l.strip()), "")
if not re.match(r"^# \S", first):
    fail(f"the first line is not `# <title>`: {first[:80]!r}")
shows = [l for l in lines if l.startswith("Shows:")]
if not shows or not shows[0][6:].strip():
    fail("no `Shows:` line")
elif len(re.findall(r"[.!?](\s|$)", shows[0][6:].strip())) > 1:
    fail(f"the Shows line holds more than one sentence: {shows[0][:120]}")
design = [l for l in lines if l.startswith("Design:")]
if not design:
    fail("no `Design:` line")
else:
    here = os.path.dirname(os.path.abspath(story_path))
    found = False
    for tok in re.findall(r"[\w./{}-]*/[\w./{}-]+|[\w-]+\.\w+", design[0][7:]):
        if tok.startswith("http"):
            found = True
        p = tok.split("#")[0].rstrip(".,)")
        for base in (here, os.path.dirname(here), os.path.dirname(os.path.dirname(here)), os.getcwd()):
            if p and os.path.exists(os.path.join(base, p)):
                found = True
    if re.search(r"https?://", design[0]):
        found = True
    if not found:
        fail(f"the Design line names no path that exists: {design[0][:120]}")
if "Journey" not in heads:
    fail("no `## Journey`")
else:
    j = " ".join(body("Journey"))
    for w in ("Given", "When", "Then"):
        if not re.search(rf"\b{w}\b", j, re.I):
            fail(f"the Journey has no {w}")
scen = [(n, l) for n, (l, s) in enumerate(zip(lines, sec_of), 1) if s == "Scenarios" and re.match(r"^\s*\d+\.\s", l)]
if "Scenarios" not in heads:
    fail("no `## Scenarios`")
elif not scen:
    fail("the Scenarios hold no numbered line")
if "Changelog" not in heads:
    fail("no `## Changelog`")
else:
    log = [l for l in body("Changelog") if l.strip()]
    if approved and not log:
        fail("the story was approved but its Changelog holds no line")
    if not approved and log:
        fail(f"the Changelog holds lines though the story is not approved: {log[0][:80]}")
if "Defaults taken" in heads:
    i = heads.index("Defaults taken")
    if not ("Scenarios" in heads[:i] and "Changelog" in heads[i + 1:]):
        fail("`Defaults taken:` is not after the Scenarios and before the Changelog")

# Ids.
for n, line in scen:
    ids = ID.findall(line)
    if not ids:
        fail(f"line {n}: the scenario names no requirement id: {line.strip()[:100]}")
    for i in set(ids):
        if req_ids and i not in req_ids:
            fail(f"line {n}: {i} is not an id the requirements hold")
        if i in ai_ids and not re.search(rf"\b{re.escape(i)}\b\s*\*", line):
            fail(f"line {n}: {i} was added by AI and has no ` *` after it: {line.strip()[:100]}")
print(f"form and ids: {len(scen)} scenarios, {len(req_ids)} requirement ids ({len(ai_ids)} added by AI)")

# Numbers and look words.
LINKING = {"on", "of", "and", "or", "to", "the", "a", "an", "is", "are", "in", "at", "for", "with", "by", "from",
           "then", "when", "out", "up", "it", "its", "as", "so", "but", "if", "than", "that", "this"}
COUNTED = re.compile(r"(?<![\w.])(\d+(?:\.\d+)?)(?!\w)(?:\s+([A-Za-z]+))?")


def unit(word):
    """The thing a number counts (tags, characters, days), or None when the next word only links."""
    if not word or word.lower() in LINKING:
        return None
    w = word.lower()
    return w[:-1] if w.endswith("s") else w


everything = "\n".join([said_text, req_text, source_text] + body("Defaults taken"))
allowed = set(re.findall(r"\d+(?:\.\d+)?", everything))
counted = {(m.group(1), unit(m.group(2))) for m in COUNTED.finditer(everything) if unit(m.group(2))}

LOOK = [
    # Screen words only, so a story for an endpoint, command or function ("in the header", "the right account") passes.
    (r"\bat the (very )?(top|bottom)\b|\bon the (left|right)\b|\bto the (left|right) of\b", "where it sits on screen"),
    (r"\b(top|bottom)[- ](left|right|corner)\b|\bin the (\w+ )?corner\b", "where it sits on screen"),
    (r"\b\d+(\.\d+)?\s?(px|pt|dp|rem)\b", "a size"),
    (r"\b(fills?|turns?|shown in|goes) (red|green|blue|teal|grey|gray|yellow|orange|purple|pink|navy)\b"
     r"|\b(red|green|blue|teal|grey|gray|yellow|orange|purple|pink|navy) (button|text|background|border|row|bar|badge|dot)s?\b", "a colour"),
    (r"\brounded corners?\b|\bicons?\b|\bfonts?\b|\bitalic\b|\bdrop shadow\b|\boutlined\b", "how it looks"),
    (r"\b(slides?|sliding) (up|down|in|out|over|open)\b|\bfades? (in|out)\b|\banimat\w*", "how it moves"),
    (r"\b(tap(s|ped|ping)?|swip(e|es|ed|ing)|click(s|ed|ing)?|buttons?|chips?|checkbox(es)?|dropdowns?)\b", "a control or gesture"),
]

checked = 0
for n, (line, s) in enumerate(zip(lines, sec_of), 1):
    if line.startswith("## ") or not (line.startswith("Shows:") or s in ("Journey", "Scenarios")):
        continue
    text = QUOTE.sub(lambda m: " " if norm(m.group(1)) in said else m.group(0), line)
    checked += 1
    for pat, what in LOOK:
        m = re.search(pat, text, re.I)
        if m:
            fail(f"line {n} names {what} («{m.group(0)}»), which belongs to the design: {line.strip()[:120]}")
    bare = re.sub(r"^\s*(\d+\.|-)\s", " ", QUOTE.sub(" ", line))
    bare = re.sub(r"\b[A-Za-z]+-\d+\b|\bR\d+\b", " ", bare)
    bare = re.sub(r"\b(defaults?|scenarios?)\s+\d+((\s*(,|and|or|to)\s*)\d+)*", " ", bare, flags=re.I)
    for m in COUNTED.finditer(bare):
        num, u = m.group(1), unit(m.group(2))
        if num not in allowed:
            fail(f"line {n} states {num}, a number in neither what people said, the requirements, the sources nor Defaults taken: {line.strip()[:120]}")
        elif u and (num, u) not in counted and any(cu == u for _, cu in counted):
            fail(f"line {n} states {num} {m.group(2)}, but the inputs give {u} only as "
                 f"{', '.join(sorted(c for c, cu in counted if cu == u))}: {line.strip()[:120]}")
print(f"look, layout and numbers: {checked} lines checked")

def scenario_text(number):
    for i, (line, s) in enumerate(zip(lines, sec_of)):
        if s == "Scenarios" and re.match(rf"^\s*{re.escape(number)}\.\s", line):
            text = [line.strip()]
            for nxt in lines[i + 1:]:  # a scenario may wrap onto indented lines
                if not nxt.strip() or re.match(r"^\s*(\d+\.\s|#|- )", nxt) or not nxt.startswith(" "):
                    break
                text.append(nxt.strip())
            return " ".join(text)
    return None


# Things that go wrong: each ends with what to do.
for number in wrong:
    scenario = scenario_text(number)
    if scenario is None:
        fail(f"no scenario {number}. under ## Scenarios")
    elif not re.search(r"\bso (they|the caller|the person|the owner|I|you|we|it|he|she)\b", scenario, re.I):
        fail(f"scenario {number} goes wrong but does not say what to do, as `so they <do this>`: {scenario[:100]!r}")
    else:
        print(f"ok: scenario {number} says what to do")

# Troubles people named: the Given opens with their words.
for number in named:
    scenario = scenario_text(number)
    if scenario is None:
        continue
    g = re.search(r"\bGiven\b\s*", scenario, re.I)
    if not g:
        fail(f"scenario {number} has no Given")
        continue
    rest = scenario[g.end():]
    q = re.match(r'^["“]([^"”]+)["”]', rest)
    if not q:
        fail(f"scenario {number}: the Given does not open with a quote of people's words: {rest[:80]!r}")
    elif norm(q.group(1).strip().rstrip(".,")) in said:
        print(f"ok: scenario {number}'s Given opens with «{q.group(1).strip()}», found in what people said")
    else:
        fail(f"scenario {number}: «{q.group(1).strip()}» is not word for word in what people said")

print(f"FAILS: {len(fails)}")
sys.exit(1 if fails else 0)
