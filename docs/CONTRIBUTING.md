# Contributing to homebrew-auths-cli

This document explains how to publish and maintain the Homebrew tap for auths.

---

## First-Time Publishing

### Prerequisites

1. **GitHub Repository**
   - Repository must be public
   - Name must follow Homebrew convention: `homebrew-<tap-name>`
   - This repo: `homebrew-auths-cli`

2. **Formula File**
   - Located at `Formula/auths.rb`
   - Must be valid Ruby syntax
   - Must pass `brew audit`

3. **Release Artifacts**
   - Release exists at `https://github.com/bordumb/auths/releases/tag/v<VERSION>`
   - Contains macOS binaries:
     - `auths-macos-x86_64.tar.gz`
     - `auths-macos-aarch64.tar.gz`
   - Contains checksums or attestations:
     - `auths-macos-x86_64.tar.gz.auths.json` (preferred)
     - `auths-macos-x86_64.tar.gz.sha256` (fallback)

### Step 1: Create a Release in Main Repo

From the `auths` repository:

```bash
cd /Users/bordumb/workspace/repositories/auths-base/auths

# Create and push tag
git tag -a v0.0.1-rc.9 -m "Release candidate 7"
git push origin v0.0.1-rc.9
```

This triggers the release workflow which:
- Builds binaries for all platforms
- Creates GitHub release
- (Will) Generate `.auths.json` attestations
- Triggers `repository_dispatch` to this repo (needs `HOMEBREW_TAP_TOKEN` secret)

### Step 2: Update Formula with Real Checksums

The formula currently has placeholder SHA256s. Update them:

```bash
cd /Users/bordumb/workspace/repositories/auths-base/homebrew-auths-cli

# Run update script (requires jq)
./update-formula.sh 0.0.1-rc.9
```

This script:
- Downloads `.auths.json` attestations (or `.sha256` files)
- Extracts SHA256 checksums
- Updates `Formula/auths.rb`
- Creates a backup at `Formula/auths.rb.bak`

### Step 3: Test Formula Locally

**Critical: Always test before publishing!**

> **Note:** `brew install` and `brew audit --online` require a real GitHub release with
> binaries to exist. Run `./update-formula.sh <VERSION>` first to replace the placeholder
> SHA256 values with real checksums. Without that, only the offline syntax check will pass.

```bash
# Link local directory as the tap (required once before auditing/installing)
brew tap bordumb/auths-cli "$(pwd)"

# Syntax-only check (works even before a real release exists)
brew audit --strict bordumb/auths-cli/auths

# Full check including URL reachability (requires real release + real SHA256s)
brew audit --strict --online bordumb/auths-cli/auths

# Install from the tapped formula (requires real SHA256s from update-formula.sh)
brew install bordumb/auths-cli/auths

# Test the installation
brew test bordumb/auths-cli/auths
auths --version

# Uninstall test version
brew uninstall auths
brew untap bordumb/auths-cli
```

### Step 4: Commit and Push

```bash
git add Formula/auths.rb
git commit -m "Initial formula for auths v0.0.1-rc.9"
git push origin main
```

### Step 5: Publish to GitHub (One-Time)

Make sure the repository is public:

```bash
# Check repository visibility
gh repo view bordumb/homebrew-auths-cli

# If private, make it public
gh repo edit bordumb/homebrew-auths-cli --visibility public
```

### Step 6: Users Can Now Install

Users can install via:

```bash
brew tap bordumb/auths-cli
brew install auths
```

Or in one command:

```bash
brew install bordumb/auths-cli/auths
```

---

## Maintaining Releases (Automated)

Once the initial setup is complete, future releases are mostly automated.

### Automated Workflow

1. **Developer pushes tag in main repo**:
   ```bash
   cd auths
   git tag -a v0.0.1-rc.9 -m "Release"
   git push origin v0.0.1-rc.9
   ```

2. **Main repo release workflow**:
   - Builds binaries
   - Creates GitHub release
   - Sends `repository_dispatch` to `homebrew-auths-cli`

3. **This repo's auto-update workflow** (`.github/workflows/auto-update-workflow.yml`):
   - Triggered by `repository_dispatch`
   - Downloads attestations/checksums
   - Updates `Formula/auths.rb`
   - Runs `brew audit` and `brew test`
   - Creates pull request

4. **Maintainer reviews and merges PR**:
   ```bash
   cd homebrew-auths-cli
   gh pr list
   gh pr view <NUMBER>
   gh pr merge <NUMBER> --merge
   ```

### Required GitHub Secret

For automation to work, the `auths` repo needs this secret:

**In `auths` repo → Settings → Secrets → Actions:**

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `HOMEBREW_TAP_TOKEN` | GitHub Personal Access Token | Token with `repo` scope for `homebrew-auths-cli` |

To create the token:

1. Go to https://github.com/settings/tokens/new
2. Name: "Homebrew Tap Automation"
3. Expiration: 1 year (or No expiration)
4. Scopes: Check `repo` (full control of private repositories)
5. Generate token
6. Copy token
7. Add to `auths` repo secrets as `HOMEBREW_TAP_TOKEN`

---

## Manual Release Updates

If automation fails or you want to update manually:

### Manual Update Process

```bash
cd /Users/bordumb/workspace/repositories/auths-base/homebrew-auths-cli

# 1. Update formula with new version
./update-formula.sh <VERSION>

# Example:
./update-formula.sh 0.0.1-rc.9

# 2. Review changes
git diff Formula/auths.rb

# 3. Test locally
brew tap bordumb/auths-cli "$(pwd)"
brew audit --strict --online bordumb/auths-cli/auths
brew install bordumb/auths-cli/auths
brew test bordumb/auths-cli/auths
brew uninstall auths
brew untap bordumb/auths-cli

# 4. Commit and push
git add Formula/auths.rb
git commit -m "Update auths to v<VERSION>"
git push origin main
```

### Triggering Automation Manually

You can manually trigger the auto-update workflow:

```bash
# Via GitHub CLI
gh workflow run auto-update-workflow.yml \
  --repo bordumb/homebrew-auths-cli \
  -f version=0.0.1-rc.9

# Or via GitHub UI
# Go to: Actions → Auto-update Formula → Run workflow
```

---

## Testing the Formula

### Local Testing (Before Publishing)

```bash
# Link local directory as the tap
brew tap bordumb/auths-cli "$(pwd)"

# Syntax check
brew audit --strict --online bordumb/auths-cli/auths

# Install from the tapped formula
brew install bordumb/auths-cli/auths

# Run formula's test block
brew test bordumb/auths-cli/auths

# Check binary works
auths --version
auths --help

# Uninstall
brew uninstall auths
```

### Testing as End User (After Publishing)

```bash
# Fresh install
brew tap bordumb/auths-cli
brew install auths

# Upgrade test
brew upgrade auths

# Uninstall test
brew uninstall auths
brew untap bordumb/auths-cli
```

---

## Troubleshooting

### Formula Update Script Fails

**Error**: `Failed to fetch checksums`

**Solution**:
1. Check release exists: https://github.com/bordumb/auths/releases/tag/v<VERSION>
2. Verify assets are uploaded (binaries + checksums)
3. Check asset names match exactly:
   - `auths-macos-x86_64.tar.gz`
   - `auths-macos-aarch64.tar.gz`

**Error**: `jq: command not found`

**Solution**:
```bash
brew install jq
```

### Automation Not Triggering

**Problem**: Release created but no PR appears in `homebrew-auths-cli`

**Checks**:
1. Verify `HOMEBREW_TAP_TOKEN` secret exists in `auths` repo
2. Check token has `repo` scope
3. Check token hasn't expired
4. View workflow run in `auths` repo Actions tab
5. Check for errors in repository dispatch step

**Manual trigger**:
```bash
./update-formula.sh <VERSION>
git add Formula/auths.rb
git commit -m "Update formula"
git push
```

### brew audit Failures

**Error**: `sha256 mismatch`

**Solution**: Re-run update script to fetch correct checksums:
```bash
./update-formula.sh <VERSION>
```

**Error**: `URL not reachable`

**Solution**: Wait a few minutes for GitHub release CDN to propagate, then retry.

**Error**: `test do block failed`

**Solution**: Update the test block in `Formula/auths.rb` if CLI interface changed.

### Users Can't Find Formula

**Problem**: `brew install auths` returns "No available formula"

**Solution**: Users need to tap first:
```bash
brew tap bordumb/auths-cli
brew install auths
```

Or use fully qualified name:
```bash
brew install bordumb/auths-cli/auths
```

---

## Release Checklist

Use this checklist for each release:

### Pre-Release
- [ ] Version number bumped in `auths/crates/auths-cli/Cargo.toml`
- [ ] CHANGELOG updated in main repo
- [ ] All tests passing in main repo
- [ ] Binary builds successfully on macOS (x86_64 and aarch64)

### Release
- [ ] Tag created and pushed in main repo
- [ ] GitHub release created with binaries
- [ ] Attestations/checksums uploaded (`.auths.json` or `.sha256`)

### Homebrew Update
- [ ] Formula updated (automated or manual)
- [ ] `brew audit --strict --online` passes
- [ ] Local `brew install` test passes
- [ ] `brew test auths` passes
- [ ] Binary works: `auths --version`

### Post-Release
- [ ] Formula changes merged to main
- [ ] Test user installation: `brew tap` + `brew install`
- [ ] Update QUICKSTART.md if installation steps changed
- [ ] Announce release (GitHub discussions, social media, etc.)

---

## Best Practices

1. **Always test locally before pushing formula changes**
   - Broken formulas frustrate users
   - Use `brew audit` and `brew install --build-from-source`

2. **Keep formula simple**
   - Minimize dependencies
   - Follow Homebrew conventions
   - Don't add features Homebrew doesn't need

3. **Version numbers must match**
   - Formula version must match release tag
   - SHA256s must match actual binaries

4. **Communicate breaking changes**
   - Update QUICKSTART.md if CLI commands change
   - Add caveats to formula if migration needed
   - Announce in release notes

5. **Monitor automation**
   - Check PRs from auto-update workflow
   - Don't blindly merge - review changes
   - Test if formula structure changed

6. **Keep secrets secure**
   - Rotate `HOMEBREW_TAP_TOKEN` annually
   - Use minimal scopes (only `repo`)
   - Don't commit tokens to git

---

## Getting Help

- **Homebrew Documentation**: https://docs.brew.sh/Formula-Cookbook
- **Homebrew Taps Guide**: https://docs.brew.sh/Taps
- **Auths Issues**: https://github.com/bordumb/auths/issues
- **Formula Issues**: https://github.com/bordumb/homebrew-auths-cli/issues

---

## Quick Reference

### Common Commands

```bash
# Update formula
./update-formula.sh <VERSION>

# Test formula (tap local dir first)
brew tap bordumb/auths-cli "$(pwd)"
brew audit --strict --online bordumb/auths-cli/auths
brew install bordumb/auths-cli/auths
brew test bordumb/auths-cli/auths

# Manual workflow trigger
gh workflow run auto-update-workflow.yml -f version=<VERSION>

# View recent PRs
gh pr list

# Merge PR
gh pr merge <NUMBER> --merge
```

### Important Files

- `Formula/auths.rb` - The Homebrew formula
- `update-formula.sh` - Updates formula with new checksums
- `.github/workflows/auto-update-workflow.yml` - Automation workflow
- `QUICKSTART.md` - User-facing installation guide
- `docs/CONTRIBUTING.md` - This file

### GitHub Secrets Needed

In `auths` repo:
- `HOMEBREW_TAP_TOKEN` - For triggering formula updates

In `homebrew-auths-cli` repo:
- None required (auto-update workflow runs with GITHUB_TOKEN)

---

*Last updated: 2026-02-17*
