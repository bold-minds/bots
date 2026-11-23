---
type: llm
focus: trace
weight: 1
---

The result states what must be decided and gives the skill's own pick as one named currency (an ISO code such as USD or the currency's name), together with a reason for it. The pick stands on its own: a rule ("the currency of the country where the business is registered"), a condition ("USD if the business is in the US") or a list of options is not a named currency, and fails even when a currency appears inside it.
