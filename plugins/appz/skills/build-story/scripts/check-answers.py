"""Check build-story's Think answers by command.

Usage: python3 check-answers.py <answers file> <tests file> <base branch> <worktree>
  answers: one line per ## Think question, in this form only
           <question> <verdict>: «<quote>» (<where>); «<quote>» (<where>)
           verdict: Yes | No | Not reached | Changed <a few words>
           Every other word is a quote, so an answer claims only what its quotes show.
           where:   <path>:<line> | <saved file>: `<command>`   (either may end ", <test name>")
           A quote is one whole line of that file, or of the command's output; a saved file
           holds the command's whole output with the command as its first line, for example
           { echo '<command>'; <command>; } > out.txt 2>&1; cat out.txt
           The last question's answer quotes «FAILS: 0», this check's own final line; its where
           names a saved file that exists and starts with this check's command: python running
           check-answers.py with this run's four arguments.
  tests:   one name per line, the tests this PR adds.
It fails: any text outside the form; any quote that isn't a whole line found where it says; any added test
missing from either test answer; in the scenario-check answer, any added test whose lines (a where ending
", <test>") come before every scenario's story line, or after the story line ("<n>. ...") of a scenario that
the numbers after the test's name in its quoted ## Tests line don't include (a ## Tests line with no numbers
after the name is noted, not failed); any changed file missing from the
design-scope answer; and a last answer not in its form.
Paths are tried beside the answers file, in the worktree, then as given.
Prints each check and what it found, then "FAILS: <n>"; exits 1 when n > 0."""
import os
import re
import shlex
import subprocess
import sys

if len(sys.argv) != 5:
    print(__doc__)
    sys.exit(2)
answers_path, tests_path, base, wt = sys.argv[1:5]
skill = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "SKILL.md")
here = os.path.dirname(os.path.abspath(answers_path))
fails = []


def fail(msg):
    fails.append(msg)
    print("FAIL: " + msg)


def norm(s):
    return " ".join(s.split())


def questions():
    out, inside = [], False
    for line in open(skill, encoding="utf-8"):
        if line.startswith("## "):
            inside = line.strip() == "## Think"
        elif inside and line.startswith("- "):
            out.append(line[2:].strip())
    return out


def resolve(p):
    for c in (os.path.join(here, p), os.path.join(wt, p), p):
        if os.path.isfile(c):
            return c
    return None


VERDICT = re.compile(r"(Yes|No|Not reached|Changed (?:[^:«\s]+ ?){1,8}):\s*")
WHERE_LINE = re.compile(r"^([^\s:`,]+):(\d+)(?:, .+)?$")
WHERE_SAVED = re.compile(r"^([^\s:`,]+): `(.+)`(?:, .+)?$")


def items(rest, n):
    """Parse «quote» (where) items separated by "; ". Returns [(quote, where)] or None on a form break."""
    out, i = [], 0
    while True:
        while i < len(rest) and rest[i] == " ":
            i += 1
        if not rest.startswith("«", i):
            fail(f"line {n}: text outside the form: {rest[i:i + 80]!r}")
            return None
        j = rest.find("»", i + 1)
        if j < 0:
            fail(f"line {n}: a quote with no closing »")
            return None
        quote = rest[i + 1:j]
        i = j + 1
        while i < len(rest) and rest[i] == " ":
            i += 1
        if not rest.startswith("(", i):
            fail(f"line {n}: a quote with no (where) after it: «{quote[:60]}»")
            return None
        depth, k, tick = 0, i, False
        while k < len(rest):
            ch = rest[k]
            if ch == "`":
                tick = not tick
            elif not tick and ch == "(":
                depth += 1
            elif not tick and ch == ")":
                depth -= 1
                if depth == 0:
                    break
            k += 1
        if k >= len(rest):
            fail(f"line {n}: a (where) with no closing )")
            return None
        out.append((quote, rest[i + 1:k]))
        i = k + 1
        if rest[i:].strip() == "":
            return out
        if rest[i:].lstrip().startswith(";"):
            i = rest.index(";", i) + 1
            continue
        fail(f"line {n}: text outside the form: {rest[i:i + 80]!r}")
        return None


def whole(quote, line):
    return norm(quote) != "" and norm(quote) == norm(line)


def check_quote(quote, where, n):
    if not norm(quote):
        return fail(f"line {n}: an empty quote")
    m = WHERE_LINE.match(where)
    if m:
        f = resolve(m.group(1))
        if not f:
            return fail(f"line {n}: no file {m.group(1)}")
        lines = open(f, encoding="utf-8", errors="replace").read().splitlines()
        ln = int(m.group(2))
        if 1 <= ln <= len(lines) and whole(quote, lines[ln - 1]):
            return print(f"ok {where}")
        hits = [str(x + 1) for x, l in enumerate(lines) if whole(quote, l)]
        part = [str(x + 1) for x, l in enumerate(lines) if norm(quote) in norm(l)]
        why = f"the whole line is on {','.join(hits)}" if hits else (f"only part of line {','.join(part)}" if part else "not in the file")
        return fail(f"line {n}: not the whole line {where} ({why}): «{quote[:60]}»")
    m = WHERE_SAVED.match(where)
    if m:
        f = resolve(m.group(1))
        if not f:
            return fail(f"line {n}: no saved file {m.group(1)}")
        lines = open(f, encoding="utf-8", errors="replace").read().splitlines()
        if not lines or norm(lines[0]) != norm(m.group(2)):
            return fail(f"line {n}: {m.group(1)}'s first line is not the command `{m.group(2)}`")
        if not any(whole(quote, l) for l in lines[1:]):
            return fail(f"line {n}: not a whole line of the output saved in {m.group(1)}: «{quote[:60]}»")
        return print(f"ok {m.group(1)} (output of its command)")
    fail(f"line {n}: where not in a known form: ({where})")


def this_check(cmd):
    """True when cmd is python running check-answers.py with this run's four arguments, nothing else."""
    try:
        toks = shlex.split(cmd)
    except ValueError:
        return False
    name = os.path.basename
    if not toks or not name(toks[0]).startswith("python"):
        return False
    i = 1
    while i < len(toks) and toks[i].startswith("-"):  # python's own flags, such as -I
        i += 1
    a = toks[i + 1:]
    return i < len(toks) and name(toks[i]) == "check-answers.py" and len(a) == 4 \
        and name(a[0]) == name(answers_path) and name(a[1]) == name(tests_path) \
        and a[2] == base and name(a[3].rstrip("/")) == name(wt.rstrip("/"))


def named(t, line):
    return re.search(r"(?<![A-Za-z0-9_])" + re.escape(t) + r"(?![A-Za-z0-9_])", line) is not None


qs = questions()
lines = [l for l in open(answers_path, encoding="utf-8").read().splitlines() if l.strip()]
print("## one line per question, in the form, each quote a whole line where it says")
print(f"{len(lines)} answer lines, {len(qs)} questions")
if len(lines) != len(qs):
    fail(f"answers file has {len(lines)} lines, not {len(qs)}")
at, quotes_on, items_on = {}, {}, {}
for n, line in enumerate(lines, 1):
    q = next((q for q in qs if line.startswith(q)), None)
    if q is None:
        fail(f"line {n} starts with no question: {line[:60]!r}")
        continue
    if q in at:
        fail(f"line {n} repeats a question: {q}")
    at[q] = n
    rest = line[len(q):].lstrip()
    v = VERDICT.match(rest)
    if not v:
        fail(f"line {n}: no verdict (Yes, No, Not reached or Changed <what>) then ':' after the question")
        continue
    print(f"line {n}: {q} {v.group(1)}")
    got = items(rest[v.end():], n) or []
    quotes_on[n] = {norm(qu) for qu, _ in got}
    items_on[n] = got
    if q == qs[-1]:
        # quotes this check's own final line, which exists only once this run prints it;
        # its saved file already holds the command as its first line while this run writes to it
        m = WHERE_SAVED.match(got[0][1]) if len(got) == 1 else None
        if not (m and norm(got[0][0]) == "FAILS: 0" and this_check(m.group(2))):
            fail(f"line {n}: the last answer must be one quote, «FAILS: 0» (<saved file>: `<python running this check with this run's four arguments>`)")
            continue
        f = resolve(m.group(1))
        first = open(f, encoding="utf-8", errors="replace").readline() if f else ""
        if not f:
            fail(f"line {n}: no saved file {m.group(1)} (save this check with its command as the first line)")
        elif norm(first) != norm(m.group(2)):
            fail(f"line {n}: {m.group(1)}'s first line is not the command `{m.group(2)}`")
        else:
            print(f"ok {m.group(1)} (holds this check's command; its last line is this run's output)")
        continue
    for quote, where in got:
        check_quote(quote, where, n)
for q in qs:
    if q not in at:
        fail(f"no line for: {q}")


def under_prs(where):
    """True when where is <path>:<line> and that line sits under a '## PRs' heading."""
    m = WHERE_LINE.match(where)
    f = resolve(m.group(1)) if m else None
    if not f:
        return False
    head = None
    for x, l in enumerate(open(f, encoding="utf-8", errors="replace").read().splitlines(), 1):
        if l.startswith("## "):
            head = l.strip()
        if x == int(m.group(2)):
            return head == "## PRs"
    return False


print("## the design-change answer quotes this PR's ## PRs line and an output line")
change = at.get(qs[4]) if len(qs) > 4 else None
if change:
    got = items_on.get(change, [])
    if not any(under_prs(w) for _, w in got):
        fail(f"line {change}: quotes no line from the design's ## PRs")
    elif not any(WHERE_SAVED.match(w) for _, w in got):
        fail(f"line {change}: quotes no output line measuring the PR's numbers")
    else:
        print(f"line {change}: has a ## PRs line and an output line")

print("## every test this PR adds, in both test answers")
serve, chk = at.get(qs[0]), at.get(qs[1])
for t in [t.strip() for t in open(tests_path, encoding="utf-8") if t.strip()]:
    hit = [n for n, l in enumerate(lines, 1) if named(t, l)]
    print(f"{t}: lines {' '.join(map(str, hit))}")
    if serve not in hit:
        fail(f"{t} not in the serve-a-scenario answer")
    if chk not in hit:
        fail(f"{t} not in the check-its-scenario answer")

# In the check-its-scenario answer, a test's lines (a where ending ", <test>") sit after the story line of the
# scenario they check (a quote from a .md file starting "<n>. "). That scenario must be one the test's own
# ## Tests line, as the serve-a-scenario answer quotes it, gives: the scenario numbers after its name.
print("## each test beside a scenario its ## Tests line serves")
added = {t.strip() for t in open(tests_path, encoding="utf-8") if t.strip()}
SCEN = re.compile(r"[Ss]cenarios?\s+(\d+(?:\s*(?:,|and)\s*\d+)*)")


def served(t):
    for qu, _ in items_on.get(serve, []):
        m = re.search(r"`%s`" % re.escape(t), qu) or re.search(r"\b%s\b" % re.escape(t), qu)
        if not m:
            continue
        seg = qu[m.end():]
        nxt = re.search(r"`Test\w*`", seg)
        seg = seg[:nxt.start()] if nxt else seg
        s = SCEN.search(seg)
        if s:
            return {int(x) for x in re.findall(r"\d+", s.group(1))}
    return None


cur = None
for qu, wh in items_on.get(chk, []):
    m = re.match(r"\s*(\d+)\.\s", qu)
    if wh.split(":")[0].endswith(".md") and m:
        cur = int(m.group(1))
        continue
    t = wh.rsplit(", ", 1)[1].strip() if ", " in wh else None
    if t not in added:
        continue
    if cur is None:
        fail(f"{t}'s lines come before every scenario's story line in the check-its-scenario answer")
        continue
    sv = served(t)
    if sv is None:
        print(f"note: no scenario numbers found after {t} in the serve-a-scenario answer's quotes")
    elif cur not in sv:
        fail(f"{t} sits beside scenario {cur}'s story line, but its ## Tests line serves {', '.join(map(str, sorted(sv)))}")
    else:
        print(f"ok {t} beside scenario {cur}")

print("## every file this PR changes, quoted in the design-scope answer")
scope = at.get(qs[2])
git = lambda *a: subprocess.run(["git", "-C", wt, *a], capture_output=True, text=True).stdout.split("\n")
changed = sorted({f for f in git("diff", "--name-only", base) + git("ls-files", "--others", "--exclude-standard") if f})
for f in changed:
    if scope and f in quotes_on.get(scope, set()):
        print(f"{f}: quoted on line {scope}")
    else:
        fail(f"{f} not quoted in the design-scope answer")

print(f"FAILS: {len(fails)}")
sys.exit(1 if fails else 0)
