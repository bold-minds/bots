# foundations

The two bookends of any deliverable. `capture-intent` runs before the work starts; `check-evidence` runs before the work is claimed done. Neither is code-specific — both apply to config, documents, strategy, and skill design as much as they apply to code.

## Skills

### capture-intent

Makes sure the request is understood before any work begins. It quotes the request verbatim, enumerates every discrete element (including what's implicit but unstated), and names the concrete mechanism that will fulfill each one — flagging anything that depends on the model choosing to act rather than being mechanically guaranteed.

### check-evidence

Adversarial self-review run before any completion claim. It traces every element of the original intent to a deliverable, checks that every artifact created has a real consumer, greps for deferral language, checks for time-decay (would this work cold, without the current conversation's context), ranks findings by severity, and reports in a mandated evidence-based shape.

Both skills are model-triggered only — there are no slash commands for either. The model decides when to invoke them based on their descriptions; there is nothing here for a user to type.

The `coding` plugin's `write-code` skill invokes both of these at the appropriate points in its flow, and degrades gracefully if `foundations` is not installed.

## Install

```
claude plugin install foundations@bots
```
