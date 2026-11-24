# What people said about slugline

Everything below is what people said, in their words, in the order they said it. Nothing here was added by AI.
Source: the project's issue tracker, by issue and paragraph.

- (issue 1, para 1, maintainer) "I want a small Go package, module example.org/slugline, that turns a post title into a URL slug: lowercase, words joined by hyphens."
- (issue 1, para 2, maintainer) "Slugs can't be longer than 60 characters. Cut at a word boundary, never mid-word."
- (issue 1, para 3, contributor) "Accented letters like é should become plain e."
- (issue 1, para 4, contributor) "What about titles in scripts that have no Latin form, like Japanese? Not sure if we drop them or keep them."
- (issue 1, para 5, maintainer) "An empty title, or one that ends up empty after cleaning, is an error the caller has to handle. Don't make up a slug."
- (issue 2, para 1, maintainer) "Second thing: given the slugs a site already has, make a new one unique by adding -2, -3 and so on."
- (issue 2, para 2, contributor) "Our static site generator calls it in-process. No network, no command line."
