---
mode: "agent"
description: "Create a new cpuminer-opt-docker release: optionally check for new upstream cpuminer-opt versions, bump versions, update CHANGELOG.md with upstream changes, then tag and publish a GitHub release."
---

Create a release for this repository.

## Workflow

1. **Version input.** If no version is provided in the request, ask for it (format `25.6` or `v25.6`).
2. **Normalize** to `VERSION` (without `v`) and `TAG` (`v${VERSION}`).
3. **Fetch upstream cpuminer-opt release notes** from `https://github.com/JayDDee/cpuminer-opt/releases/tag/v${VERSION}` using `gh release view v${VERSION} --repo JayDDee/cpuminer-opt --json body -q .body`. Extract the changelog items (bug fixes, features, improvements) — ignore SHA256 checksums and GPG signatures.
4. **Update `CHANGELOG.md`**: add a new section at the top (below the header) with:
   - `## [${VERSION}] - ${YYYY-MM-DD}` (today's date)
   - `### Upstream cpuminer-opt changes` — list items from step 3
   - `### Packaging changes` — list any packaging changes made in this release (if any)
5. **Update version references** in these files:
   - `Dockerfile` → `ARG VERSION_TAG=v${VERSION}` (with `v` prefix)
   - `build.sh` → `version="${VERSION}"` (without `v` prefix)
   - `README.md` — update version references if present
   - `CHANGELOG.md` — already updated in step 4
6. **Validate** with:
   - `docker build . -t cniweb/cpuminer-opt:test`
   - `docker run --rm cniweb/cpuminer-opt:test cpuminer --version`
   - `docker run --rm cniweb/cpuminer-opt:test cpuminer --cputest`
7. **Commit** using message: `chore(release): ${TAG}`
8. **Create and push** Git tag `${TAG}`.
9. **Create a GitHub release** with title/body based on the latest previous release text, replacing old tag/version with the new one. Include a summary of upstream changes in the release body.
10. **Report** exactly which files changed and final tag/release URL.

Prefer using the workflow `Create Release From Version` (`.github/workflows/release-from-version.yml`) when possible. The workflow handles steps 5, 7, 8, and 9 automatically but does **not** update `CHANGELOG.md` — that must be done manually or by the agent before running the workflow.

## Checking for new upstream versions

When asked to check for a new cpuminer-opt version:

1. Run `gh release list --repo JayDDee/cpuminer-opt --limit 5` to find the latest release.
2. Compare with the current version in `Dockerfile` (`ARG VERSION_TAG=...`).
3. If a newer version exists, report it and ask whether to proceed with the release workflow above.
