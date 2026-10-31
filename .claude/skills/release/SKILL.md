---
name: release
description: Update Python dependencies (pip-compile) and release a new quark Docker image tagged YY.MM via GitHub Actions. Use when asked to update deps, bump requirements, cut/publish a release, or release a new docker image.
---

# Update dependencies and release quark

Release version is `YY.MM` of the current date (e.g. Nov 2026 -> `26.11`). If the
user gives an explicit version, use it for that run only; do not carry it over.
Re-releasing within the same month re-tags the same version (`release.sh` replaces
the tag).

Docker images are built and pushed to Docker Hub (`rsubr/quark`) by GitHub Actions
(`.github/workflows/build-release.yml`) on any pushed tag. Never build images locally.

## Steps

1. **Pre-flight**: `cd` to the repo root, `git status`, confirm branch is `main`.
   Pre-existing uncommitted edits (e.g. `requirements.in`) are usually intended for
   this release; check `git diff` and include them.
2. **Compile deps**: `./pip-compile.sh` (needs docker; runs `pip-compile --upgrade
   --generate-hashes` in a `python:3.12-bookworm` container and rewrites
   `requirements.txt`). It takes several minutes: run it in the background and wait
   for completion. Without `--upgrade`, pip-compile keeps existing pins and updates
   nothing.
3. **Review**: `git diff --stat`; skim changed `==` lines with
   `git diff requirements.txt | grep -E '^[+-][a-zA-Z0-9_.-]+=='`. Report notable
   major bumps to the user.
4. **Commit**: `git add requirements.in requirements.txt` (plus any script changes)
   and `git commit` with a message like `pip updates`.
5. **Release**: `./release.sh <YY.MM>`. It force-tags HEAD, deletes the remote tag
   (an error here is fine if the tag does not exist yet), pushes `main`, then pushes
   the tag. Pushing the tag triggers the build.
6. **Watch the build**:
   ```
   gh run list --repo rsubr/quark --limit 3
   gh run watch <run-id> --repo rsubr/quark --exit-status
   ```
   Both matrix jobs (amd64 and arm64) and the `manifest` job must pass. On failure,
   inspect with `gh run view <run-id> --log-failed`, fix, commit, and re-run
   `./release.sh <YY.MM>` to move the tag.
7. **Report** the run result and the resulting image tag `rsubr/quark:<YY.MM>`.

## Notes
- `pip-compile.sh` uses `-ti` for docker only when a TTY exists, so it also works
  from non-interactive agents.
- `pip-update.py requirements.in` prints latest PyPI versions of the top-level
  packages; handy for pinned entries (e.g. `playwright==x`) in `requirements.in`.
