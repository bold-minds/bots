"""Check a technical design's scenario numbers by command.

Usage: python3 check-design.py <design file> [--earlier <earlier design file>]
  Each list item ("- ...") under ## Packages and functions, ## Schema, routes, commands and events and ## Tests
  must end with the scenario numbers it serves, as digits only: "1, 3", "(2, 3)" or "Scenarios 1, 2." With
  --earlier, only the items the design adds or changes against the earlier design are checked. The checked
  items stop at "Defaults taken".
It fails: an item that does not end with its scenario numbers; and an item with "Journey" or "all" beside its
numbers, as in "(Journey, 1, 3)", "(all, 2)" or "1, 2 and the Journey". An item that only says nothing is added,
that a part is unchanged, that a helper is exercised by the tests above, or that a layer has no tests, is noted,
not failed: it names no part. So is an item ending ":" that heads the items under it.
With --earlier it also fails: a line of the earlier design that named a part now gone from the revision (a dotted
name such as plants.Store.Rename) whose revised line, the closest one in the same section, names no part new to
the design, where it should name the part that takes the gone part's place. It then lists, as "words" lines, the
words each added or changed line adds (+) and drops (-) against its closest earlier line, for the change list.
Prints each failing item, then "FAILS: <n>"; exits 1 when n > 0."""
import re
import sys

SECTIONS = ("## Packages and functions", "## Schema, routes, commands and events", "## Tests")
ENDS = re.compile(r"(?:[Ss]cenarios?\s+)?\(?(\d+(?:\s*(?:,|and)\s*\d+)*)\)?[.;]?\s*$")
WORD = re.compile(r"\b(journey|all)\b", re.I)
NOT_A_PART = re.compile(r"^(no|none|nothing)\b|\bunchanged\b|exercised by the tests above|\bno tests?\b", re.I)


def items(path):
    out, inside, n = [], False, 0
    for n, line in enumerate(open(path, encoding="utf-8"), 1):
        if line.startswith("## "):
            inside = line.strip() in SECTIONS
            continue
        if re.match(r"^\s*(-\s+)?\**Defaults taken", line):  # the defaults follow ## Tests and name no parts
            inside = False
            continue
        if inside and re.match(r"^\s*-\s+\S", line):
            out.append((n, line.rstrip("\n")))
    return out


args = sys.argv[1:]
if len(args) not in (1, 3) or (len(args) == 3 and args[1] != "--earlier"):
    print(__doc__)
    sys.exit(2)
design = args[0]
earlier = {l for _, l in items(args[2])} if len(args) == 3 else set()
fails = 0
for n, line in items(design):
    if line in earlier:
        continue
    text = re.sub(r"^\s*-\s+", "", line)
    m = ENDS.search(text)
    if not m:
        if text.rstrip().endswith(":"):
            print(f"note line {n}: heads the items under it, which carry the numbers: {text[:80]}")
            continue
        if NOT_A_PART.search(text):
            print(f"note line {n}: names no part, so no numbers: {text[:80]}")
            continue
        fails += 1
        print(f"FAIL line {n}: does not end with its scenario numbers: {text[-90:]}")
        continue
    near = text[max(0, m.start() - 25):]
    if WORD.search(near):
        fails += 1
        print(f"FAIL line {n}: Journey or all beside its scenario numbers: {near}")

# Revising: a line of the earlier design that named a part now gone (a dotted name such as plants.Store.Rename,
# found nowhere in the revision) must, in its revised line (the closest line in the same section), name a part
# new to the design: the one that takes its place.
if earlier:
    import difflib

    NAME = re.compile(r"\b[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)+\b")

    def by_section(path):
        out, sec = {}, None
        for line in open(path, encoding="utf-8"):
            if line.startswith("## "):
                sec = line.strip()
            elif sec and line.strip():
                out.setdefault(sec, []).append(line.rstrip("\n"))
        return out

    old_text, new_text = open(args[2], encoding="utf-8").read(), open(design, encoding="utf-8").read()
    old_names = set(NAME.findall(old_text))
    gone = {n for n in old_names if n not in new_text and not n.endswith((".md", ".go", ".sql", ".html", ".yml"))}
    old_secs, new_secs = by_section(args[2]), by_section(design)
    for sec, lines in old_secs.items():
        for line in lines:
            named = sorted(n for n in gone if n in line)
            if not named or line in new_secs.get(sec, []):
                continue
            cands = new_secs.get(sec, [])
            best = max(cands, key=lambda c: difflib.SequenceMatcher(None, line, c).ratio(), default=None)
            if best is None or difflib.SequenceMatcher(None, line, best).ratio() < 0.5:
                continue  # the line is gone; step 9 then asks for another line in the section
            new = [n for n in NAME.findall(best) if n not in old_names]
            if not new:
                fails += 1
                print(f"FAIL {sec}: the earlier line naming {', '.join(named)} (gone) is now \"{best.strip()[:90]}\", "
                      "which names no part new to the design: name the part that takes its place")

    # The words each changed line adds and drops against its earlier line, for the change list: each needs a quote.
    print("## words each changed line adds (+) and drops (-) against its earlier line")
    for sec, lines in new_secs.items():
        olds = [l for l in old_secs.get(sec, []) if l not in lines]
        for line in lines:
            if line in old_secs.get(sec, []):
                continue
            best = max(olds, key=lambda c: difflib.SequenceMatcher(None, line, c).ratio(), default=None)
            if best is None or difflib.SequenceMatcher(None, line, best).ratio() < 0.5:
                print(f"words {sec}: new line: {line.strip()[:120]}")
                continue
            a, b = best.split(), line.split()
            for op, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b).get_opcodes():
                if op != "equal":
                    print(f"words {sec}: " + (f"- \"{' '.join(a[i1:i2])}\" " if i2 > i1 else "")
                          + (f"+ \"{' '.join(b[j1:j2])}\"" if j2 > j1 else ""))
print(f"FAILS: {fails}")
sys.exit(1 if fails else 0)
