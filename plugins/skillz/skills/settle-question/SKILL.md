---
name: settle-question
description: Settle a question from what people said, the work's inputs and the tools already installed, or return it to the caller with a pick. Use before returning any question to a caller, in any work, and whenever a choice comes up that the work can't go on without.
---

# Settle question

## In
- The question: what must be chosen, and what the work can't do until it is.
- What people have already said or decided that bears on the question, in their words, and the work's own inputs. Either may be empty; use what there is.

## Out
Returned to the caller, one of:
- Settled: the answer, and where it came from.
- Default: the answer taken, marked as a default, and why.
- Question: what must be decided, your pick as one named answer, and why you picked it.

Beside it, any other question that came up while settling it and meets the bar in `## In`, named as a new question to settle with what the work can't do until it is answered, and left unsettled: no answer, default or pick.

With a default or a question, any MCP that isn't installed but would answer it, and what it would answer. And this skill's Think answers, one line per question, each saying what it led the skill to do, kept apart from the answer.

## Think
- Does anything people have said or decided, or the work's inputs, settle it?
- Could an installed MCP or other tool look up the answer?
- Would an MCP that isn't installed answer it?
- Is it hard to undo, and does it change what comes next?
- Is everything I am about to answer the question I was given, or did another question come up that the work can't go on without?

## Act
1. Check the question against `## In`: it says what must be chosen and what the work can't do until it is. If it doesn't, return it to the caller, saying exactly what's missing and what it must contain.
2. Check what people have said or decided, and the work's inputs. If they settle it, return it as settled, with its source.
3. Look it up with any installed MCP or tool that holds the answer, reading only. If one settles it, return it as settled, with the tool as its source.
4. If it's both hard to undo and changes what comes next, return it as a question, with your pick: one named answer, the likeliest on what you have, and why you picked it. The caller can accept a named answer as it stands.
5. Otherwise, return a default, marked as a default, with its reason.
6. With a question or a default, name any MCP that isn't installed but would answer it, and what it would answer.
7. Answer only the question you were given. Return another question beside the answer only when it came up while settling this one and meets the bar in `## In`: what must be chosen, and what the work can't do until it is. Name it as a new question to settle, say what the work can't do until it is answered, and leave it unsettled, because answering it here would commit the caller to a choice it never saw. Anything the work can go on without stays out.
