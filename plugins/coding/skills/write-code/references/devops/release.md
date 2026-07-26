# Release Management

## Release Automation Tools

| Tool | Approach | Human Approval | Best For |
|---|---|---|---|
| semantic-release | Fully automated from conventional commits | No | Zero-touch releases |
| release-please | Creates/maintains release PRs | Yes — merge to release | Review before release |
| changesets | Developer-authored changeset files per PR | Yes — fine-grained | Monorepos, detailed notes |

### semantic-release Workflow
1. Analyzes commits since last release.
2. Determines next version from conventional commits.
3. Generates changelog/release notes.
4. Creates Git tag.
5. Publishes package.
6. Creates GitHub Release.

### release-please Workflow
1. Monitors conventional commits on main.
2. Continuously updates a release PR with accumulated changes.
3. On merge: creates tag, GitHub Release, updates CHANGELOG.md.
4. Supports monorepo per-package versioning.

## Tagging
- Tag with `v` prefix: `v1.2.3`.
- Use annotated tags (`git tag -a`) with release notes.
- Never delete or move tags after publication.
- Automate artifact signing and provenance in release workflow.
- Include SHA256 checksums for all release artifacts.
- Use immutable tags — never overwrite a published artifact.

## Artifact Management
- Set automated retention policies. Keep production artifacts indefinitely. PR/branch artifacts for 7-30 days.
- Store in dedicated registries (GitHub Packages, ECR, Artifactory). Never in source control.
- Implement RBAC: CI publishes, developers read, only admins delete.
- Tag every build with Git SHA and timestamp for traceability.
