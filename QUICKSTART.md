# Homebrew Setup Quickstart

Quick commands to get your Homebrew tap up and running.

## Prerequisites

- [ ] Ensure `auths --version` works locally
- [ ] Ensure you have commit/push access to `bordumb/auths`
- [ ] Ensure you can create a new GitHub repository

## Step 1: Create Tap Repository (5 minutes)

```sh
# On GitHub, create a new public repository: homebrew-auths
# Then locally:
cd ~/workspace/repositories  # or wherever you keep repos
git clone git@github.com:bordumb/homebrew-auths-cli.git
cd homebrew-auths-cli
mkdir Formula
echo "# Homebrew Tap for Auths" > README.md
git add .
git commit -m "Initial commit"
git push origin main
```

## Step 2: Create a Test Release (2 minutes)

```sh
cd /Users/bordumb/workspace/repositories/auths-base/auths

# Make sure everything is committed
git status

# Create and push a tag
git tag -a v0.0.1-rc.6 -m "Release v0.0.1-rc.6"
git push origin v0.0.1-rc.6

# Monitor the release workflow
# Go to: https://github.com/bordumb/auths/actions
# Wait for it to complete (~5-10 minutes)
```

## Step 3: Update and Test Formula (5 minutes)

```sh
cd /Users/bordumb/workspace/repositories/auths-base/auths/homebrew

# Update the formula with checksums from the release
./update-formula.sh 0.0.1-rc.6

# Review the changes
cat auths.rb

# Copy to tap repository
cp auths.rb ~/workspace/repositories/homebrew-auths/Formula/

# Test the formula
cd ~/workspace/repositories/homebrew-auths
brew audit --strict --online Formula/auths.rb
```

## Step 4: Test Installation (3 minutes)

```sh
cd ~/workspace/repositories/homebrew-auths

# Install from local formula
brew install --build-from-source ./Formula/auths.rb

# Verify all three binaries work
auths --version
auths-sign --version
auths-verify --version

# Run Homebrew tests
brew test auths

# Clean up
brew uninstall auths
```

## Step 5: Publish (1 minute)

```sh
cd ~/workspace/repositories/homebrew-auths

git add Formula/auths.rb README.md
git commit -m "Add auths v0.0.1-rc.6 formula"
git push origin main
```

## Step 6: Test Public Installation (1 minute)

```sh
# Install from the published tap
brew install bordumb/auths/auths

# Verify it works
auths --version

# Success! 🎉
```

## Troubleshooting

### Release workflow failed
- Check GitHub Actions logs for errors
- Common issue: Rust toolchain version mismatch
- Solution: Check `rust-toolchain.toml` and workflow file match

### update-formula.sh can't find checksums
- Verify the release completed successfully
- Check the release assets exist: https://github.com/bordumb/auths/releases
- Verify filenames match: `auths-macos-x86_64.tar.gz` and `auths-macos-aarch64.tar.gz`

### brew audit fails
- Read the error message carefully
- Common issues:
  - SHA256 mismatch: Re-run `update-formula.sh`
  - Invalid URL: Check the version number in URLs
  - Style issues: Run `brew style --fix Formula/auths.rb`

### Installation fails with "binary not found"
- Check tar.gz contents:
  ```sh
  curl -sL https://github.com/bordumb/auths/releases/download/v0.0.1-rc.6/auths-macos-aarch64.tar.gz | tar -tz
  ```
- Should see: `auths`, `auths-sign`, `auths-verify`
- If not, check the release workflow packaging step

### brew test fails
- Run manually to see the error:
  ```sh
  /opt/homebrew/bin/auths --version
  ```
- Verify the version output contains the version number

## Expected Timeline

- **Total time:** ~20 minutes (including waiting for CI)
- **Active time:** ~10 minutes
- **CI wait time:** ~10 minutes

## Next Release (Future)

For subsequent releases, it's much faster:

```sh
# 1. Tag and push (30 seconds)
git tag -a v0.0.1-rc.7 -m "Release v0.0.1-rc.7"
git push origin v0.0.1-rc.7

# 2. Wait for CI (~10 minutes)

# 3. Update formula (1 minute)
cd /Users/bordumb/workspace/repositories/auths-base/auths/homebrew
./update-formula.sh 0.0.1-rc.7
cp auths.rb ~/workspace/repositories/homebrew-auths/Formula/

# 4. Test and publish (2 minutes)
cd ~/workspace/repositories/homebrew-auths
brew audit --strict Formula/auths.rb
git add Formula/auths.rb
git commit -m "Update auths to v0.0.1-rc.7"
git push origin main

# 5. Verify (30 seconds)
brew upgrade auths
auths --version
```

## Automation (Optional)

To fully automate formula updates:

```sh
cd ~/workspace/repositories/homebrew-auths
mkdir -p .github/workflows
cp /Users/bordumb/workspace/repositories/auths-base/auths/homebrew/auto-update-workflow.yml \
   .github/workflows/auto-update.yml
git add .github/workflows/auto-update.yml
git commit -m "Add auto-update workflow"
git push origin main
```

Then for each release, just trigger the workflow from the Actions tab!

## Help

Questions or issues?
- Check SETUP_GUIDE.md for detailed explanations
- Check README.md for quick reference
- Check the Homebrew documentation: https://docs.brew.sh/Formula-Cookbook
