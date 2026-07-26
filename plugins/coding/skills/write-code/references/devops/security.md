# DevOps Security

## Supply Chain Security

### SLSA Levels
| Level | Requirements | Protects Against |
|---|---|---|
| L1 | Documented build process, provenance metadata | Release mistakes |
| L2 | Hosted build platform, digitally signed provenance | Post-build tampering |
| L3 | Build isolation, signing keys inaccessible to build steps | Build-time tampering, insider threats |
- GitHub Actions satisfies L2 out of the box. Use `slsa-framework/slsa-github-generator` for L3.

### Sigstore
- Cosign: sign and verify container images and artifacts.
- Fulcio: short-lived signing certificates tied to OIDC identity (no long-lived keys).
- Rekor: public transparency log for all signing events.
- Use keyless signing with OIDC in CI — eliminates key management.

### SBOM
- Formats: SPDX (strong license metadata) or CycloneDX (optimized for security analysis).
- Integrate generation into CI — every build auto-generates SBOM.
- Capture entire dependency tree including transitive deps.
- Include: component names, versions, suppliers, hashes, licenses.
- Tools: Syft, Trivy, CycloneDX CLI.
- Block deployments if critical vulnerabilities detected in SBOM.
- Store SBOMs alongside release artifacts.

## Secrets Management

### Storage
- Use centralized secrets management (Vault, AWS Secrets Manager, GCP Secret Manager).
- Encrypt at rest using AES-256-GCM or ChaCha20-Poly1305.
- Store encryption keys separately, preferably in HSMs.
- NEVER hardcode in source code, config files, or container images.
- NEVER pass via Docker ENV/ARG instructions.
- NEVER commit to version control — persists in history permanently.

### Rotation & Lifecycle
- Automate rotation. API keys: 90 days. DB credentials: 30 days. Certificates: before expiry.
- Configure automatic expiration dates.
- Immediately revoke compromised secrets and verify no reuse.

### Access Control
- Least privilege: engineers should not access all secrets.
- Role-based policies at individual secret level.
- CI systems get dedicated service accounts with scoped access.
- Mount as volumes rather than environment variables (env vars visible in process inspection).

### Auditing
- Log all access: who, when, from where, approval/rejection.
- Tamper-resistant audit log storage.
- Alert on anomalies: unexpected locations, mass downloads, unusual patterns.

## GitHub Actions Hardening
- Restrict third-party actions at org level — require approval for new additions.
- Fork high-risk dependencies — internal copies with security hardening.
- Use OpenSSF Scorecards to detect injection, permissive tokens, unpinned actions.
- Add `.github/workflows` to CODEOWNERS for required reviewer approval.
- Disable "Allow GitHub Actions to create and approve pull requests" at org level.
- Never use self-hosted runners for public repositories.
- Ephemeral/JIT runners only — clean, isolated, auto-removed after one job.
