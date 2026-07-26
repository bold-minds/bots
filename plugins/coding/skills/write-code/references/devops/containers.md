# Containers & Docker

## Multi-Stage Builds
- Use multiple `FROM` statements: build stage (full SDK) → production stage (minimal runtime).
- Name stages descriptively: `FROM golang:1.21 AS builder`.
- Copy dependency manifests and install dependencies BEFORE copying source code — prevents full reinstalls on code changes.
- Copy only the compiled binary/artifacts to the final stage.

## Image Size
- Start from minimal base images: Alpine (~6 MB), distroless, or slim variants.
- Combine `apt-get update` and `install` in a single `RUN` with cache cleanup in the same layer.
- Use `.dockerignore` to exclude `.git`, `node_modules`, test artifacts, logs, docs.
- Prefer `COPY` over `ADD` — ADD has implicit tar extraction and URL behavior.
- Sort multi-line arguments alphabetically for maintainability.

## Layer Caching
- Order instructions from least to most frequently changed.
- Use `--mount=type=cache` for package manager caches (pip, npm, apt).
- Use `--mount=type=bind` for temporary file access instead of `COPY`.

## Security (12 Rules)
1. Keep host OS and Docker Engine updated.
2. Never expose `/var/run/docker.sock` to containers — grants root-equivalent access.
3. Run as non-root: `USER` directive with explicit UID/GID.
4. Drop all capabilities (`--cap-drop ALL`), add back only what's needed.
5. Disable privilege escalation (`--security-opt=no-new-privileges`).
6. Use custom networks, bind ports to `127.0.0.1` not `0.0.0.0`.
7. Apply seccomp/AppArmor/SELinux profiles.
8. Set resource limits (memory, CPU, restart policies, file descriptors).
9. Use `--read-only` filesystem, mount volumes as `:ro`, use `--tmpfs /tmp`.
10. Integrate vulnerability scanning (Trivy, Snyk, Docker Scout) in CI.
11. Consider rootless Docker mode.
12. Use Docker Secrets or external vaults — never embed secrets in images.
- Pin base images using digest hashes: `FROM alpine:3.21@sha256:...`
- Block deployment of images with critical/high CVEs.

## Health Checks
- Define `HEALTHCHECK` in Dockerfiles.
- Separate readiness probes (controls traffic routing) from liveness probes (triggers restarts).
- Readiness probes must NOT depend on external services — causes cascade failures.

## Container Design
- One concern per container.
- Design as ephemeral — start, run, replaceable with minimal config.
- Capture SIGTERM and gracefully drain connections.
- Use exec form: `CMD ["executable", "param1"]` not shell form.
- Set `WORKDIR` with absolute paths.
