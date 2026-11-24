"""Write a milestone's build report from the build log and the build state only.

Usage: python3 build-report.py <build folder> <milestone id> [--check]
  build folder: holds data/build-log.jsonl and data/build-state.json
  milestone id: as the build state names it (for example M1)
  --check:      write nothing; fail when the report still holds a pick to fill

The state holds "milestones": [{"id", "name", "status", "stories": [{"id", "step", "status", "produced"}]}].
The log holds one JSON object per line.
  A step record: {"record": "step", "step", "for" (app, a milestone id or a story id), "round", "pr",
    "model", "effort", "duration_ms", "tokens", "check_misses_first": [{"kind", "where"}], "fix_round",
    "misses_left": [{"kind", "where"}], "questions": [...], "estimate_lines", "lines",
    "failing_scenarios": [...], "released_to"}
  A caller record: {"record": "caller", "kind": "answer" | "approval" | "markup" | "rejection", "step", "for",
    "round", "pr", "question", "answer", "a_source_said_it" (the line, or null), "markup"}
Fields that don't apply are left out or null.

Writes data/build-report-<milestone id>.md and prints its path. Each recurring problem ends the report as a
question whose pick reads `Pick: <fill ...>`; replace each with the step skill and the line in it to change,
then run again with --check until it prints `PICKS LEFT: 0`.
"""
import json
import os
import re
import sys

ORDER = ["design-app", "write-requirements", "plan-milestones", "write-stories", "design-app", "design-tech",
         "build-story", "write-pr", "ship-milestone"]
FILL = "<fill: the step skill and the line in it to change>"


def mins(ms):
    s = round((ms or 0) / 1000)
    return f"{s // 60} min {s % 60} s" if s >= 60 else f"{s} s"


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) != 2:
        print(__doc__)
        sys.exit(2)
    folder, mid = args
    path = os.path.join(folder, "data", f"build-report-{mid}.md")
    if "--check" in sys.argv:
        text = open(path).read() if os.path.exists(path) else ""
        left = text.count("<fill")
        print(f"{path}: {'missing' if not text else 'found'}\nPICKS LEFT: {left if text else 1}")
        sys.exit(1 if left or not text else 0)
    state = json.load(open(os.path.join(folder, "data", "build-state.json")))
    log = [json.loads(l) for l in open(os.path.join(folder, "data", "build-log.jsonl")) if l.strip()]
    ms = state.get("milestones", [])
    m = next((x for x in ms if x.get("id") == mid), None)
    if m is None:
        print(f"no milestone {mid} in the build state")
        sys.exit(2)
    stories = {s.get("id") for s in m.get("stories", [])}
    scope = stories | {mid} | ({"app"} if ms and ms[0].get("id") == mid else set())

    def mine(r):  # `for` names one or more stories, a milestone or app, maybe with a note: "M1 (before release)"
        return bool(set(re.split(r"[^\w-]+", str(r.get("for") or ""))) & scope)

    steps = [r for r in log if r.get("record") == "step" and mine(r)]
    caller = [r for r in log if r.get("record") == "caller" and mine(r)]
    names = [n for i, n in enumerate(ORDER) if n not in ORDER[:i]]
    names += sorted({r["step"] for r in steps} - set(names))
    out = [f"# Build report: {m.get('id')} {m.get('name', '')}".rstrip(), "",
           "From the build log and the build state only.", "", "## Per step", "",
           "| Step | Runs | Time | Tokens | Model, effort |", "|---|---|---|---|---|"]
    for n in names:
        rs = [r for r in steps if r["step"] == n]
        if not rs:
            continue
        me = sorted({f"{r.get('model', '?')}, {r.get('effort', '?')}" for r in rs})
        out.append(f"| {n} | {len(rs)} | {mins(sum(r.get('duration_ms') or 0 for r in rs))} "
                   f"| {sum(r.get('tokens') or 0 for r in rs):,} | {'; '.join(me)} |")

    def who(r):
        return f"{r.get('for')}" + (f" round {r['round']}" if r.get("round") else "") + (f" {r['pr']}" if r.get("pr") else "")

    first = [r for r in steps if not r.get("check_misses_first")]
    marked = {(r.get("step"), r.get("for"), r.get("round")) for r in caller if r.get("kind") in ("markup", "rejection")}
    clean = [r for r in caller if r.get("kind") == "approval" and (r.get("step"), r.get("for"), r.get("round")) not in marked]
    sized = [r for r in steps if r.get("estimate_lines") and r.get("lines") is not None]
    near = [r for r in sized if abs(r["lines"] - r["estimate_lines"]) <= r["estimate_lines"] / 2]
    off = [r for r in sized if r not in near]
    out += ["", "## Where it worked", "",
            "- Passed check-work the first time: " + (", ".join(f"{r['step']} ({who(r)})" for r in first) or "none") + ".",
            "- Approved without markup: " + (", ".join(f"{r['step']} ({who(r)})" for r in clean) or "none") + ".",
            "- PR sizes near the design's estimate: " + (", ".join(f"{r.get('pr') or r.get('for')}, {r['lines']} lines against {r['estimate_lines']}" for r in near) or "none") + "."]
    out += ["", "## Where it didn't", ""]
    per = {}
    kinds = {}
    for r in steps:
        for x in r.get("check_misses_first") or []:
            per[r["step"]] = per.get(r["step"], 0) + 1
            kinds.setdefault((r["step"], x.get("kind")), []).append((r.get("for"), x.get("where")))
    out.append("- check-work misses per step: " + (", ".join(f"{n} {per[n]}" for n in names if n in per) or "none") + ".")
    recur = [(k, v) for k, v in kinds.items() if len({f for f, _ in v}) > 1]
    for (n, kind), v in kinds.items():
        tag = "recurs across stories" if ((n, kind), v) in recur else "once"
        out.append(f"  - {n}: {kind} ({tag}: {', '.join(sorted({str(f) for f, _ in v}))}); example: {v[0][1]}")
    fixes = [r for r in steps if r.get("fix_round")]
    left = [(r, x) for r in steps for x in (r.get("misses_left") or [])]
    out.append(f"- Fix rounds: {len(fixes)}" + (" (" + ", ".join(f"{r['step']} {who(r)}" for r in fixes) + ")" if fixes else "") + ".")
    out.append(f"- Misses left after the one fix round: {len(left)}" + (" (" + "; ".join(f"{r['step']} {who(r)}: {x.get('where') or x.get('kind')}" for r, x in left) + ")" if left else "") + ".")
    mk = [r for r in caller if r.get("kind") == "markup"]
    rj = [r for r in caller if r.get("kind") == "rejection"]
    out.append(f"- The caller's markups: {len(mk)}" + (" (" + "; ".join(f"{r['step']} {who(r)}: \"{r.get('markup')}\"" for r in mk) + ")" if mk else "")
               + f"; rejections: {len(rj)}" + (" (" + "; ".join(f"{r['step']} {who(r)}" for r in rj) + ")" if rj else "") + ".")
    qs = [(r, q) for r in steps for q in (r.get("questions") or [])]
    ans = [r for r in caller if r.get("kind") == "answer" and r.get("a_source_said_it")]
    out.append(f"- Questions sent to the caller: {len(qs)}; a source could have answered: {len(ans)}"
               + (" (" + "; ".join(f"{r['step']} {r.get('for')}: {r.get('a_source_said_it')}" for r in ans) + ")" if ans else "") + ".")
    out.append("- PRs off the design's estimate by more than half: " + (", ".join(f"{r.get('pr') or r.get('for')}, {r['lines']} lines against {r['estimate_lines']}" for r in off) or "none") + ".")
    e2e = [(r, s) for r in steps if r["step"] == "ship-milestone" for s in (r.get("failing_scenarios") or [])]
    out.append("- E2E failures on test or live after ship: " + ("; ".join(f"{s} ({r.get('released_to') or '?'})" for r, s in e2e) or "none") + ".")
    probs = [f"{kind}, in {n} for {', '.join(sorted({str(f) for f, _ in v}))}" for (n, kind), v in recur]
    if len(ans) > 1:
        probs.append(f"questions a source already answered, {len(ans)} times, in {', '.join(sorted({r['step'] for r in ans}))}")
    if len(off) > 1:
        probs.append(f"PRs off the estimate by more than half, {len(off)} times")
    by = {}
    for r in mk + rj:
        by.setdefault(r["step"], []).append(r)
    probs += [f"the caller's markups or rejections on {n}, {len(v)} times" for n, v in by.items() if len(v) > 1]
    out += ["", "## Questions", ""]
    if not probs:
        out.append("No problem came back more than once.")
    for i, p in enumerate(probs, 1):
        out.append(f"{i}. Which skill line would stop {p}? Pick: {FILL}")
    open(path, "w").write("\n".join(out) + "\n")
    print(path)
    print(f"PICKS LEFT: {len(probs)}")


main()
