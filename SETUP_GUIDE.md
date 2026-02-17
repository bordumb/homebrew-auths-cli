# Complete Homebrew Setup Guide for Auths

This guide will walk you through setting up Homebrew distribution for Auths, from creating the tap to publishing updates.

## Overview

- **Main Repository:** `bordumb/auths` (contains the source code and release workflow)
- **Tap Repository:** `bordumb/homebrew-auths-cli` (already exists at `~~/path/to/homebrew-auths-cli/`)
- **Formula:** `auths.rb` (defines how to install auths)

## Step 1: Initial Setup (Already Done! ✅)

The tap repository is already set up:
- **Local:** `~~/path/to/homebrew-auths-cli/`
- **Remote:** `git@github.com:bordumb/homebrew-auths-cli.git`
- **Formula directory:** Already created

Just commit the initial files:
```sh
cd ~~/path/to/homebrew-auths-cli
git add .
git commit -m "Initial Homebrew formula setup"
git push origin main
```

## Step 2: Prepare a Release

Before setting up the formula, we need an actual release with checksums.

1. In the main `auths` repository, create a new release:
   ```sh
   cd ~/path/to/auths
   git tag -a v0.0.1-rc.7 -m "Release v0.0.1-rc.7"
   git push origin v0.0.1-rc.7
   ```

2. Wait for the GitHub Action to complete (check Actions tab on GitHub)

3. Verify the release assets are created:
   - Go to: https://github.com/bordumb/auths/releases/tag/v0.0.1-rc.7
   - Should see: `auths-macos-x86_64.tar.gz`, `auths-macos-aarch64.tar.gz`, and their `.sha256` files

## Step 3: Update the Formula

1. Get the checksums from the release:
   ```sh
   # From the homebrew directory
   cd ~/path/to/auths/homebrew

   # Use the update script
   ./update-formula.sh 0.0.1-rc.7
   ```

   Or manually:
   ```sh
   curl -sL https://github.com/bordumb/auths/releases/download/v0.0.1-rc.7/auths-macos-x86_64.tar.gz.sha256
   curl -sL https://github.com/bordumb/auths/releases/download/v0.0.1-rc.7/auths-macos-aarch64.tar.gz.sha256
   ```

2. Copy the updated formula to the tap:
   ```sh
   cp auths.rb ~/path/to/homebrew-auths-cli/Formula/
   ```

## Step 4: Test the Formula Locally

Before publishing, always test:

```sh
cd ~/path/to/homebrew-auths-cli

# Audit the formula
brew audit --strict --online Formula/auths.rb

# Install from the formula
brew install --build-from-source ./Formula/auths.rb

# Test all three binaries
auths --version
auths-sign --version
auths-verify --version

# Run Homebrew's test
brew test auths

# Check installation
which auths
ls -la $(which auths)
```

If everything works:
```sh
brew uninstall auths
```

## Step 5: Publish the Formula

1. Commit and push to the tap repository:
   ```sh
   cd ~/path/to/homebrew-auths-cli
   git add Formula/auths.rb
   git commit -m "Add auths v0.0.1-rc.7"
   git push origin main
   ```

2. Test the public installation:
   ```sh
   brew install bordumb/auths-cli/auths
   auths --version
   ```

## Step 6: Set Up Auto-Updates (Optional)

1. Copy the auto-update workflow to the tap repository:
   ```sh
   cd ~/path/to/homebrew-auths-cli
   mkdir -p .github/workflows
   cp ~/path/to/auths/homebrew/auto-update-workflow.yml \
      .github/workflows/auto-update.yml
   git add .github/workflows/auto-update.yml
   git commit -m "Add auto-update workflow"
   git push origin main
   ```

2. To trigger updates manually:
   - Go to Actions tab in the tap repository
   - Select "Auto-update Formula"
   - Click "Run workflow"
   - Enter the version number

## Updating for New Releases

### Manual Process

1. Create a new release in the main repository:
   ```sh
   cd ~/path/to/auths
   git tag -a v0.0.1-rc.7 -m "Release v0.0.1-rc.7"
   git push origin v0.0.1-rc.7
   ```

2. Wait for the release to complete

3. Update the formula:
   ```sh
   cd ~/path/to/auths/homebrew
   ./update-formula.sh 0.0.1-rc.7
   ```

4. Test locally:
   ```sh
   cp auths.rb ~/path/to/homebrew-auths-cli/Formula/
   cd ~/path/to/homebrew-auths-cli
   brew audit --strict Formula/auths.rb
   brew install --build-from-source ./Formula/auths.rb
   brew test auths
   brew uninstall auths
   ```

5. Commit and push:
   ```sh
   git add Formula/auths.rb
   git commit -m "Update auths to v0.0.1-rc.7"
   git push origin main
   ```

### Semi-Automated Process

Use Homebrew's bump tool:

```sh
brew bump-formula-pr \
  --url="https://github.com/bordumb/auths/releases/download/v0.0.1-rc.7/auths-macos-x86_64.tar.gz" \
  --sha256="<sha256>" \
  bordumb/auths-cli/auths
```

### Fully Automated Process

If you set up the auto-update workflow, trigger it from the Actions tab or configure repository dispatch events.

## Verification Checklist

Before each release:
- [ ] Version number in `Cargo.toml` is correct
- [ ] Git tag matches the version
- [ ] Release workflow completes successfully
- [ ] All platform archives are created (macOS Intel, macOS ARM)
- [ ] SHA256 files are generated for each archive
- [ ] Formula version field matches the release version
- [ ] SHA256 values in formula match the release assets
- [ ] Formula passes `brew audit --strict --online`
- [ ] Installation works: `brew install --build-from-source`
- [ ] All binaries work: `auths`, `auths-sign`, `auths-verify`
- [ ] Version output is correct: `auths --version`
- [ ] Tests pass: `brew test auths`

## Troubleshooting

### SHA256 Mismatch
- Re-download the checksums from the release
- Verify you're using the correct version number
- Check that the formula URL matches the actual release asset name

### Formula Audit Failures
- Run `brew audit --strict --online Formula/auths.rb` for detailed errors
- Common issues: missing license, incorrect URL format, style violations

### Installation Failures
- Verify the tar.gz contains the expected binaries:
  ```sh
  curl -sL https://github.com/bordumb/auths/releases/download/v0.0.1-rc.7/auths-macos-aarch64.tar.gz | tar -tz
  ```
- Should see: `auths`, `auths-sign`, `auths-verify`

### Binary Not Found After Installation
- Check Homebrew's bin directory: `ls $(brew --prefix)/bin/auths*`
- Verify PATH includes Homebrew bin: `echo $PATH`

## Files Overview

```
auths/
└── homebrew/
    ├── auths.rb                      # The Homebrew formula
    ├── README.md                     # Quick reference
    ├── SETUP_GUIDE.md                # This file
    ├── update-formula.sh             # Script to update checksums
    └── auto-update-workflow.yml      # GitHub Action for tap repo
```

## Next Steps

1. **Create the tap repository:** `homebrew-auths-cli` on GitHub
2. **Create a test release:** Tag and push v0.0.1-rc.7
3. **Update the formula:** Run `./update-formula.sh 0.0.1-rc.7`
4. **Test locally:** Follow Step 4 above
5. **Publish:** Follow Step 5 above
6. **Announce:** Update README.md with installation instructions

## User Installation (After Setup)

Once published, users can install with:

```sh
brew install bordumb/auths-cli/auths
```

Or:

```sh
brew tap bordumb/auths
brew install auths
```

Upgrade:
```sh
brew upgrade auths
```
