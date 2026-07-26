---
name: capture-intent
description: >
  Understand what the user is asking for and how you'll deliver it, before starting
  work. Use at the beginning of any task that will produce deliverables — code, skills, config,
  documentation, architecture. Prevents building the wrong thing or building the right thing
  the wrong way.
---

# Capture Intent

Before doing any work, make sure you understand what "done" looks like and how you'll get there.

## The Process

### 1. Capture the full request.

Quote the user's exact words. If intent was built across multiple messages, combine them. Not your interpretation. Not a paraphrase. Their words.

### 2. Enumerate every discrete element.

Break the request into individually verifiable pieces:

- If they named specific items (authors, features, endpoints), list each one.
- If they described behavior ("it should do X and Y"), list X and Y separately.
- If they referenced existing things ("like the one in Z"), note what Z is.
- What does the user obviously expect even if they didn't say it? Add these as elements marked **(implicit)**.

Partial enumeration = missed requirements later. If the user said 7 things, list 7 things.

### 3. Define how each element will be fulfilled.

For each element, state the concrete approach — not just *what* but *how*:

- What file, function, step, or mechanism will fulfill this element?
- Is the fulfillment **mechanical** (guaranteed to execute) or does it depend on the model choosing to act? If the latter, find a mechanical approach.
- What does "done" look like for this element? How will we verify it?

This is where bad plans get caught. "Put author teachings in reference files" sounds like a plan but isn't one unless you also specify what forces those files to be read.

### 4. Surface risks for this type of task.

Based on the kind of work being done, flag known pitfalls:

- **Skills:** Reference files need unconditional consumers. File paths in prose don't get Read at runtime.
- **Code:** Shared interfaces need all callers updated. New dependencies need to be in allowlists.
- **Config:** Dependent systems may expect the old format. Rollback path needed.

Ask yourself: what's the most likely way this specific task silently fails?

### 5. Present to the user.

Show the user:

1. Their request (quoted)
2. The elements you identified
3. How each element will be fulfilled
4. Risks you flagged

If any element is ambiguous or the approach for any element seems weak, say so. Let the user correct course now — not after you've built the wrong thing.

Then begin work.
