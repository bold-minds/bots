# Markup on rename-a-plant.design.md

1. Packages and functions, PRs, Tests: don't add plants.Store.Rename. The store already has Update(ctx, Plant); use that.
2. Libraries: drop the validator library. ValidName checks the length by hand.

Everything else is approved as it is.
