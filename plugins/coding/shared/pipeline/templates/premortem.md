# Pre-mortem — <story title>

It shipped. It went wrong. How? Returned as text; nothing is written.

Keep a case only if BOTH are yes:
- a real customer would plausibly hit it — point at a number if you can
- you can name the exact message, refusal, or fallback they get instead. No
  name, no case. "We could do something" is always yes and decides nothing.

| how it fails | customer hits it? | what they get instead | on the story? | kept |
|---|---|---|---|---|
| <business: the customer does X and …> | yes/no + the number | <the exact message, refusal, or fallback> | scenario <n> / no | ✓/✗ |
| <business, on purpose: someone who wants our money, another customer's data, or to make us send something we did not mean to send does X …> | yes/no + the number | <…> | <…> | ✓/✗ |
| <technical: the provider/store/network …> | yes/no + the number | <…> | <…> | ✓/✗ |

## What happens when it fails

<Each ✓ row, restated as Given / When / Then, ending in the exact message,
refusal, or fallback the customer gets. A row a scenario covers names it and
needs nothing more; a row no scenario covers is a proposed scenario, and the
TRD writer puts it in the Review table for the owner.>
