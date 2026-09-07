# Database lens

- What is written, where? Can two of those places disagree about the same fact?
- Is any write not atomic with the read that decided it?
- What is deleted, when, and can it be undone? Does deletion refuse for a paying customer?
- Is versioning or a backup relied on? Does anything assert it is on?
- Is a key, prefix, or naming convention assumed that a rename would break?
- Does it need a migration? For existing rows, what do they mean under the new code?
