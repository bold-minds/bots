# Pre-mortem — <feature name>

It shipped. It went wrong. How?

Keep a case only if BOTH are yes:
- a real customer would plausibly hit it
- we could actually do something about it

| how it fails | customer hits it? | we can act? | kept | what they should get instead |
|---|---|---|---|---|
| <business: the customer does X and …> | yes/no | yes/no | ✓/✗ | <message, refusal, fallback> |
| <technical: the provider/store/network …> | yes/no | yes/no | ✓/✗ | <…> |

## What happens when it fails

<Each ✓ row, restated as Given / When / Then, ending in the exact message,
refusal, or fallback the customer gets. These go into the tasks.>

## Dropped, and why

<One line each. So nobody re-raises them.>
