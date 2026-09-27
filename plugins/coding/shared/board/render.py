#!/usr/bin/env python3
"""render.py <release.md> — the board's HTML on stdout, from its written form.

The release file is the board. Its shape:

    # <title>
    Launch: <YYYY-MM-DD>
    Board: <artifact url>
    Beta: <nn>–<nn>[ except <nn>, <nn>]                             optional: the stories in the beta cut; each card
                                                                    carries a beta or v1 tag top left (Claire, 19 Sept);
                                                                    an excepted story is v1 (Claire, 27 Sept: 10)

    <nn> <stop> <state> <YYYY-MM-DD> — <sentence>. <sentence>.     one card line per story
    Next: <nn> — <title of the story not yet written>                optional, one

    ## Before any story builds                                      optional, bullets
    - …

A card line is exactly shared/hil/templates/card.md, and a bad one stops the
render. The story's title comes from docs/product/stories/<nn>-*.md beside the
release file. Nothing is drawn by hand: change a line, render, publish.
"""
import datetime as dt, html, pathlib, re, sys

STOPS = ["Requirements", "Story", "Design", "Tasks", "Building", "Code Review", "Test", "Launched"]
STATES = {"done": "done", "now": "now", "waiting-owner": "wait", "waiting-dependency": "dep", "not-started": ""}
CARD = re.compile(r"^(\d{2}) (Requirements|Story|Design|Tasks|Building|Code Review|Test|Launched) (done|now|waiting-owner|waiting-dependency|not-started) (\d{4}-\d{2}-\d{2}) — (.+)$")

def die(msg):
    sys.stderr.write(f"render: {msg}\n"); sys.exit(1)

def main(path):
    p = pathlib.Path(path).resolve()
    text = p.read_text(encoding="utf-8").splitlines()
    title = next((l[2:].strip() for l in text if l.startswith("# ")), None) or die("no '# <title>' line")
    launch = next((l.split(":", 1)[1].strip() for l in text if l.startswith("Launch:")), None) or die("no 'Launch: <YYYY-MM-DD>' line")
    board = next((l.split(":", 1)[1].strip() for l in text if l.startswith("Board:")), "")
    nxt = next((l.split(":", 1)[1].strip() for l in text if l.startswith("Next:")), "")
    beta_line = next((l.split(":", 1)[1].strip() for l in text if l.startswith("Beta:")), "")
    beta = set()
    if beta_line:
        m = re.match(r"^(\d{2})\s*[–-]\s*(\d{2})(?:\s+except\s+(\d{2}(?:\s*,\s*\d{2})*))?$", beta_line) or die("Beta: is '<nn>–<nn>[ except <nn>, <nn>]'")
        beta = {f"{i:02d}" for i in range(int(m.group(1)), int(m.group(2)) + 1)} - set(re.findall(r"\d{2}", m.group(3) or ""))
    def tag(nn):
        if not beta_line: return ""
        return '<span class="tag beta">beta</span>' if nn in beta else '<span class="tag v1">v1</span>'
    cards, before, section, before_title = [], [], None, "Before any story builds"
    for l in text:
        if l.startswith("## "):
            section = l[3:].strip()
            if section.lower().startswith("before"): before_title = section
            continue
        if section and section.lower().startswith("before") and l.startswith("- "):
            before.append(l[2:].strip()); continue
        m = CARD.match(l)
        if m:
            nn, stop, state, date, tail = m.groups()
            sentences = re.findall(r"[^.]+\.", tail)
            if len(sentences) != 2: die(f"card {nn}: {len(sentences)} sentence(s); a card is two")
            if len(tail.split()) > 40: die(f"card {nn}: over 40 words")
            cards.append((nn, stop, state, date, sentences[0].strip(), sentences[1].strip()))
        elif re.match(r"^\d{2} ", l):
            die(f"a card line that is not '<nn> <stop> <state> <YYYY-MM-DD> — <two sentences>': {l}")
    if not cards: die("no card lines")
    cards.sort(key=lambda c: c[0])  # the board is in story order, whatever order the lines were written in
    stories = p.parent / "stories"
    def story_title(nn):
        for f in sorted(stories.glob(f"{nn}-*.md")):
            if not f.name.endswith(".trd.md"):
                first = f.read_text(encoding="utf-8").splitlines()[0]
                return first[2:].strip() if first.startswith("# ") else f.stem
        die(f"no story file for {nn} under {stories}")
    today = dt.date.today()
    ld = dt.date.fromisoformat(launch)
    days = (ld - today).days
    e = html.escape
    out = []
    out.append(f"<title>{e(title)}</title>")
    out.append(CSS)
    out.append("<main>")
    out.append(f'<header><h1>{e(title)}</h1><div class="ship">launch <b>{ld.strftime("%-d %b %Y")}</b> at the latest · today {today.strftime("%-d %b")} · <b>{days} days</b></div></header>')
    out.append('<div class="legend"><span class="l-done">done</span><span class="l-now">happening now</span><span class="l-wait">waiting on the owner</span><span class="l-dep">waiting on a dependency</span><span>not started</span></div>')
    out.append('<ol class="stories">')
    waiting = []
    for nn, stop, state, date, s1, s2 in cards:
        at = STOPS.index(stop)
        track = []
        for i, s in enumerate(STOPS):
            cls = "done" if i < at else (STATES[state] if i == at else "")
            track.append(f'<div class="stop {cls}">{e(s)}</div>')
        if state == "waiting-owner": waiting.append(f"{nn}: {s2}")
        d = dt.date.fromisoformat(date).strftime("%-d %b")
        out.append(f'<li class="story"><div class="num">{tag(nn)}{nn}</div><p class="name">{e(story_title(nn))}</p><div class="track">{"".join(track)}</div><p class="stand"><b>{e(stop)} {e(state.replace("-", " "))}, {d}.</b> {e(s1)} {e(s2)}</p></li>')
    if nxt:
        m = re.match(r"^(\d{2}) — (.+)$", nxt) or die("Next: is '<nn> — <title>'")
        track = "".join(f'<div class="stop {"done" if i == 0 else ("now" if i == 1 else "")}">{e(s)}</div>' for i, s in enumerate(STOPS))
        out.append(f'<li class="story next"><div class="num">{m.group(1)}</div><p class="name">{e(m.group(2))}</p><div class="track">{track}</div><p class="stand"><b>Next to write.</b></p></li>')
    out.append("</ol>")
    if before:
        out.append(f'<section class="box before"><h2>{e(before_title)}</h2><ul>' + "".join(f"<li>{e(b)}</li>" for b in before) + "</ul></section>")
    out.append('<section class="box claire"><h2>Waiting on the owner</h2><ul>' + ("".join(f"<li>{e(w)}</li>" for w in waiting) or "<li>Nothing.</li>") + "</ul></section>")
    out.append(f'<footer>{e(p.name)} is the written form of this board; rendered {today.isoformat()} by shared/board/render.py</footer>')
    out.append("</main>")
    sys.stdout.write("\n".join(out) + "\n")

CSS = """<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Serif:wght@500&display=swap">
<style>
  :root { --paper:#f3f5f7; --ink:#1c2127; --muted:#5b6673; --rule:#d3d9df; --track:#c9d1d8; --done:#1f7a4d; --now:#b7791f; --now-soft:#f6e9cf; --wait:#9a3b3b; --wait-soft:#f5dcdc; --dep:#4a5fa8; --dep-soft:#dfe4f5; --card:#ffffff; }
  @media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { --paper:#14181c; --ink:#e6e9ec; --muted:#9aa5b1; --rule:#2b333b; --track:#3a434d; --done:#5fcf94; --now:#e0a84a; --now-soft:#3a2e14; --wait:#e07a7a; --wait-soft:#3b2020; --dep:#8fa3e6; --dep-soft:#1f2540; --card:#1b2026; } }
  :root[data-theme="dark"] { --paper:#14181c; --ink:#e6e9ec; --muted:#9aa5b1; --rule:#2b333b; --track:#3a434d; --done:#5fcf94; --now:#e0a84a; --now-soft:#3a2e14; --wait:#e07a7a; --wait-soft:#3b2020; --dep:#8fa3e6; --dep-soft:#1f2540; --card:#1b2026; }
  body { background:var(--paper); color:var(--ink); font-family:"IBM Plex Sans","Helvetica Neue",Arial,sans-serif; font-size:15px; line-height:1.45; margin:0; }
  main { max-width:900px; margin:0 auto; padding-block:36px 60px; padding-inline:20px; }
  header { display:flex; justify-content:space-between; align-items:baseline; gap:16px; flex-wrap:wrap; border-bottom:2px solid var(--ink); padding-bottom:10px; }
  h1 { font-family:"IBM Plex Serif",Georgia,serif; font-weight:500; font-size:26px; margin:0; text-wrap:balance; }
  .ship { font-family:"IBM Plex Mono",Menlo,monospace; font-size:13px; color:var(--muted); font-variant-numeric:tabular-nums; }
  .ship b { color:var(--ink); font-weight:500; }
  .legend { display:flex; gap:18px; flex-wrap:wrap; margin:14px 0 6px; font-size:12.5px; color:var(--muted); letter-spacing:0.02em; text-transform:uppercase; }
  .legend span::before { content:""; display:inline-block; width:10px; height:10px; border-radius:50%; margin-right:6px; vertical-align:-1px; background:var(--track); }
  .legend .l-done::before { background:var(--done); } .legend .l-now::before { background:var(--now); } .legend .l-wait::before { background:var(--wait); } .legend .l-dep::before { background:var(--dep); }
  ol.stories { list-style:none; margin:0; padding:0; display:grid; gap:10px; }
  li.story { background:var(--card); border:1px solid var(--rule); border-radius:6px; padding:14px 16px 12px; display:grid; grid-template-columns:44px 1fr; gap:6px 12px; }
  li.story.next { border-color:var(--now); }
  .num { font-family:"IBM Plex Mono",Menlo,monospace; color:var(--muted); font-size:13px; padding-top:3px; display:flex; flex-direction:column; align-items:flex-start; gap:4px; }
  .tag { font-family:"IBM Plex Sans","Helvetica Neue",Arial,sans-serif; font-size:9.5px; font-weight:600; letter-spacing:0.08em; text-transform:uppercase; padding:1px 5px; border-radius:3px; line-height:1.4; }
  .tag.beta { background:var(--done); color:var(--card); } .tag.v1 { background:var(--track); color:var(--ink); }
  .name { font-weight:600; font-size:16px; margin:0; }
  .track { grid-column:2; display:grid; grid-template-columns:repeat(8,1fr); position:relative; margin-top:4px; }
  .track::before { content:""; position:absolute; left:6.25%; right:6.25%; top:7px; height:2px; background:var(--track); }
  .stop { position:relative; text-align:center; font-size:11px; color:var(--muted); letter-spacing:0.02em; text-transform:uppercase; }
  .stop::before { content:""; display:block; width:14px; height:14px; border-radius:50%; margin:0 auto 5px; background:var(--card); border:2px solid var(--track); box-sizing:border-box; }
  .stop.done::before { background:var(--done); border-color:var(--done); } .stop.done { color:var(--done); }
  .stop.now::before { background:var(--now); border-color:var(--now); box-shadow:0 0 0 4px var(--now-soft); } .stop.now { color:var(--now); font-weight:600; }
  .stop.wait::before { background:var(--wait); border-color:var(--wait); } .stop.wait { color:var(--wait); font-weight:600; }
  .stop.dep::before { background:var(--dep); border-color:var(--dep); box-shadow:0 0 0 4px var(--dep-soft); } .stop.dep { color:var(--dep); font-weight:600; }
  .stand { grid-column:2; margin:2px 0 0; font-size:13.5px; color:var(--muted); max-width:70ch; }
  .stand b { color:var(--ink); font-weight:500; }
  section.box { margin-top:26px; padding:12px 16px; border-radius:0 6px 6px 0; }
  section.claire { background:var(--wait-soft); border-left:3px solid var(--wait); } section.claire h2 { color:var(--wait); }
  section.before { background:var(--dep-soft); border-left:3px solid var(--dep); } section.before h2 { color:var(--dep); }
  section.box h2 { font-size:12.5px; text-transform:uppercase; letter-spacing:0.06em; margin:0 0 6px; }
  section.box ul { margin:0; padding-left:18px; font-size:13.5px; } section.box li { margin:3px 0; }
  footer { margin-top:22px; font-size:12.5px; color:var(--muted); font-family:"IBM Plex Mono",Menlo,monospace; }
  @media (max-width:640px) { .stop { font-size:9px; } .track { grid-template-columns:repeat(4,1fr); row-gap:10px; } .track::before { display:none; } }
</style>"""

if __name__ == "__main__":
    if len(sys.argv) != 2: die("usage: render.py <release.md>")
    main(sys.argv[1])
