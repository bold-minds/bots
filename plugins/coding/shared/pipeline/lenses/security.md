# Security lens — at the plan, before any code

The code-level review runs later, on every task. This is the design-level
question: what does this feature expose, and what does someone do with it on
purpose?

- What trust boundary does this cross? Every input that arrives from outside — a text, a URL, an image, a webhook, a form — is hostile until checked. Where is the check, and is it before the action?
- What can a stranger make us do or spend? A feature that turns an inbound message into work, a fetch, or a model call is a way to burn our money or our provider's patience. What bounds it — per sender, per day, globally?
- What can one customer do to another? Reach their data, their site, their address, their place in a queue?
- What does this feature put into a model prompt that came from outside? Customer text becomes instructions. What can it instruct?
- What does it fetch? A URL we are handed can point at our own network, a metadata endpoint, a huge file, a slow host.
- What does it make public or guessable — a URL, an id, a name — and does anything depend on it staying private?
- What credential, key, or token does it touch, and where could that leak — a log, an error message, a rendered page, an outbound call?
- Who can delete or overwrite, and on what check? An operator path with a thin guard is an attacker path with a thin guard.
- What is the worst thing an attacker gets if this ships as planned? Say it in one sentence. That sentence goes to the pre-mortem.
