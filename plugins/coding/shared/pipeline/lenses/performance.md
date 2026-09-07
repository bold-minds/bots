# Performance lens

- What does this cost per customer per day, in tokens or vendor calls? Is there a ceiling, and is it declared or a default?
- Does it read a whole bucket, table, or site when it needs one thing?
- Does it hold a shared lane, slot, or lock while waiting on something slow?
- What happens at 10× today's customers? At 100×? Say where it breaks first.
- Is anything done on every request that could be done once?
- Only raise what a customer would feel or the bill would show. Skip micro-optimisation.
