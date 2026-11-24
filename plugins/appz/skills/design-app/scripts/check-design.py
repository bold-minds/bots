"""Check a design round's marks and Think answers by command.

Usage: python3 check-design.py <round folder> <said file> [--markup <file>] [--earlier <round folder>]
                               [--answers <file>]
  round folder: round-<N>/, holding system.md and the round's pages
  said file:    what people said, as text
  markup:       the markup notes, when revising
  earlier:      the earlier round, when revising; lines it already held are not read
  answers:      this skill's Think answers, one list item per question, each holding
                "<quoted line>" (<where it is>)

It fails:
  - a decisions row whose From holds no ` *` and no quote, or a quote not in the said file or the
    markup, or a quote from a sentence asked as a question or said with a maybe, or a Decision that
    holds words its quotes don't (small words aside);
  - a line in system.md, outside its tables, that holds a pick (or, in its gaps, a default) and no ` *`;
  - a line on a page, or in system.md outside its tables, that holds a number or a rule word and
    holds neither a ` *` nor a quote from the said file or the markup;
  - a code line that builds or shows an error (errors.New, Errorf, raise, throw, an ...Error or
    ...Exception call, an "error" or "message" key, an "Error:" output line) whose message has
    no ` *` on the line (in a comment);
  - a literal a page states (a number, with or without a unit; a quoted string, an error's message
    included; the name of a limit; in code that defines a value or an error, any quoted string and
    the name defined) found neither in the said file or the markup nor in a decisions row marked
    ` *` (a row may give a message with a slot, "back by <date>"); in an example call or sample
    only its result code and error messages are read, and a case named "such as" is left out;
  - a message screens.html shows (a sentence in its text or script) whose fixed words are in neither,
    or a number in screen text about a limit ("Up to 12 photos") in neither; labels are left to the
    read-back of step 8, since a label and a sample entry look alike;
  - with screens.html in the round, an Interface that gives no screens.html#<id> line with a real id,
    or names an id screens.html doesn't hold;
  - when revising, a round with no changes.md, a markup note (a list item, or a line with a quote)
    changes.md doesn't quote, or a changed file changes.md doesn't name;
  - an answer with no "<quoted line>" (<where it is>), or a quote found in no file of the design
    folder, the said file or the markup.
Code blocks, headings, `Said:` lines, the Interface section and changes.md are not read.
Prints each FAIL, then "FAILS: <n>"; exits 1 when n > 0."""
import html
import os
import re
import sys

args = sys.argv[1:]
opts = {}
for flag in ("--markup", "--earlier", "--answers"):
    if flag in args:
        i = args.index(flag)
        opts[flag] = args[i + 1]
        del args[i:i + 2]
if len(args) != 2:
    print(__doc__)
    sys.exit(2)
round_dir, said_path = args
said = open(said_path, encoding="utf-8").read()
markup = open(opts["--markup"], encoding="utf-8").read() if "--markup" in opts else ""
fails = []

SMALL = set("""a an the and or but of to in on at by for from with as is are was be been can could will would
it its this that these those there their they them who what which when where any each every all some
no not so if then than into onto per via up out over our we us you your he she his her i me my""".split())
RULE = re.compile(r"\d|\bErr[A-Z]\w*|\b(returns?|must|limit\w*|never|always|at most|up to|cut|drops?|dropped|"
                  r"unchanged|required|maximum|minimum|max|min|sorted)\b", re.I)
LIST_MARK = re.compile(r"^(\d+[.)]|[-*+])\s+")
STAR = re.compile(r"(?<![*\w])\*(?![*\w])")  # a lone ` *` mark, not markdown bold or a list bullet


def fail(msg):
    fails.append(msg)
    print("FAIL: " + msg)


def norm(s):
    s = s.replace("’", "'").replace("‘", "'").replace("“", '"').replace("”", '"').replace("…", "...")
    return " ".join(s.lower().replace("`", "").split())


SOURCES = norm(said + "\n" + markup)


def words(s):
    return {w.rstrip("s") for w in re.findall(r"[a-z0-9]+", norm(s)) if w not in SMALL}


def quotes(s):
    """Text between pairs of double quotes; a span that starts or ends with a space is the text between two quotes."""
    s = s.replace("“", '"').replace("”", '"')
    return [q for q in re.findall(r'"([^"]+)"', s) if q.strip() and q == q.strip()]


def cited(s):
    """Quotes an answer cites: from the first double quote after the last citation to a double quote a ( follows."""
    s = s.replace("“", '"').replace("”", '"')
    out, prev = [], 0
    for m in re.finditer(r'"(?=\s*\()', s):
        o = s.find('"', prev, m.start())
        if o != -1:
            out.append(s[o + 1:m.start()])
        prev = m.start() + 1
    return [q for q in out if q.strip()]


def quote_parts(q):
    return [p.strip(" .,;:") for p in re.split(r"\.\.\.", norm(q)) if p.strip(" .,;:")]


def in_sources(q):
    parts = quote_parts(q)
    return bool(parts) and all(p in SOURCES for p in parts)


HEDGE = re.compile(r"\b(maybe|perhaps|not sure|might|probably|i think|i guess|unsure)\b")


def hedged(q):
    """True when the sentence a quote comes from is asked as a question or holds a maybe."""
    for p in quote_parts(q):
        i = SOURCES.find(p)
        if i < 0:
            continue
        start = max(SOURCES.rfind(c, 0, i) for c in '.!?"') + 1
        m = re.search(r'[.!?"]', SOURCES[i + len(p):])
        sentence = SOURCES[start:i + len(p) + (m.end() if m else 0)]
        if "?" in sentence or HEDGE.search(sentence):
            return True
    return False


def earlier_lines(name):
    if "--earlier" not in opts:
        return set()
    p = os.path.join(opts["--earlier"], name)
    return {l.strip() for l in open(p, encoding="utf-8")} if os.path.isfile(p) else set()


def check_row(where, cells, hdr):
    fi = next((i for i, c in enumerate(hdr) if c.startswith("from")), None)
    if fi is None or fi >= len(cells):
        return
    frm, dec = cells[fi], cells[0]
    if STAR.search(frm):
        return
    qs = quotes(frm)
    if not qs:
        fail(f"{where}: row '{dec[:60]}': From holds no quote and no ` *`")
        return
    for q in qs:
        if not in_sources(q):
            fail(f"{where}: row '{dec[:60]}': quote not in what people said or the markup: \"{q[:60]}\"")
        elif hedged(q):
            fail(f"{where}: row '{dec[:60]}': its quote is asked as a question or said with a maybe: "
                 f"\"{q[:60]}\"; end From with ` *`")
    extra = sorted(words(dec) - words(" ".join(qs)))
    if extra:
        fail(f"{where}: row '{dec[:60]}': Decision words its quotes don't hold: {', '.join(extra)}; "
             "copy the quote's words, or split those into a row marked ` *`, or end From with ` *`")


# a code line that builds or shows an error: errors.New / Errorf, raise, throw, a call to an ...Error or
# ...Exception type, an "error" or "message" key in a body, or a line of output starting "Error:"
ERR_DEF = re.compile(r"errors?\.New\b|Errorf\b|\braise\b|\bthrow\b|\w*(?:Error|Exception)\s*\(|"
                     r"[\"'](?:error|message)[\"']\s*:|^\s*error:", re.I)
_starred = None


def starred_rows():
    """The text of every decisions row in the round whose From ends in ` *`, normalised."""
    global _starred
    if _starred is None:
        rows = []
        for name in os.listdir(round_dir):
            if name.endswith(".md"):
                for l in open(os.path.join(round_dir, name), encoding="utf-8"):
                    if l.strip().startswith("|") and STAR.search(l):
                        rows.append(norm(l))
        _starred = "\n".join(rows)
    return _starred


def check_changes():
    """When revising: a change list that quotes each markup note and names each file that changed."""
    ch = os.path.join(round_dir, "changes.md")
    if not os.path.isfile(ch):
        fail(f"{ch}: no change list")
        return
    text = norm(open(ch, encoding="utf-8").read())
    for n, line in enumerate(markup.split("\n"), 1):
        s = line.strip()
        qs = [q for q in quotes(s) if len(q) >= 12]
        if s.startswith("#") or not (LIST_MARK.match(s) or qs):
            continue  # a note is a list item, or a line that quotes what to change
        note = norm(qs[0] if qs else LIST_MARK.sub("", s))[:40]
        if note and note not in text:
            fail(f"{ch}: markup note on line {n} is not quoted: \"{note}\"")
    for name in sorted(os.listdir(round_dir)):
        new, old = os.path.join(round_dir, name), os.path.join(opts["--earlier"], name)
        if name != "changes.md" and os.path.isfile(new) and os.path.isfile(old):
            if open(new, "rb").read() != open(old, "rb").read() and name.lower() not in text:
                fail(f"{ch}: {name} changed and the change list doesn't name it")


CITE = re.compile(r"\b(msg|message|issue|para|paragraph|note|line|round|step|act|section|row|item|question|q)s?\s+"
                  r"(\d+\s*(to|and|or|,|-)\s*)?$", re.I)
CALL = re.compile(r"(GET|POST|PUT|PATCH|DELETE|HEAD)\s|\$\s|>\s")  # an example request or command line
DEFINES = re.compile(r"\b(const|var|let|final|static|default)\b|[^=!<>:]=[^=>]")
SHOWN = r"(such as|e\.g\.|for example|for instance)"
LIMIT = re.compile(r"\b(limit\w*|max\w*|min\w*|cap|caps|capped|timeout\w*|quota\w*|at most|up to|longest|shortest)\b", re.I)


def literals(s, code):
    """The literals a line states: numbers (a unit after one included), double-quoted strings, the name of a limit, and
    in code single- or back-quoted strings and the name a line defines; in prose, back-quoted spans of three or more
    words or holding ": " (wording, not a name)."""
    s = s.replace("“", '"').replace("”", '"')
    keys = set(re.findall(r'"([^"\n]*)"\s*:', s)) if code else set()  # a JSON key names a field; its value is stated
    out = [q for q in re.findall(r'"([^"\n]*)"', s) if len(q.strip()) >= 3 and q not in keys]
    if code:
        out += [a or b for a, b in re.findall(r"'([^'\n]*)'|`([^`\n]*)`", s) if len((a or b).strip()) >= 3]
        out += re.findall(r"\b(?:const|var|let|final|static)\s+([A-Za-z_]\w*)", s)
        out += [n for n in re.findall(r"\b([A-Za-z_]\w*)\s*:?=", s) if LIMIT.search(re.sub(r"([a-z])([A-Z])", r"\1 \2", n))]
    else:
        out += [b for b in re.findall(r"`([^`\n]+)`", s)
                if not re.search(r"[\"=(){}\[\]]", b) and (len(b.split()) >= 3 or ": " in b)]
        if LIMIT.search(s):  # the name a limit goes by, back-quoted or bare (CamelCase or UPPER_CASE)
            names = re.findall(r"`([A-Za-z_][\w.]*)`", s) + re.findall(r"\b([A-Z][a-z]+[A-Z]\w*|[A-Z][A-Z0-9]*_[A-Z0-9_]+)\b", s)
            out += [b for b in names if LIMIT.search(re.sub(r"([a-z])([A-Z])", r"\1 \2", b).replace("_", " "))
                    or re.fullmatch(r"[A-Z][A-Z0-9_]{2,}", b)]
    out = [q for q in out if not re.fullmatch(r"\s*<[^>]*>\s*", q)]
    bare = re.sub(r'"[^"\n]*"|`[^`\n]*`', " ", s)
    if not code:  # a case named to show a rule ("such as ...") is an example, not a rule
        out = [q for q in out if not re.search(SHOWN + r"\W+(\w+\W+){0,3}?[\"`]" + re.escape(q), s, re.I)]
    for m in re.finditer(r"(?<![\w.#/-])\d+(?:\.\d+)?(?![\d.]*\d|-\d)", bare):
        if not CITE.search(bare[:m.start()]) and not re.match(r"\s*px\b", bare[m.end():]):
            out.append(m.group(0))
    return out


def traced(lit):
    """A literal comes from what people said or the markup, or from a decisions row marked ` *`."""
    if re.fullmatch(r"\d+(?:\.\d+)?", lit):
        num = r"(?<![\d.])" + re.escape(lit) + r"(?![\d.]*\d)"
        return bool(re.search(num, SOURCES) or re.search(num, starred_rows()))
    n = norm(lit).strip(" .,;:")
    return not n or in_sources(lit) or n in starred_rows() or any(t.fullmatch(n) for t in templates())


_templates = None


def templates():
    """Messages a starred decisions row gives with a slot, such as "back by <date>", as patterns any filling matches."""
    global _templates
    if _templates is None:
        spans = re.findall(r'"([^"]*<[^>]+>[^"]*)"|`([^`]*<[^>]+>[^`]*)`', starred_rows().replace("“", '"').replace("”", '"'))
        _templates = [re.compile(".+?".join(re.escape(p) for p in re.split(r"<[^>]+>", (a or b).strip(" .,;:"))))
                      for a, b in spans]
    return _templates


def check_literals(where, s, code):
    for lit in dict.fromkeys(literals(s, code)):
        if not traced(lit):
            fail(f"{where}: literal \"{lit[:60]}\" is in no quote of what people said and in no decisions row "
                 "marked ` *`; add the row, or copy the quote's words")


def check_round():
    for name in sorted(os.listdir(round_dir)):
        path = os.path.join(round_dir, name)
        if not name.endswith(".md") or name == "changes.md":
            continue
        old = earlier_lines(name)
        hdr, section, fence, prev = None, "", False, ""
        for n, line in enumerate(open(path, encoding="utf-8"), 1):
            line, s, where = line.rstrip("\n"), line.strip(), f"{path}:{n}"
            example = "example" in section  # example calls and samples show the design at work; they state nothing
            if s.startswith("```"):
                fence = not fence
                continue
            if fence or (line.startswith(("    ", "\t")) and not LIST_MARK.match(s)):
                if s not in old and ERR_DEF.search(s):  # code: an error's message wording is the design's own
                    msgs = [a or b or c for a, b, c in re.findall(r'"([^"]{3,})"|\'([^\']{3,})\'|`([^`]{3,})`', s)]
                    msgs = [m for m in msgs if m.lower() not in ("error", "message")]
                    if re.match(r"\s*error:\s*(.+)", s, re.I) and not msgs:
                        msgs = [re.match(r"\s*error:\s*(.+)", s, re.I).group(1)]
                    for msg in msgs:
                        if not STAR.search(s) and not in_sources(msg):
                            fail(f"{where}: error message \"{msg[:60]}\" has no ` *` on its line (in a comment)")
                shown = example or re.search(r"\b(example|sample)", prev, re.I)
                if s not in old and not CALL.match(s) and (
                        ERR_DEF.search(s) or re.match(r"\d{3}\b", s) if shown else ERR_DEF.search(s) or DEFINES.search(s)):
                    check_literals(where, s, True)  # code that defines a value or an error, or an example's result code
                continue
            if s.startswith("#"):
                section, hdr = s.lstrip("# ").lower(), None
                continue
            if s.startswith("|"):
                cells = [c.strip() for c in s.strip("|").split("|")]
                if hdr is None:
                    hdr = [c.lower() for c in cells] if any("decision" in c.lower() for c in cells) else []
                elif hdr and not set("".join(cells)) <= set("-: ") and s not in old:
                    check_row(where, cells, hdr)
                elif hdr == [] and s not in old and not example and not section.startswith("interface"):
                    check_literals(where, s, False)
                continue
            hdr = None if not s else hdr
            prev = s or prev  # the prose line before a code block says whether the block is an example
            body = LIST_MARK.sub("", s)
            if not body or s in old or body.lower().startswith("said:") or section.startswith("interface"):
                continue
            if name == "system.md" and not STAR.search(s) and not s.endswith(":") and (
                    re.search(r"\bpick\b", s, re.I) or (section.startswith("gaps") and re.search(r"\bdefault", s, re.I))):
                fail(f"{where}: line holds a pick or a default and no ` *`: {s[:90]}")
                check_literals(where, body, False)
                continue
            if RULE.search(body) and not STAR.search(s) and not any(in_sources(q) for q in quotes(s)):
                fail(f"{where}: line holds a number or rule, and no ` *` and no quote: {s[:90]}")
            if not example and not body.lower().startswith(("example", "e.g.")):
                check_literals(where, body, False)


def check_screens():
    """With screens.html in the round: each message the screens show (text, or a string in the page's script, with a
    space and ending in . ! ? or an ellipsis) is in what people said or a decisions row marked ` *`."""
    path = os.path.join(round_dir, "screens.html")
    if not os.path.isfile(path):
        return
    page = re.sub(r"<style.*?</style>", "", open(path, encoding="utf-8", errors="replace").read(), flags=re.S)
    found = [m.group(1) for m in re.finditer(r">([^<>]+)<", page)]
    found += [a or b or c for a, b, c in re.findall(r'"([^"\n]{4,})"|\'([^\'\n]{4,})\'|`([^`\n]{4,})`', page)]
    old = ""
    if "--earlier" in opts and os.path.isfile(os.path.join(opts["--earlier"], "screens.html")):
        old = open(os.path.join(opts["--earlier"], "screens.html"), encoding="utf-8", errors="replace").read()
    seen = set()
    for raw in found:  # a limit the screens state ("Up to 12 photos") carries its number from a quote or a row
        text = " ".join(html.unescape(raw).split())
        if raw not in old and LIMIT.search(text) and not re.search(r"[{};=]|<\w", text):
            for num in dict.fromkeys(re.findall(r"(?<![\w.:/-])\d+(?:\.\d+)?(?![\d.:]*\d)", text)):
                if not traced(num):
                    fail(f"{path}: \"{text[:60]}\" states {num}, in no quote of what people said and in no decisions "
                         "row marked ` *`; add the row")
    for raw in found:
        msg = " ".join(html.unescape(raw).replace("\\'", "'").split())
        if (msg in seen or raw in old or " " not in msg or not re.search(r"[.!?…]$", msg)
                or re.search(r"[{};=]|<\w", msg) or "not part of the app" in msg.lower()):
            continue
        seen.add(msg)
        if any(t.fullmatch(norm(msg).strip(" .,;:!?")) for t in templates()):
            continue
        # the fixed words of a message: what a script fills in, a quoted sample and a sample number or date are left out
        for part in re.split(r"'\s*\+.*?\+\s*'|\"\s*\+.*?\+\s*\"|\$\{[^}]*\}|<[^>]*>|“[^”]*”|\"[^\"]*\"|\S*\d\S*|"
                        r"\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\b", msg):
            n = norm(part).strip(" .,;:!?'\"")
            if len(n) >= 4 and not in_sources(part) and n not in starred_rows():
                fail(f"{path}: message \"{msg[:60]}\" is in no quote of what people said and in no decisions "
                     "row marked ` *`; add the row")
                break


def check_interface():
    """With screens.html in the round: system.md's Interface names screens.html#<id> for real ids, each found in the file."""
    html, sysmd = os.path.join(round_dir, "screens.html"), os.path.join(round_dir, "system.md")
    if not (os.path.isfile(html) and os.path.isfile(sysmd)):
        return
    text = open(sysmd, encoding="utf-8").read()
    iface = re.split(r"\n## ", text.split("\n## Interface", 1)[1], 1)[0] if "\n## Interface" in text else ""
    page = open(html, encoding="utf-8", errors="replace").read()
    ids = re.findall(r"screens\.html#([A-Za-z][\w-]*)", iface)
    if not ids:
        fail(f"{sysmd}: Interface gives no line per screen as screens.html#<its id>, with the real id")
    for i in dict.fromkeys(ids):
        if not re.search(r"[\"'#]" + re.escape(i) + r"[\"']", page):
            fail(f"{sysmd}: Interface names screens.html#{i}, and screens.html holds no screen with that id")


def think_questions():
    skill = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "SKILL.md")
    out, inside = [], False
    for line in open(skill, encoding="utf-8"):
        if line.startswith("## "):
            inside = line.strip() == "## Think"
        elif inside and line.startswith("- "):
            out.append(" ".join(re.findall(r"[a-z]+", line.lower())[:3]))
    return out


def check_answers(path):
    design = os.path.dirname(os.path.abspath(round_dir.rstrip("/")))
    texts, skip = [], {os.path.abspath(path), os.path.abspath(said_path)}
    if "--markup" in opts:
        skip.add(os.path.abspath(opts["--markup"]))
    for d, _, fs in os.walk(design):
        for f in fs:
            if f.endswith((".md", ".html", ".txt")) and os.path.abspath(os.path.join(d, f)) not in skip:
                texts.append(open(os.path.join(d, f), encoding="utf-8", errors="replace").read())
    pool = " ".join(norm("\n".join(texts) + "\n" + said + "\n" + markup).replace("|", " ").split())
    heads = think_questions()
    seen = set()
    for n, line in enumerate(open(path, encoding="utf-8"), 1):
        s = line.strip()
        key = " ".join(re.findall(r"[a-z]+", s.lower())[:6])
        q_of = next((h for h in heads if h and h in key), None)
        if not s.startswith(("- ", "* ")) or q_of is None:
            continue
        seen.add(q_of)
        qs = cited(s)
        if not qs:
            fail(f"{path}:{n}: answer has no \"<quoted line>\" (<where it is>): {s[:80]}")
            continue
        for q in qs:
            nq = " ".join(norm(q).replace("|", " ").split())
            if len(nq) >= 6 and nq not in pool:
                fail(f"{path}:{n}: quote found in no design file, said file or markup: \"{q[:70]}\"")
    for h in heads:
        if h not in seen:
            fail(f"{path}: no answer for the Think question starting \"{h}\"")


check_round()
check_screens()
check_interface()
if "--earlier" in opts:
    check_changes()
if "--answers" in opts:
    check_answers(opts["--answers"])
print(f"FAILS: {len(fails)}")
sys.exit(1 if fails else 0)
