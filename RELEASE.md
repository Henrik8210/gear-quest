# CurseForge release

Publishing uses **GitHub Actions**, not the CurseForge webhook. Keep any CurseForge GitHub webhook **inactive**.

## One-time setup

1. **Create CurseForge project** at [authors.curseforge.com](https://authors.curseforge.com/) for GearQuest.
2. Copy the **Project ID** from CurseForge → Overview → paste into `GearQuest/GearQuest.toc` as `## X-Curse-Project-ID:`.
3. **API token:** [authors.curseforge.com → API tokens](https://authors.curseforge.com/#/settings/api-tokens) → create token.
4. **GitHub secret:** Repo → Settings → Secrets and variables → Actions → New repository secret:
   - Name: `CF_API_KEY`
   - Value: your CurseForge API token
5. **CurseForge Source (optional):** Link this GitHub repo for metadata only. Uploads come from Actions.

## Release steps

Only when explicitly publishing:

1. Bump `## Version:` in `GearQuest/GearQuest.toc` and `GearQuest/Core.lua` (`GQ.VERSION`).
2. Add a `## vX.Y.Z` section to `CHANGELOG.md`.
3. Commit and push to `main`.
4. Tag and push: `git tag vX.Y.Z` then `git push origin vX.Y.Z` (tag must match version with `v` prefix).
5. Verify **GitHub Actions → Release** succeeds.
6. Check CurseForge → **Files** — new file appears as Processing, then Approved.

## Rules

- **Never tag** unless explicitly publishing a release.
- **Do not** delete and re-push tags — bump the patch version instead.
- Pushing to `main` alone is **not** a release.

## First upload

After `CF_API_KEY` is set and the CurseForge project ID is in the toc:

```powershell
git tag v0.1.0
git push origin v0.1.0
```

Then confirm the Release workflow and CurseForge Files tab.
