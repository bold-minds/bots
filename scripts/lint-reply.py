#!/usr/bin/env python3
"""Reply-shape lint: checks a focus reply against the mechanically decidable
rules in advice/shared/focus-template.md and coding/shared/engine.md.

Usage:
    scripts/lint-reply.py <file>...     # lint each file
    ... | scripts/lint-reply.py         # lint stdin

Exits non-zero if any violation is found.

Scope: this decides only what the text alone can settle — preamble, nesting,
scorekeeping, packing. It says nothing about whether the right items were
selected or whether a line is understandable. Those stay human.
"""
import re
import sys

# "Raises load" and "no nesting" rules, as patterns.
NESTING = [
    (r"—[^—\n]{12,}—", "em-dash aside"),
    (r"\S\s+—\s+\S.*\S\s+—\s+\S", "two em-dashes in one line"),
    (r"\b(which|that)\s+(breaks|puts|means|makes|gives|shows|leaves|carries|would|is|was)\b",
     "which/that clause"),
    (r";", "semicolon"),
    (r"\([^)]{15,}\)", "parenthetical"),
    (r"[\"“][^\"”]{25,}[\"”]", "embedded quote"),
]

# "The opening is the surviving list and nothing else."
PREAMBLE = [
    (r"^\s*[-*]?\s*(Sweep run|Data ritual|Ran the |The \w+ ritual|Swept again|Nothing has moved|Nothing changed)",
     "opens on the run, not a finding"),
    (r"\balready ran (today|at)\b", "reports that the ritual ran"),
    (r"\bwindow \d{1,2}:\d{2}\s*(→|->)", "sweep window in the reply"),
]

# The Scorekeeping refusal.
SCOREKEEPING = [
    (r"\b\d+\s*days?\s+(open|unconfirmed|stale)\b", "how long an item has been open"),
    (r"\bafter (five|four|three|two|\d+)\s+asks\b", "how many times it was raised"),
    (r"\b(dead|unconfirmed|open)\s+since\s+\w+", "how long since"),
    (r"\bI had it wrong\b|\bre-spoken\b|\bI got it wrong\b", "the focus's own error record"),
    (r"\bfolded into #\d+|\bentered separately\b", "how an entry was filed"),
]

MAX_SENTENCE_WORDS = 25
MAX_BULLET_WORDS = 30
MAX_STATEMENTS_PER_BULLET = 2   # a trailing question does not count


def sentences(line):
    return [s.strip() for s in re.split(r"(?<=[.!?])\s+", line) if s.strip()]


def bullets(text):
    return [l for l in text.splitlines() if re.match(r"^\s*[-*]\s+\S", l)]


def check(text):
    out = []
    lines = [l for l in text.splitlines() if l.strip()]

    if lines:
        for pat, name in PREAMBLE:
            if re.search(pat, lines[0], re.I):
                out.append(("PREAMBLE", name, lines[0][:70]))

    for line in lines:
        for pat, name in SCOREKEEPING:
            for m in re.finditer(pat, line, re.I):
                out.append(("SCOREKEEPING", name, m.group(0)))

    bl = bullets(text)

    # Prose blocks get the same treatment as bullets. Without this the whole
    # lint is blind to the original failure — a wall of paragraphs scores clean
    # because every per-bullet check iterates over an empty list.
    prose = [l for l in lines if l not in bl]
    if len(prose) > 1 and not bl:
        out.append(("SHAPE", f"{len(prose)} prose blocks, no bullets",
                    "the opening is a bulleted list"))

    for unit, kind in [(b, "bullet") for b in bl] + [(p, "paragraph") for p in prose]:
        body = re.sub(r"^\s*[-*]\s+", "", unit)
        for pat, name in NESTING:
            m = re.search(pat, body)
            if m:
                out.append(("NESTING", name, m.group(0)[:50]))
        ss = sentences(body)
        support = [s for s in ss if not s.rstrip().endswith("?")]
        if len(support) > MAX_STATEMENTS_PER_BULLET:
            out.append(("PACKED", f"{len(support)} statements in one {kind}", body[:60]))
        if len(body.split()) > MAX_BULLET_WORDS:
            out.append(("PACKED", f"{len(body.split())}-word {kind}", body[:60]))
        for s in ss:
            if len(s.split()) > MAX_SENTENCE_WORDS:
                out.append(("PACKED", f"{len(s.split())}-word sentence", s[:60]))
    return out


def lint(label, text):
    findings = check(text)
    print(f"{label}: {len(text.split())} words, {len(bullets(text))} bullets")
    for kind, name, ev in findings:
        print(f"  [{kind}] {name}: {ev!r}")
    if not findings:
        print("  clean")
    return findings


def main(argv):
    failed = False
    if argv:
        for path in argv:
            with open(path) as fh:
                if lint(path, fh.read()):
                    failed = True
    else:
        if lint("stdin", sys.stdin.read()):
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
