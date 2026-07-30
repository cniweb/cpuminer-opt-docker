## Summary

<!-- What does this PR change and why? -->

## Checklist

- [ ] If this is a cpuminer-opt version bump: all files are in sync (`Dockerfile`, `build.sh`, `README.md`, `CHANGELOG.md`) — prefer using `release-from-version.yml` instead of editing these by hand.
- [ ] `CHANGELOG.md` has an `## [Unreleased]` entry describing this change (required before the release workflow can run).
- [ ] Shell scripts (`*.sh`) stay POSIX-compatible (`set -eu`, no bashisms) if touched.
- [ ] Ran `docker build .` locally, or relied on CI's `validate` job.
- [ ] Updated `AGENTS.md` / `.github/copilot-instructions.md` if this changes repo conventions, CI behavior, or known gotchas.

## Testing

<!-- How did you verify this change? Include commands/output where useful. -->
